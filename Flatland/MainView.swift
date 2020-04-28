//
//  ViewController.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/26/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import CoreImage
import SceneKit

class MainView: UIViewController, CAAnimationDelegate, SettingsProtocol
{
    /// Original orientation of the image with Greenwich, England as the baseline. Since this program
    /// treats midnight as the base and the image has Greenwich at the top, we need an offset value
    /// to make sure the image is rotated correctly, depending on settings,
    let OriginalOrientation: Double = 180.0
    
    /// Initialize the UI.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Settings.Initialize()
        FileIO.InitializeDirectory()

        //Initialize the please wait dialog
        PleaseWaitDialog.isHidden = true
        PleaseWaitDialog.isUserInteractionEnabled = false
        PleaseWaitDialog.layer.borderColor = UIColor.systemBlue.cgColor
        
        if Settings.GetViewType() == .FlatMap
        {
            WorldViewer3D.Hide()
            StarFieldView.Hide()
            SetFlatlandVisibility(IsVisible: true)
            let PoleIndex = Settings.GetImageCenter() == .NorthPole ? 0 : 1
            ViewTypeSegment.selectedSegmentIndex = PoleIndex
        }
        else
        {
            WorldViewer3D.Show()
            if Settings.ShowStars()
            {
                StarFieldView.Show()
            }
            SetFlatlandVisibility(IsVisible: false)
            ViewTypeSegment.selectedSegmentIndex = 2
        }
        
        DataStack.layer.borderColor = UIColor.white.cgColor
        ArcLayer.backgroundColor = UIColor.clear
        ArcLayer.layer.zPosition = 100000
        TopView.backgroundColor = UIColor.black
        SettingsDone()
        TopSun?.VariableSunImage(Using: SunViewTop, Interval: 0.1)
        BottomSun?.VariableSunImage(Using: SunViewBottom, Interval: 0.1)
        CityTestList = CityList.TopNCities(N: 50, UseMetroPopulation: true)
        
        MakeLatitudeBands()
        let Radius = ArcLayer.bounds.width / 2.0
        let Center = CGPoint(x: Radius, y: Radius)
        #if false
        let test = MakeArc(Start: 90.0,
                           End: 270.0,
                           Radius: Radius,
                           ArcWidth: 360.0,
                           Center: Center,
                           ArcColor: UIColor.black,
                           Rectangle: ArcLayer.bounds)
        ArcLayer.layer.addSublayer(test)
        #endif
        LocalDataTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                              target: self,
                                              selector: #selector(UpdateLocalData),
                                              userInfo: nil,
                                              repeats: true)
        
        let ContextMenu = UIContextMenuInteraction(delegate: self)
        TopView.addInteraction(ContextMenu)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    var LocalDataTimer: Timer? = nil
    
    func SetFlatlandVisibility(IsVisible: Bool)
    {
        WorldViewer.isHidden = !IsVisible
        GridOverlay.isHidden = !IsVisible
        ArcLayer.isHidden = !IsVisible
        HourLayer2D.isHidden = !IsVisible
        HourLayer2D.backgroundColor = UIColor.clear
        Show2DHours()
        if !IsVisible
        {
            SunViewTop?.alpha = 0.0
            SunViewBottom?.alpha = 0.0
        }
        else
        {
            SunViewTop?.alpha = 1.0
            SunViewBottom?.alpha = 1.0
            UpdateSunLocations()
        }
        if IsVisible
        {
            SunlightTimer = Timer.scheduledTimer(timeInterval: 60.0,
                                                 target: self,
                                                 selector: #selector(UpdateDaylight),
                                                 userInfo: nil,
                                                 repeats: true)
        }
        else
        {
            if SunlightTimer != nil
            {
                SunlightTimer?.invalidate()
                SunlightTimer = nil
            }
        }
    }
    
    func Show2DHours()
    {
        if Settings.GetViewType() == .Globe3D || Settings.GetViewType() == .CubicWorld
        {
            HourLayer2D.isHidden = false
            HourLayer2D.layer.sublayers?.removeAll()
            return
        }
        if Settings.GetShowHourLabels()
        {
            HourLayer2D.isHidden = false
            HourLayer2D.layer.zPosition = 40000
            HourLayer2D.layer.sublayers?.removeAll()
            HourLayer2D.backgroundColor = UIColor.clear
            
            let TextLayer = CALayer()
            TextLayer.zPosition = 50000
            let TextLayerRect = HourLayer2D.bounds
            TextLayer.frame = TextLayerRect
            TextLayer.bounds = TextLayerRect
            TextLayer.backgroundColor = UIColor.clear.cgColor
            let Radius = TextLayerRect.size.width / 2.0 
            let HourType = Settings.GetHourValueType()
            if HourType != .RelativeToLocation
            {
                let Rotation = CATransform3DMakeRotation(0.0, 0.0, 0.0, 1.0)
                    HourLayer2D.layer.transform = Rotation
            }
            for Hour in 0 ... 23
            {
                let Angle = CGFloat(Hour) / 24.0 * 360.0
                let Radial = Angle.Radians
                var DisplayHour = (Hour + 18) % 24
                var IncludeSign = false

                switch HourType
                {
                    case .Solar:
                        if Settings.GetImageCenter() == .NorthPole
                        {
                            DisplayHour = 24 - (DisplayHour + 12) % 24
                    }
                    
                    case .RelativeToLocation:
                        //Only valid if the user has entered local coordinates.
                        IncludeSign = true
                        if let LocalLongitude = Settings.GetLocalLongitude()
                        {
                            let Long = Int(LocalLongitude / 15.0)
                            DisplayHour = Hour - 18
                            if DisplayHour < -12
                            {
                                DisplayHour = 12 - (DisplayHour * -1) % 12
                            }
                            DisplayHour = DisplayHour * -1
                            DisplayHour = DisplayHour - Long
                            if DisplayHour >= 12
                            {
                                DisplayHour = 12 - (DisplayHour % 12)
                                DisplayHour = DisplayHour * -1
                            }
                            if DisplayHour < -12
                            {
                                DisplayHour = (12 + (DisplayHour % 12))
                            }
                            if Settings.GetImageCenter() == .SouthPole
                            {
                                DisplayHour = DisplayHour * -1
                            }
                        }
                    
                    case .RelativeToNoon:
                    IncludeSign = true
                    DisplayHour = DisplayHour - 12
                    if Settings.GetImageCenter() == .NorthPole
                    {
                        DisplayHour = (DisplayHour + 12) % 24
                        if DisplayHour > 12
                        {
                            DisplayHour = DisplayHour - 24
                        }
                        DisplayHour = DisplayHour * -1
                    }
                }
                
                let TextNode = CATextLayer()
                let (AText, Width, Height) = MakeHourText(Hour: DisplayHour,
                                                          Font: UIFont.boldSystemFont(ofSize: 36.0),
                                                          Color: UIColor.yellow,
                                                          StrokeColor: UIColor.black,
                                                          StrokeThickness: -2,
                                                          IncludeSign: IncludeSign)
                TextNode.string = AText
                let X = CGFloat(Radius) * cos(Radial) + CGFloat(Radius - Width / 2)
                let Y = CGFloat(Radius) * sin(Radial) + CGFloat(Radius - Height / 2)
                TextNode.font = UIFont.systemFont(ofSize: 36.0)
                TextNode.fontSize = 36.0
                TextNode.alignmentMode = .center
                TextNode.foregroundColor = UIColor.yellow.cgColor
                TextNode.frame = CGRect(x: X, y: Y, width: Width, height: Height)
                TextNode.bounds = CGRect(x: 0, y: 0, width: Width, height: Height)
                let TextRotate = ((90.0 - Angle) + 180.0).Radians
                TextNode.transform = CATransform3DRotate(TextNode.transform, -TextRotate, 0.0, 0.0, 1.0)
                TextLayer.addSublayer(TextNode)
            }
            HourLayer2D.layer.addSublayer(TextLayer)
        }
        else
        {
            HourLayer2D.isHidden = true
            HourLayer2D.layer.sublayers?.removeAll()
        }
    }
    
    func MakeHourText(Hour: Int, Font: UIFont, Color: UIColor, StrokeColor: UIColor,
                      StrokeThickness: CGFloat, IncludeSign: Bool) -> (NSAttributedString, CGFloat, CGFloat)
    {
        var Sign = ""
        if IncludeSign
        {
            if Hour > 0
            {
                Sign = "+"
            }
        }
        let TextValue = "\(Sign)\(Hour)"
        let Attributes: [NSAttributedString.Key: Any] =
            [.font: Font as Any,
             .foregroundColor: Color.cgColor as Any,
             .strokeColor: StrokeColor.cgColor as Any,
             .strokeWidth: StrokeThickness as Any]
        let Final = NSAttributedString(string: TextValue, attributes: Attributes)
        let Size = TextValue.size(withAttributes: Attributes)
        return (Final, Size.width, Size.height)
    }
    
    @objc func UpdateLocalData()
    {
        if !Settings.GetShowLocalData()
        {
            DataStack.isHidden = true
            return
        }
        DataStack.isHidden = false
        let Now = Date()
        let Cal = Calendar.current
        let Hour = Cal.component(.hour, from: Now)
        let Minute = Cal.component(.minute, from: Now)
        let Second = Cal.component(.second, from: Now)
        let Total = Second + (Minute * 60) + (Hour * 60 * 60)
        let FinalTotal = "\(Total)"
        LocalSecondsLabel.text = FinalTotal
        let LocalLat = Settings.GetLocalLatitude()
        let LocalLon = Settings.GetLocalLongitude()
        var RiseAndSetAvailable = true
        var SunRiseTime = Date()
        var SunSetTime = Date()
        if LocalLat == nil || LocalLon == nil
        {
            RiseAndSetAvailable = false
            LocalSunsetLabel.text = "N/A"
            LocalSunriseLabel.text = "N/A"
        }
        else
        {
            let Location = GeoPoint2(LocalLat!, LocalLon!)
            let SunTimes = Sun()
            if let SunriseTime = SunTimes.Sunrise(For: Date(), At: Location,
                                                  TimeZoneOffset: 0)
            {
                SunRiseTime = SunriseTime
                LocalSunriseLabel.text = SunriseTime.PrettyTime()
            }
            else
            {
                RiseAndSetAvailable = false
                LocalSunriseLabel.text = "No sunrise"
            }
            if let SunsetTime = SunTimes.Sunset(For: Date(), At: Location,
                                                TimeZoneOffset: 0)
            {
                SunSetTime = SunsetTime
                LocalSunsetLabel.text = SunsetTime.PrettyTime()
            }
            else
            {
                RiseAndSetAvailable = false
                LocalSunsetLabel.text = "No sunset"
            }
        }
        let Declination = Sun.Declination(For: Date())
        DeclinitionLabel.text = "\(Declination.RoundedTo(3))°"
        if RiseAndSetAvailable
        {
            let RiseHour = Cal.component(.hour, from: SunRiseTime)
            let RiseMinute = Cal.component(.minute, from: SunRiseTime)
            let RiseSecond = Cal.component(.second, from: SunRiseTime)
            let SetHour = Cal.component(.hour, from: SunSetTime)
            let SetMinute = Cal.component(.minute, from: SunSetTime)
            let SetSecond = Cal.component(.second, from: SunSetTime)
            let RiseSeconds = RiseSecond + (RiseMinute * 60) + (RiseHour * 60 * 60)
            let SetSeconds = SetSecond + (SetMinute * 60) + (SetHour * 60 * 60)
            let SecondDelta = SetSeconds - RiseSeconds
            let NoonTime = RiseSeconds + (SecondDelta / 2)
            let (NoonHour, NoonMinute, NoonSecond) = Date.SecondsToTime(NoonTime)
            let HourS = "\(NoonHour)"
            let MinuteS = (NoonMinute < 10 ? "0" : "") + "\(NoonMinute)"
            let SecondS = (NoonSecond < 10 ? "0" : "") + "\(NoonSecond)"
            SolarNoonLabel.text = "\(HourS):\(MinuteS):\(SecondS)"
        }
        else
        {
            print("Missing sunrise and/or sunset time.")
        }
    }
    
    @objc func UpdateDaylight()
    {
        let DQ = DispatchQueue(label: "SunlightQueue", qos: .utility)
        DQ.async
            {
                self.MakeLatitudeBands()
        }
    }
    
    func MakeLatitudeBands()
    {
        let Time = Date()
        //print("Latitude time: \(Time)")
        for Lat in -90 ..< 90
        {
            let Location = GeoPoint2(42.9584, 141.5630)
            let SolarLibrary = Sun(Location: Location, Offset: 9)
            let Sunrise = SolarLibrary.Sunrise(For: Time, At: Location, TimeZoneOffset: 0)
            if Sunrise == nil
            {
                print("No sunrise for location on this date")
            }
            let Sunset = SolarLibrary.Sunset(For: Time, At: Location, TimeZoneOffset: 0)
            if Sunset == nil
            {
                print("No sunset for location on this date")
            }
            if let (Rise, Set) = SolarLibrary.SunPercents(Sunrise: Sunrise, Sunset: Sunset)
            {
                //print("At \(Location), Rise%=\(Rise), Set%=\(Set)")
            }
        }
    }
    
    let DaylightGridSize = 1.3
    
    func GetSunlightPoints()
    {
        LightList.removeAll()
        for Lon in stride(from: -179, to: 180, by: DaylightGridSize)
        {
            for Lat in stride(from: -90, to: 90, by: DaylightGridSize)
            {
                let Location = GeoPoint2(Double(Lat), Double(Lon))
                let SunVisible = Solar.CalculateSunVisibility(Where: Location)
                LightList.append((Latitude: Double(Lat), Longitude: Double(Lon), SunVisible: SunVisible))
            }
        }
    }
    
    var LightList = [(Latitude: Double, Longitude: Double, SunVisible: Bool)]()
    
    var SunlightTimer: Timer? = nil
    
    var CityTestList = [City]()
    let CityList = Cities()
    var BottomSun: SunGenerator? = SunGenerator()
    var TopSun: SunGenerator? = SunGenerator()
    
    /// Get the original locations of the sun and time labels. Initialize the program based on
    /// user settings.
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        OriginalTimeFrame = MainTimeLabelBottom.frame
        OriginalSunFrame = SunViewTop.frame
    }
    
    ///  Original location of the time label.
    var OriginalTimeFrame: CGRect = CGRect.zero
    /// Original location of the sun image.
    var OriginalSunFrame: CGRect = CGRect.zero
    
    func ForceTime(NewTime: Date, WithOffset: Int)
    {
        print("Force stop at \(NewTime.PrettyTime()), WithOffset: \(WithOffset)")
        
        UseFrozenTime = true
        FrozenTime = NewTime
    }
    
    /// Called when the user closes the settings view controller, and when the program first starts.
    func SettingsDone()
    {
        if !Settings.GetShowHourLabels()
        {
            HourSegment.selectedSegmentIndex = 0
        }
        else
        {
            switch Settings.GetHourValueType()
            {
                case .Solar:
                    HourSegment.selectedSegmentIndex = 1
                
                case .RelativeToNoon:
                    HourSegment.selectedSegmentIndex = 2
                
                case .RelativeToLocation:
                    HourSegment.selectedSegmentIndex = 3
            }
        }
        if GridOverlay.layer.sublayers != nil
        {
            for Layer in GridOverlay.layer.sublayers!
            {
                if Layer.name == "ViewGrid"
                {
                    Layer.removeFromSuperlayer()
                }
                if Layer.name == "PrimeMeridian"
                {
                    Layer.removeFromSuperlayer()
                }
            }
        }
        UpdateSunLocations()
        WorldViewer3D.UpdateSurfaceTransparency()
        WorldViewer3D.UpdateHourLabels()
        
        Show2DHours()
        
        let CenterPole = Settings.GetImageCenter()
        var ProvisionalImage = UIImage()
        ProvisionalImage = MapManager.ImageFor(MapType: Settings.GetFlatlandMapType(), ViewType: .FlatMap, ImageCenter: CenterPole)!
        WorldViewer.image = ProvisionalImage
        
        PreviousPercent = -1.0
        StartTimeLabel()
        if Settings.GetViewType() == .Globe3D
        {
            if Settings.ShowStars()
            {
                StarFieldView.Show()
            }
            else
            {
                StarFieldView.Hide()
            }
        }
    }
    
    var InitialSunPrint: UUID? = nil
    
    /// Update the location of the sun. The sun can be on top or on the bottom and swaps places
    /// with the time label.
    func UpdateSunLocations()
    {
        if Settings.GetImageCenter() == .NorthPole
        {
            SunViewTop.isHidden = true
            SunViewBottom.isHidden = false
            if Settings.GetTimeLabel() == .None
            {
                MainTimeLabelTop.isHidden = true
                MainTimeLabelBottom.isHidden = true
            }
            else
            {
                MainTimeLabelTop.isHidden = false
                MainTimeLabelBottom.isHidden = true
            }
        }
        else
        {
            SunViewTop.isHidden = false
            SunViewBottom.isHidden = true
            if Settings.GetTimeLabel() == .None
            {
                MainTimeLabelTop.isHidden = true
                MainTimeLabelBottom.isHidden = true
            }
            else
            {
                MainTimeLabelBottom.isHidden = false
                MainTimeLabelTop.isHidden = true
            }
        }
    }
    
    /// Runs a recurrent timer to update the display once a second.
    func StartTimeLabel()
    {
        TimeTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target: self,
                                         selector: #selector(TimeUpdater),
                                         userInfo: nil,
                                         repeats: true)
        TimeUpdater()
    }
    
    /// Returns the local time zone abbreviation (a three-letter indicator, not a set of words).
    /// - Returns: The local time zone identifier if found, nil if not found.
    func GetLocalTimeZoneID() -> String?
    {
        let TZID = TimeZone.current.identifier
        for (Abbreviation, Wordy) in TimeZone.abbreviationDictionary
        {
            if Wordy == TZID
            {
                return Abbreviation
            }
        }
        return nil
    }
    
    var UseFrozenTime: Bool = false
    var IsFrozen: Bool = false
    var FrozenTime: Date = Date()
    
    /// Updates the current time (which may or may not be visible given user settings) as well as
    /// rotates the Earth image to keep it aligned with the sun.
    @objc func TimeUpdater()
    {
        if IsFrozen
        {
            return
        }
        UpdateSunLocations()
        var Now: Date = Date()
        if UseFrozenTime
        {
            Now = FrozenTime
        }
        else
        {
            Now = GetUTC()
        }
        let Formatter = DateFormatter()
        Formatter.dateFormat = "HH:mm:ss"
        var TimeZoneAbbreviation = ""
        if Settings.GetTimeLabel() == .UTC
        {
            TimeZoneAbbreviation = "UTC"
        }
        else
        {
            TimeZoneAbbreviation = GetLocalTimeZoneID() ?? "UTC"
        }
        let TZ = TimeZone(abbreviation: TimeZoneAbbreviation)
        Formatter.timeZone = TZ
        let Final = Formatter.string(from: Now)
        let FinalText = Final + " " + TimeZoneAbbreviation
        MainTimeLabelBottom.text = FinalText
        MainTimeLabelTop.text = FinalText
        var Cal = Calendar(identifier: .gregorian)
        Cal.timeZone = TZ!
        let Hour = Cal.component(.hour, from: Now)
        let Minute = Cal.component(.minute, from: Now)
        let Second = Cal.component(.second, from: Now)
        let ElapsedSeconds = Second + (Minute * 60) + (Hour * 60 * 60)
        let Percent = Double(ElapsedSeconds) / Double(SecondsInDay)
        let PrettyPercent = Double(Int(Percent * 1000.0)) / 1000.0
        CurrentWorldRotationalValue = PrettyPercent
        let CurrentSeconds = Now.timeIntervalSince1970
        if CurrentSeconds != OldSeconds
        {
            let ND = (GetUTCNoon().timeIntervalSinceReferenceDate - GetUTC().timeIntervalSinceReferenceDate) / (60 * 60)
            //print("ND=\(Int(ND))")
            let IND = Int(ND) + 1
            if let NDInfo = TimeZoneTable.GetTimeZoneInfo(For: Double(IND))
            {
                let NDI = NDInfo.first!
                // print("Noon time zone \(NDI.Name)")
                var TZOffsetSign = ""
                if IND < 0
                {
                    TZOffsetSign = "-"
                }
                if IND > 0
                {
                    TZOffsetSign = "+"
                }
                NoonTimezoneLabel.text = NDI.Abbreviation + " \(TZOffsetSign)\(IND)"
            }
            var NoonTime = Date.DateFrom(Percent: PrettyPercent)
            var NTS = NoonTime.AsSeconds()
            let (NH, HM, NS) = Date.SecondsToTime(NTS)
            let PPAngle = 360.0 * PrettyPercent
            let PPAngleH = PPAngle / 15.0
            // print("NTS Hour=\(NH), Minute=\(HM), Second=\(NS), \(PrettyPercent)%, Angle=\(PPAngle)°, \(PPAngleH)")
            let NTSm = NTS % 3600
            NTS = NTS - NTSm
            //   print("NTS=\(NTS)")
            let NTZ = TimeZone(secondsFromGMT: NTS)
            //  print("NTZ=\((NTZ)!), \(NTZ!.abbreviation())")
            if let NTZInfo = TimeZoneTable.GetTimeZoneInfo(For: Double(NTS / 3600))
            {
                let TZI = NTZInfo.first!
                //      print("TZI=\(TZI.Name)")
            }
            var NoonDelta = NoonTime.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate
            NoonDelta = NoonDelta / 3600
            NoonDelta.round()
            let NDTZ = NoonTime.GetTimeZone()
            //print("Noon delta: \(NoonDelta) \(NoonTime.PrettyTime()) \(PrettyPercent)% TZ: \(NDTZ)")
            OldSeconds = CurrentSeconds
            //print("Flatland pretty percent=\(PrettyPercent)")
            RotateImageTo(PrettyPercent)
            let DaySeconds = (Hour * 60 * 60) + (Minute * 60) + Second
            let NST = NSTimeZone()
            let NowDate = Date()
            #if false
            var D2 = NowDate.ToLocal().timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate
            D2 = D2 / 3600.0
            D2.round()
            if let TZInfo = TimeZoneTable.GetTimeZoneInfo(For: D2)
            {
                let Abbr = TZInfo.first!
                print("\(Abbr.Abbreviation)")
            }
            let Delta = NST.secondsFromGMT(for: Date())
            print("\(FinalText) [\(DaySeconds)] = \(PrettyPercent), [\(Delta)]")
            #endif
        }
        #if true
        if CityTestList.count > 0
        {
            if SingleTask.NotCompleted(&TestCities)
            {
                let FinalOffset = Settings.GetSunLocation() == .Bottom ? 0.0 : OriginalOrientation
                let Radial = MakeRadialTime(From: PrettyPercent, With: FinalOffset)
                PlotCities(InCityList: CityTestList, RadialTime: Radial, CityListChanged: false)
            }
        }
        #endif
        if UseFrozenTime
        {
            IsFrozen = true
        }
    }
    
    var CurrentWorldRotationalValue: Double = -1.0
    
    var OldSeconds: Double = 0.0
    
    var TestCities: UUID? = nil
    
    let SecondsInDay: Int = 60 * 60 * 24
    
    func GetUTC() -> Date
    {
        return Date()
    }
    
    func GetUTCNoon() -> Date
    {
        let Now = GetUTC()
        var Cal = Calendar(identifier: .gregorian)
        Cal.timeZone = TimeZone(identifier: "UTC")!
        var Components = DateComponents()
        Components.hour = 12
        Components.minute = 0
        Components.second = 0
        Components.year = Cal.component(.year, from: Now)
        Components.month = Cal.component(.month, from: Now)
        Components.day = Cal.component(.day, from: Now)
        return Cal.date(from: Components)!
    }
    
    var TimeTimer: Timer! = nil
    
    func MakeRadialTime(From Percent: Double, With Offset: Double) -> Double
    {
        let Degrees = 360.0 * Percent - Offset
        return Degrees * Double.pi / 180.0
    }
    
    /// Rotates the Earth image to the passed number of degrees where Greenwich England is 0°.
    /// - Parameter Percent: Percent of the day, eg, if 0.25 is passed, it is 6:00 AM. This value
    ///                      should be normalized.
    func RotateImageTo(_ Percent: Double)
    {
        //if PreviousPercent == Percent
        //{
        //    return
        //}
        PreviousPercent = Percent
        let FinalOffset = Settings.GetImageCenter() == .NorthPole ? 0.0 : 180.0
        //Be sure to rotate the proper direction based on the map.
        let Multiplier = Settings.GetImageCenter() == .NorthPole ? 1.0 : -1.0
        let Radians = MakeRadialTime(From: Percent, With: FinalOffset) * Multiplier
        let Rotation = CATransform3DMakeRotation(CGFloat(-Radians), 0.0, 0.0, 1.0)
        WorldViewer.layer.transform = Rotation
        if Settings.GetHourValueType() == .RelativeToLocation
        {
            HourLayer2D.layer.transform = Rotation
        }
        if Settings.ShowGrid()
        {
            DrawGrid(Radians)
        }
        if Settings.ShowCities()
        {
            PlotCities(InCityList: CityTestList, RadialTime: Radians, CityListChanged: true)
        }
    }
    
    var PreviousImage: String = "WorldNorth"
    /// Previous percent drawn. Used to prevent constant updates when an update would not result
    /// in a visual change.
    var PreviousPercent: Double = -1.0
    
    func PlotCities(InCityList: [City], RadialTime: Double, CityListChanged: Bool = false)
    {
        #if false
        if CityListChanged
        {
            HideCities()
        }
        else
        {
            if let Layer = CityLayer
            {
                //rotate the existing layer here
                return
            }
        }
        #endif
        if CityLayer == nil
        {
            CityLayer = CAShapeLayer()
            CityLayer?.backgroundColor = UIColor.clear.cgColor
            CityLayer?.zPosition = 10000
            CityLayer?.name = "City Layer"
            CityLayer?.bounds = WorldViewer.bounds
            CityLayer?.frame = WorldViewer.bounds
            GridOverlay.layer.addSublayer(CityLayer!)
        }
        let Bezier = UIBezierPath()
        for SomeCity in InCityList
        {
            let CityPath = PlotCity(SomeCity, Diameter: (CityLayer?.bounds.width)!)
            Bezier.append(CityPath)
        }
        if Settings.ShowUserLocations()
        {
            if CityLayer?.sublayers != nil
            {
                for SomeLayer in CityLayer!.sublayers!
                {
                    if SomeLayer.name == "User Location"
                    {
                        SomeLayer.removeFromSuperlayer()
                    }
                }
            }
            let UserLocations = Settings.GetLocations()
            for (_, Location, Name, Color) in UserLocations
            {
                let LocationLayer = PlotLocation2(Location, Name, Color, (CityLayer?.bounds.width)!)
                LocationLayer.name = "User Location"
                CityLayer?.addSublayer(LocationLayer)
            }
        }
        CityLayer?.fillColor = UIColor.red.cgColor
        CityLayer?.strokeColor = UIColor.black.cgColor
        CityLayer?.lineWidth = 1.0
        CityLayer?.path = Bezier.cgPath
        let Rotation = CATransform3DMakeRotation(CGFloat(-RadialTime), 0.0, 0.0, 1.0)
        CityLayer?.transform = Rotation
    }
    
    let HalfCircumference: Double = 40075.0 / 2.0
    
    func PlotCity(_ PlotMe: City, Diameter: CGFloat) -> UIBezierPath
    {
        let Latitude = PlotMe.Latitude
        let Longitude = PlotMe.Longitude
        let Half = Double(Diameter / 2.0)
        let Ratio: Double = Half / HalfCircumference
        let CitySize: CGFloat = 10.0
        let CityDotSize = CGSize(width: CitySize, height: CitySize)
        let PointModifier = Double(CGFloat(Half) - (CitySize / 2.0))
        let LongitudeAdjustment = Settings.GetImageCenter() == .NorthPole ? 1.0 : -1.0
        var Distance = DistanceFromContextPole(To: GeoPoint2(Latitude, Longitude))
        Distance = Distance * Ratio
        var CityBearing = Bearing(Start: GeoPoint2(90.0, 0.0), End: GeoPoint2(Latitude, Longitude * LongitudeAdjustment))
        CityBearing = (CityBearing + 90.0).ToRadians()
        let PointX = Distance * cos(CityBearing) + PointModifier
        let PointY = Distance * sin(CityBearing) + PointModifier
        let Origin = CGPoint(x: PointX, y: PointY)
        let City = UIBezierPath(ovalIn: CGRect(origin: Origin, size: CityDotSize))
        return City
    }
    
    func PlotLocation2(_ Location: GeoPoint2, _ Name: String, _ Color: UIColor, _ Diameter: CGFloat) -> CAShapeLayer
    {
        let Latitude = Location.Latitude
        let Longitude = Location.Longitude
        let Half = Double(Diameter / 2.0)
        let Ratio: Double = Half / HalfCircumference
        let LocationSize: CGFloat = 10.0
        let LocationDotSize = CGSize(width: LocationSize, height: LocationSize)
        let PointModifier = Double(CGFloat(Half) - (LocationSize / 2.0))
        let LongitudeAdjustment = Settings.GetImageCenter() == .NorthPole ? 1.0 : -1.0
        var Distance = DistanceFromContextPole(To: GeoPoint2(Latitude, Longitude))
        Distance = Distance * Ratio
        var LocationBearing = Bearing(Start: GeoPoint2(90.0, 0.0), End: GeoPoint2(Latitude, Longitude * LongitudeAdjustment))
        LocationBearing = (LocationBearing + 90.0).ToRadians()
        let PointX = Distance * cos(LocationBearing) + PointModifier
        let PointY = Distance * sin(LocationBearing) + PointModifier
        let Origin = CGPoint(x: PointX, y: PointY)
        let Location = UIBezierPath(rect: CGRect(origin: Origin, size: LocationDotSize))
        let Layer = CAShapeLayer()
        Layer.frame = WorldViewer.bounds
        Layer.bounds = WorldViewer.bounds
        Layer.backgroundColor = UIColor.clear.cgColor
        Layer.fillColor = Color.cgColor
        Layer.strokeColor = UIColor.black.cgColor
        Layer.lineWidth = 1.0
        Layer.path = Location.cgPath
        return Layer
    }
    
    /// Calculate the bearing between two geographic points on the Earth using the forward azimuth formula (great circle).
    /// - Parameters:
    ///   - Start: Starting point.
    ///   - End: Destination point.
    /// - Returns: Bearing from the Start point to the End point. (Bearing will change over the arc.)
    public func Bearing(Start: GeoPoint2, End: GeoPoint2) -> Double
    {
        let StartLat = Start.Latitude.ToRadians()
        let StartLon = Start.Longitude.ToRadians()
        let EndLat = End.Latitude.ToRadians()
        let EndLon = End.Longitude.ToRadians()
        
        if cos(EndLat) * sin(EndLon - StartLon) == 0
        {
            if EndLat > StartLat
            {
                return 0
            }
            else
            {
                return 180
            }
        }
        var Angle = atan2(cos(EndLat) * sin(EndLon - StartLon),
                          sin(EndLat) * cos(StartLat) - sin(StartLat) * cos(EndLat) * cos(EndLon - StartLon))
        Angle = Angle.ToDegrees()
        Angle = Angle * 1000.0
        let IAngle = Int(Angle)
        Angle = Double(IAngle) / 1000.0
        return Angle
    }
    
    /// Implementation of the Spherical Law of Cosines. Used to calculate a distance between two
    /// points on a sphere, in our case, the surface of the Earth.
    /// - Parameter Point1: First location.
    /// - Parameter Point2: Second location.
    /// - Returns: Distance from `Point1` to `Point2` in kilometers.
    func LawOfCosines(Point1: GeoPoint2, Point2: GeoPoint2) -> Double
    {
        let Term1 = sin(Point1.Latitude.ToRadians()) * sin(Point2.Latitude.ToRadians())
        let Term2 = cos(Point1.Latitude.ToRadians()) * cos(Point2.Latitude.ToRadians())
        let Term3 = cos(Point2.Longitude.ToRadians() - Point1.Longitude.ToRadians())
        var V = acos(Term1 + (Term2 * Term3))
        V = V * 6367.4447
        return V
    }
    
    /// Returns the distance from the passed location to the North Pole.
    /// - Returns: Distance (in kilometers) from `To` to the North Pole.
    func DistanceFromNorthPole(To: GeoPoint2) -> Double
    {
        return LawOfCosines(Point1: GeoPoint2(90.0, 0.0), Point2: To)
    }
    
    /// Returns the distance from the passed location to the South Pole.
    /// - Returns: Distance (in kilometers) from `To` to the South Pole.
    func DistanceFromSouthPole(To: GeoPoint2) -> Double
    {
        return LawOfCosines(Point1: GeoPoint2(-90.0, 0.0), Point2: To)
    }
    
    /// Returns the distance from the passed location to the pole that is at the center of the image.
    /// - Parameter To: The point whose distance to the pole at the center of the image is returned.
    /// - Returns: The distance (in kilometers) from `To` to the pole at the center of the image.
    func DistanceFromContextPole(To: GeoPoint2) -> Double
    {
        if Settings.GetImageCenter() == .NorthPole
        {
            return DistanceFromNorthPole(To: To)
        }
        else
        {
            return DistanceFromSouthPole(To: To)
        }
    }
    
    func PrettyPoint(_ Point: CGPoint) -> String
    {
        let X = Double(Point.x).RoundedTo(3)
        let Y = Double(Point.y).RoundedTo(3)
        return "(\(X),\(Y))"
    }
    
    /// Converts polar coordintes into Cartesian coordinates, optionally adding an offset value.
    /// - Parameter Theta: The angle of the polar coordinate.
    /// - Parameter Radius: The radial value of the polar coordinate.
    /// - Parameter HOffset: Value added to the returned `x` value. Defaults to 0.0.
    /// - Parameter VOffset: Value added to the returned `y` value. Defaults to 0.0.
    /// - Returns: `CGPoint` with the converted polar coorindate.
    func PolarToCartesian(Theta: Double, Radius: Double, HOffset: Double = 0.0, VOffset: Double = 0.0) -> CGPoint
    {
        let Radial = Theta * Double.pi / 180.0
        let X = Radius * cos(Radial) + HOffset
        let Y = Radius * sin(Radial) + VOffset
        return CGPoint(x: X, y: Y)
    }
    
    func HideCities()
    {
        if CityLayer != nil
        {
            CityLayer?.removeFromSuperlayer()
            CityLayer = nil
        }
    }
    
    var CityLayer: CAShapeLayer? = nil
    
    func StopTimers()
    {
        TimeTimer.invalidate()
        SunlightTimer?.invalidate()
        LocalDataTimer?.invalidate()
    }
    
    func GetCities() -> [City]
    {
        return CityTestList
    }
    
    @IBAction func HandleViewTypeChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            switch Segment.selectedSegmentIndex
            {
                case 0:
                    Settings.SetImageCenter(.NorthPole)
                    Settings.SetViewType(.FlatMap)
                    WorldViewer3D.Hide()
                    StarFieldView.Hide()
                    SetFlatlandVisibility(IsVisible: true)
                SettingsDone()
                
                case 1:
                    Settings.SetImageCenter(.SouthPole)
                    Settings.SetViewType(.FlatMap)
                    WorldViewer3D.Hide()
                    StarFieldView.Hide()
                    SetFlatlandVisibility(IsVisible: true)
                SettingsDone()
                
                case 2:
                    Settings.SetViewType(.Globe3D)
                    WorldViewer3D.Show()
                    if Settings.ShowStars()
                    {
                        StarFieldView.Show()
                    }
                    SetFlatlandVisibility(IsVisible: false)
                    PleaseWait
                        {
                        WorldViewer3D.AddEarth()
                    }
                
                default:
                    break
            }
        }
    }
    
    /// Instantiate the settings controller.
    @IBSegueAction func InstantiateSettingsNavigator(_ coder: NSCoder) -> SettingsNavigationViewer?
    {
        let Controller = SettingsNavigationViewer(coder: coder)
        Controller?.Delegate = self
        return Controller
    }
    
    @IBSegueAction func InstantiateDebugNavigator(_ coder: NSCoder) -> DebugNavigationViewer?
    {
        let Controller = DebugNavigationViewer(coder: coder)
        Controller?.Delegate = self
        return Controller
    }
    
    func PleaseWait(_ Status: ViewStatuses)
    {
        switch Status
        {
            case .Hide:
                UIView.animate(withDuration: 0.5,
                               animations:
                    {
                        self.PleaseWaitDialog.alpha = 0.0
                }, completion:
                    {
                        Completed in
                        if Completed
                        {
                            self.PleaseWaitDialog.isHidden = true
                        }
                })
            
            case .Show:
                PleaseWaitDialog.alpha = 0.0
                PleaseWaitDialog.isHidden = false
                UIView.animate(withDuration: 0.2,
                               animations:
                    {
                        self.PleaseWaitDialog.alpha = 1.0
                })
        }
    }
    
    func PleaseWait(For Action: () -> ())
    {
        PleaseWait(.Show)
        Action()
        PleaseWait(.Hide)
    }
    
    func ChangeMap()
    {
        PleaseWait
            {
            WorldViewer3D.AddEarth()
        }
        SettingsDone()
    }
    
    func AlphaChanged()
    {
        WorldViewer3D.UpdateSurfaceTransparency()
    }
    
    func FreezeTime(_ IsFrozen: Bool)
    {
        if IsFrozen
        {
            DecoupleClocks()
        }
    }
    
    func SetTimeMultiplier(_ Multiplier: Double)
    {
        print("Time muliplier = \(Multiplier)")
        if Multiplier > 1.0
        {
            WorldViewer3D.SetClockMultiplier(Multiplier)
        }
    }
    
    func DecoupleClocks()
    {
        
    }
    
    func SetTexture(_ MapType: MapTypes)
    {
        print("User selected \"\(MapType.rawValue)\" map.")
        Settings.SetFlatlandMapType(MapType)
        Settings.SetGlobeMapType(MapType)
        ChangeMap()
    }
    
    @IBAction func HandleHourSegmentChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            switch Segment.selectedSegmentIndex
            {
                case 0:
                    Settings.SetShowHourLabels(false)
                    SettingsDone()
                    WorldViewer3D.UpdateHourLabels()
                
                case 1:
                    Settings.SetShowHourLabels(true)
                    Settings.SetHourValueType(.Solar)
                    SettingsDone()
                    WorldViewer3D.UpdateHourLabels()
                
                case 2:
                    Settings.SetShowHourLabels(true)
                    Settings.SetHourValueType(.RelativeToNoon)
                    SettingsDone()
                    WorldViewer3D.UpdateHourLabels()
                
                case 3:
                    Settings.SetShowHourLabels(true)
                    Settings.SetHourValueType(.RelativeToLocation)
                    SettingsDone()
                    WorldViewer3D.UpdateHourLabels()
                
                default:
                return
            }
        }
    }
    
    // MARK: - Interface builder outlets.
    
    @IBOutlet weak var PleaseWaitDialog: UIView!
    @IBOutlet weak var HourSegment: UISegmentedControl!
    @IBOutlet weak var HourLayer2D: UIView!
    @IBOutlet weak var StarFieldView: Starfield!
    @IBOutlet weak var ViewTypeSegment: UISegmentedControl!
    @IBOutlet weak var WorldViewer3D: GlobeView!
    @IBOutlet weak var LocalSunsetLabel: UILabel!
    @IBOutlet weak var LocalSunriseLabel: UILabel!
    @IBOutlet weak var LocalSecondsLabel: UILabel!
    @IBOutlet weak var NoonTimezoneLabel: UILabel!
    @IBOutlet weak var DataStack: UIStackView!
    @IBOutlet weak var ArcLayer: UIView!
    @IBOutlet weak var SettingsButton: UIButton!
    @IBOutlet weak var GridOverlay: UIView!
    @IBOutlet weak var SunViewTop: UIImageView!
    @IBOutlet weak var SunViewBottom: UIImageView!
    @IBOutlet weak var MainTimeLabelBottom: UILabel!
    @IBOutlet weak var MainTimeLabelTop: UILabel!
    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var WorldViewer: UIImageView!
    @IBOutlet weak var SolarNoonLabel: UILabel!
    @IBOutlet weak var DeclinitionLabel: UILabel!
}

enum ViewStatuses
{
    case Show
    case Hide
}
