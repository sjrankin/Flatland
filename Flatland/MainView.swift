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

class MainView: UIViewController, CAAnimationDelegate, SettingsProtocol, MainProtocol
{
    /// Original orientation of the image with Greenwich, England as the baseline. Since this program
    /// treats midnight as the base and the image has Greenwich at the top, we need an offset value
    /// to make sure the image is rotated correctly, depending on settings,
    let OriginalOrientation: Double = 180.0
    
    /// Initialize the UI.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Thread.current.name = "Main UI Thread"
        Settings.Initialize()
        FileIO.InitializeDirectory()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        NightMaskView.backgroundColor = UIColor.clear
        
        //Initialize the please wait dialog
        PleaseWaitDialog.isHidden = true
        PleaseWaitDialog.isUserInteractionEnabled = false
        PleaseWaitDialog.layer.borderColor = UIColor.systemBlue.cgColor
        
        if Settings.GetViewType() == .FlatMap
        {
            WorldViewer3D.Hide()
            StarFieldView.Hide()
            SetFlatlandVisibility(FlatIsVisible: true)
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
            SetFlatlandVisibility(FlatIsVisible: false)
            ViewTypeSegment.selectedSegmentIndex = 2
        }
        
        TopView.backgroundColor = UIColor.black
        SettingsDone()
        TopSun?.VariableSunImage(Using: SunViewTop, Interval: 0.1)
        BottomSun?.VariableSunImage(Using: SunViewBottom, Interval: 0.1)
        CityTestList = CityList.TopNCities(N: 50, UseMetroPopulation: true)
        SetNightMask()
        
        LocalDataTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                              target: self,
                                              selector: #selector(UpdateLocalData),
                                              userInfo: nil,
                                              repeats: true)
        //https://www.raywenderlich.com/113835-ios-timer-tutorial
        RunLoop.current.add(LocalDataTimer!, forMode: .common)
        LocalDataTimer?.tolerance = 0.1
        
        #if false
        let Rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        Rotation.delegate = self
        Rotation.fromValue = NSNumber(floatLiteral: 0.0)
        Rotation.toValue = NSNumber(floatLiteral: Double(CGFloat.pi * 2.0))
        Rotation.duration = 30.0
        Rotation.repeatCount = Float.greatestFiniteMagnitude
        Rotation.isAdditive = true
        SettingsButton.layer.add(Rotation, forKey: "RotateMe")
        #endif
        
        #if DEBUG
        MainDebugButton.isHidden = false
        MainDebugButton.isUserInteractionEnabled = true
        #else
        MainDebugButton.isHidden = true
        MainDebugButton.isUserInteractionEnabled = false
        #endif
        
        #if DEBUG
        ElapsedRuntime.isHidden = false
        ElapsedRuntime.font = UIFont.monospacedSystemFont(ofSize: 18.0, weight: .semibold)
        ElapsedRuntime.textColor = UIColor.white
        let ETimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(UpdateElapsedTime), userInfo: nil, repeats: true)
        RunLoop.current.add(ETimer, forMode: .common)
        ETimer.tolerance = 0.1
        #else
        ElapsedRuntime.isHidden = true
        #endif
        
        #if DEBUG
        TemperatureStatus.isHidden = false
        let TempTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(ThermalChecker), userInfo: nil, repeats: true)
        TempTimer.tolerance = 0.5
        #else
        TemperatureStatus.isHidden = true
        #endif
    }
    
    /// Checks the status of thermal pressure and displays an "icon" to let the user know how hot
    /// the device is without the user having to touch it.
    /// - Note: Intended for use only when the `#DEBUG` flag is true.
    @objc func ThermalChecker()
    {
        #if DEBUG
        switch ProcessInfo.processInfo.thermalState
        {
            case .nominal:
                TemperatureStatus.tintColor = UIColor.systemTeal
            
            case .fair:
                TemperatureStatus.tintColor = UIColor.systemBlue
            
            case .serious:
                TemperatureStatus.tintColor = UIColor.systemOrange
            
            case .critical:
                TemperatureStatus.tintColor = UIColor.red
                TemperatureStatus.layer.shadowColor = UIColor.yellow.cgColor
                TemperatureStatus.layer.shadowRadius = 10.0
                TemperatureStatus.layer.shadowOpacity = 1.0
                TemperatureStatus.layer.shadowOffset = CGSize.zero
                UIView.animate(withDuration: 1.5,
                               delay: 0.0,
                               options: [.autoreverse],
                               animations:
                    {
                        self.TemperatureStatus.layer.shadowColor = UIColor.systemPink.cgColor
                },
                               completion: nil)
            
            default:
                break
        }
        #endif
    }
    
    var ElapsedSeconds = 0
    
    @objc func UpdateElapsedTime()
    {
        ElapsedSeconds = ElapsedSeconds + 1
        let (Hours, Minutes, Seconds) = Date.SecondsToTime(ElapsedSeconds)
        let FinalHours = Hours > 0 ? "\(Hours):" : ""
        let FinalSeconds = Seconds < 10 ? "0\(Seconds)" : "\(Seconds)"
        let FinalMinutes = Minutes < 10 ? "0\(Minutes)" : "\(Minutes)"
        ElapsedRuntime.text = "\(FinalHours)\(FinalMinutes):\(FinalSeconds)"
    }
    
    /// Given the darkness of the app, have the status bar in a lighter color.
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
        print("Getting map image")
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
    
    /// Convert a point into a pretty string.
    /// - Parameter Point: The point to convert.
    /// - Returns: String equivalent of the passed point.
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
    
    /// Changes the view type.
    /// - Parameter NewType: The new view type.
    func HandleNewViewType(NewType: MapViewTypes)
    {
        switch NewType
        {
            case .NorthCentered:
                Settings.SetImageCenter(.NorthPole)
                Settings.SetViewType(.FlatMap)
                WorldViewer3D.Hide()
                StarFieldView.Hide()
                SetFlatlandVisibility(FlatIsVisible: true)
                SetNightMask()
                SettingsDone()
            
            case .SouthCentered:
                Settings.SetImageCenter(.SouthPole)
                Settings.SetViewType(.FlatMap)
                WorldViewer3D.Hide()
                StarFieldView.Hide()
                SetFlatlandVisibility(FlatIsVisible: true)
                SetNightMask()
                SettingsDone()
            
            case .Globe3D:
                Settings.SetViewType(.Globe3D)
                WorldViewer3D.Show()
                if Settings.ShowStars()
                {
                    StarFieldView.Show()
                }
                SetFlatlandVisibility(FlatIsVisible: false)
                PleaseWait
                    {
                        WorldViewer3D.AddEarth()
            }
        }
    }
    
    func ShowZoomingStars()
    {
        StarFieldView.Show()
    }
    
    func HideZoomingStars()
    {
        StarFieldView.Hide()
    }
    
    @IBAction func HandleViewTypeChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            switch Segment.selectedSegmentIndex
            {
                case 0:
                    HandleNewViewType(NewType: .NorthCentered)
                
                case 1:
                    HandleNewViewType(NewType: .SouthCentered)
                
                case 2:
                    HandleNewViewType(NewType: .Globe3D)
                
                default:
                    break
            }
        }
    }
    
    @IBAction func HandleDebugButtonPressed(_ sender: Any)
    {
        let Storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let Controller = Storyboard.instantiateViewController(identifier: "DebugDialogRoot") as? DebugNavigationViewer
        {
            Controller.MainObject = self
            if let DebugSettingDialog = Controller.topViewController as? DebugController
            {
                DebugSettingDialog.MainObject = self
            }
            if let PresentingController = Controller.presentationController
            {
                PresentingController.delegate = self
            }
            self.present(Controller, animated: true, completion: nil)
            if let PopView = Controller.popoverPresentationController
            {
                PopView.sourceView = MainDebugButton
                PopView.sourceRect = MainDebugButton.bounds
            }
        }
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
    
    func FreezeDate(_ IsFrozen: Bool, ToDate: Date)
    {
        
    }
    
    func FreezeDate(_ IsFrozen: Bool)
    {
        
    }
    
    func DecoupleClocks()
    {
        
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
    
    @IBAction func HandleSettingsButtonPressed(_ sender: Any)
    {
        ShowSettingsWindow()
    }
    
    // MARK: - Main protocol functions
    
    /// Return a reference to the 3D world.
    /// - Returns: The 3D world.
    func GlobeObject() -> GlobeView?
    {
        return WorldViewer3D
    }
    
    /// Handle changes to the vie type.
    func MainViewTypeChanged()
    {
        switch Settings.GetViewType()
        {
            case .Globe3D:
                WorldViewer3D.Show()
                if Settings.ShowStars()
                {
                    StarFieldView.Show()
                }
                SetFlatlandVisibility(FlatIsVisible: false)
                PleaseWait
                    {
                        WorldViewer3D.AddEarth()
            }
            
            case .FlatMap:
                switch Settings.GetImageCenter()
                {
                    case .NorthPole:
                        WorldViewer3D.Hide()
                        StarFieldView.Hide()
                        SetFlatlandVisibility(FlatIsVisible: true)
                        SetNightMask()
                        SettingsDone()
                    
                    case .SouthPole:
                        WorldViewer3D.Hide()
                        StarFieldView.Hide()
                        SetFlatlandVisibility(FlatIsVisible: true)
                        SetNightMask()
                        SettingsDone()
            }
            
            default:
                break
        }
    }
    
    /// Handle map type changes.
    /// - Parameter MapType: The new map type.
    func SetTexture(_ MapType: MapTypes)
    {
        Settings.SetFlatlandMapType(MapType)
        Settings.SetGlobeMapType(MapType)
        ChangeMap()
    }
    
    func ShowLocalData(_ Show: Bool)
    {
        LocalDataTimer?.invalidate()
        LocalDataTimer = nil
        if Show
        {
            LocalDataTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                                  target: self,
                                                  selector: #selector(UpdateLocalData),
                                                  userInfo: nil,
                                                  repeats: true)
        }
    }
    
    func ShowCities(_ Show: Bool)
    {
        
    }
    
    func SetDisplayLanguage()
    {
        
    }
    
    func GetWorldHeritageSites() -> [WorldHeritageSite]
    {
        if WorldHeritageSites == nil
        {
            return []
        }
        return WorldHeritageSites!
    }
    
    // MARK: - Variables for extensions.
    
    var UnescoURL: URL? = nil
    static var UnescoInitialized = false
    static var UnescoHandle: OpaquePointer? = nil
    var WorldHeritageSites: [WorldHeritageSite]? = nil
    var NightMaskCache = [String: UIImage]()
    
    // MARK: - Interface builder outlets.
    
    @IBOutlet weak var MainDebugButton: UIButton!
    @IBOutlet weak var TemperatureStatus: UIButton!
    @IBOutlet weak var ElapsedRuntime: UILabel!
    @IBOutlet weak var NightMaskView: UIImageView!
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

/// Types of map views.
enum MapViewTypes
{
    /// North-centered flat map.
    case NorthCentered
    /// South-centered flat map.
    case SouthCentered
    /// 3D globe.
    case Globe3D
}
