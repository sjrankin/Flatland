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
        ArcLayer.layer.zPosition = 50000
        TopView.backgroundColor = UIColor.black
        SettingsDone()
        TopSun?.VariableSunImage(Using: SunViewTop, Interval: 0.1)
        BottomSun?.VariableSunImage(Using: SunViewBottom, Interval: 0.1)
        CityTestList = CityList.TopNCities(N: 50, UseMetroPopulation: true)
        
        MakeLatitudeBands()
        let Radius = ArcLayer.bounds.width / 2.0
        let Center = CGPoint(x: Radius, y: Radius)
        #if false
        var Start: CGFloat = -90
        let LatitudeIncrement = 5
        let ArcIncrement = abs(Start / CGFloat(LatitudeIncrement))
        print("ArcIncrement=\(ArcIncrement)")
        for Lat in stride(from: -180, to: 180, by: LatitudeIncrement)
        {
            let ArcColor = Lat == -180 ? UIColor.red : UIColor.Random(MinRed: 0.3, MinGreen: 0.3, MinBlue: 0.3)
            let End = -Start
            let LatPercent = CGFloat(abs(Double(Lat)) + 180.0) / 360.0
            let test = MakeArc(Start: -90.0 * LatPercent,
                               End: 90.0 * LatPercent,
                               Radius: Radius,
                               ArcRadius: CGFloat(Lat + 180),
                               ArcWidth: CGFloat(LatitudeIncrement),
                               Center: Center,
                               ArcColor: UIColor.black,//ArcColor,
                               Rectangle: ArcLayer.bounds)
            ArcLayer.layer.addSublayer(test)
            Start = Start + ArcIncrement
        }
 
// ArcLayer.layer.addSublayer(test)
        #endif
        LocalDataTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                              target: self,
                                              selector: #selector(UpdateLocalData),
                                              userInfo: nil,
                                              repeats: true)
        
        let ContextMenu = UIContextMenuInteraction(delegate: self)
        TopView.addInteraction(ContextMenu)
        
        let Rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        Rotation.delegate = self
        Rotation.fromValue = NSNumber(floatLiteral: 0.0)
        Rotation.toValue = NSNumber(floatLiteral: Double(CGFloat.pi * 2.0))
        Rotation.duration = 30.0
        Rotation.repeatCount = Float.greatestFiniteMagnitude
        Rotation.isAdditive = true
        SettingsButton.layer.add(Rotation, forKey: "RotateMe")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    var LocalDataTimer: Timer? = nil
    
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
    
    let DaylightGridSize = 1.3
    
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
            switch Settings.GetHourValueType()
            {
                case .None:
                    HourSegment.selectedSegmentIndex = 0
                
                case .Solar:
                    HourSegment.selectedSegmentIndex = 1
                
                case .RelativeToNoon:
                    HourSegment.selectedSegmentIndex = 2
                
                case .RelativeToLocation:
                    HourSegment.selectedSegmentIndex = 3
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
        WorldViewer3D.UpdateHourLabels(With: Settings.GetHourValueType())
        
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
    
    var PreviousImage: String = "WorldNorth"
    /// Previous percent drawn. Used to prevent constant updates when an update would not result
    /// in a visual change.
    var PreviousPercent: Double = -1.0
    
    let HalfCircumference: Double = 40075.0 / 2.0
    
    func PrettyPoint(_ Point: CGPoint) -> String
    {
        let X = Double(Point.x).RoundedTo(3)
        let Y = Double(Point.y).RoundedTo(3)
        return "(\(X),\(Y))"
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
    
    func HandleNewViewType(NewType: MapViewTypes)
    {
        switch NewType
        {
            case .NorthCentered:
                Settings.SetImageCenter(.NorthPole)
                Settings.SetViewType(.FlatMap)
                WorldViewer3D.Hide()
                StarFieldView.Hide()
                SetFlatlandVisibility(IsVisible: true)
                MakeLatitudeBands()
                SettingsDone()
            
            case .SouthCentered:
                Settings.SetImageCenter(.SouthPole)
                Settings.SetViewType(.FlatMap)
                WorldViewer3D.Hide()
                StarFieldView.Hide()
                SetFlatlandVisibility(IsVisible: true)
                MakeLatitudeBands()
                SettingsDone()
            
            case .Globe3D:
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
        }
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
                    MakeLatitudeBands()
                SettingsDone()
                
                case 1:
                    Settings.SetImageCenter(.SouthPole)
                    Settings.SetViewType(.FlatMap)
                    WorldViewer3D.Hide()
                    StarFieldView.Hide()
                    SetFlatlandVisibility(IsVisible: true)
                    MakeLatitudeBands()
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
    
    /// Change the map according to what the user set.
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
    
    func UpdateHourDisplay(With NewType: HourValueTypes)
    {
        Settings.SetHourValueType(NewType)
        SettingsDone()
        WorldViewer3D.UpdateHourLabels(With: NewType)
    }
    
    @IBAction func HandleHourSegmentChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            switch Segment.selectedSegmentIndex
            {
                case 0:
                    Settings.SetHourValueType(.None)
                    SettingsDone()
                    WorldViewer3D.UpdateHourLabels(With: .None)
                
                case 1:
                    Settings.SetHourValueType(.Solar)
                    SettingsDone()
                    WorldViewer3D.UpdateHourLabels(With: .Solar)
                
                case 2:
                    Settings.SetHourValueType(.RelativeToNoon)
                    SettingsDone()
                    WorldViewer3D.UpdateHourLabels(With: .RelativeToNoon)
                
                case 3:
                    Settings.SetHourValueType(.RelativeToLocation)
                    SettingsDone()
                    WorldViewer3D.UpdateHourLabels(With: .RelativeToLocation)
                
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

enum MapViewTypes
{
    case NorthCentered
    case SouthCentered
    case Globe3D
}
