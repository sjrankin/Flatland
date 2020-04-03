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
        
        TopView.backgroundColor = UIColor.black
        SettingsDone()
        Sun.VariableSunImage(Using: SunViewTop, Interval: 0.1)
        Sun.VariableSunImage(Using: SunViewBottom, Interval: 0.1)
        Top10 = CityList.TopNCities(N: 10, UseMetroPopulation: true)
        /*
        Top10.removeAll()
        #if true
        Top10.append(City("Tokyo", "Japan", true, 100, 100, 35.6804, 139.7690, "Asia"))
        #else
        Top10.append(City("North Pole", "No One", true, 1, 2, 90.0, 0.0, "North America"))
        Top10.append(City("Gulf of Guinea", "No One", true, 2, 1, 0.0, -90.0, "Africa"))
        Top10.append(City("Sahara", "No One", true, 2, 1, 45.0, -90.0, "Africa"))
        Top10.append(City("Atlantic", "No One", true, 2, 1, -45.0, -90.0, "Africa"))
        
        Top10.append(City("Guinea Antipodal", "No One", true, 2, 1, 0.0, 90.0, "Asia"))
        Top10.append(City("Sahara Antipodal", "No One", true, 2, 1, 45.0, 90.0, "Asia"))
        Top10.append(City("Atlantic Antipodal", "No One", true, 2, 1, -45.0, 90.0, "Asia"))
        
        Top10.append(City("Canada", "No One", true, 2, 1, 0.0, 0.0, "North America"))
        Top10.append(City("Mexico", "No One", true, 2, 1, 45.0, 0.0, "North America"))
        Top10.append(City("Southeast Pacific", "No One", true, 2, 1, -45.0, 0.0, "South America"))
        
        Top10.append(City("Siberia", "No One", true, 2, 1, 0.0, 180.0, "Asia"))
        Top10.append(City("Indian Ocean", "No One", true, 2, 1, 45.0, 180.0, "Asia"))
        Top10.append(City("South Indian Ocean", "No One", true, 2, 1, -45.0, 180.0, "Asia"))
        #endif
        
//        Top10.append(City("Indian Ocean", "No One", true, 2, 1, 0.0, 90.0, "Asia"))
//        Top10.append(City("Pacific Ocean", "No One", true, 2, 1, 0.0, -90.0, "South America"))
        let D1 = Geometry.LawOfCosines(Point1: CGPoint(x: 0.0, y: 90.0), Point2: CGPoint(x: 0.0, y: 0.0), Radius: 6371.0)
        print("Distance from north pole to Gulf of Guinea: \(D1)km")
         */
        for Top in Top10
         {
            print("Name: \(Top.Name), population: \(Top.MetropolitanPopulation!)")
         }
    }
    
    var Top10 = [City]()
    let CityList = Cities()
    let Sun = SunGenerator()
    
    /// Get the original locations of the sun and time labels. Initialize the program based on
    /// user settings.
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        OriginalTimeFrame = MainTimeLabelBottom.frame
        OriginalSunFrame = SunViewTop.frame
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        //UpdateSunLocations()
    }
    
    ///  Original location of the time label.
    var OriginalTimeFrame: CGRect = CGRect.zero
    /// Original location of the sun image.
    var OriginalSunFrame: CGRect = CGRect.zero
    
    /// Called when the user closes the settings view controller, and when the program first starts.
    func SettingsDone()
    {
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
        var ProvisionalImage = ""
        switch Settings.GetImageCenter()
        {
            case .NorthPole:
                ProvisionalImage = "WorldNorth"
            
            case .SouthPole:
                ProvisionalImage = "WorldSouth"
        }
        if ProvisionalImage != PreviousImage
        {
            PreviousImage = ProvisionalImage
            WorldViewer.image = UIImage(named: PreviousImage)
        }
        #if false
        if Settings.GetTimeLabel() == .None
        {
            MainTimeLabelBottom.isHidden = true
        }
        else
        {
            MainTimeLabelBottom.isHidden = false
        }
        #endif
        PreviousPercent = -1.0
        StartTimeLabel()
    }
    
    var InitialSunPrint: UUID? = nil
    
    /// Update the location of the sun. The sun can be on top or on the bottom and swaps places
    /// with the time label.
    func UpdateSunLocations()
    {
        if SingleTask.NotCompleted(&InitialSunPrint)
        {
            print("Initial sun location: \(Settings.GetSunLocation().rawValue)")
        }
        switch Settings.GetSunLocation()
        {
            case .Hidden:
                SunViewTop.isHidden = true
                SunViewBottom.isHidden = true
            
            case .Top:
                SunViewTop.isHidden = false
                SunViewBottom.isHidden = true
                if Settings.GetTimeLabel() != .None
                {
                    MainTimeLabelBottom.isHidden = false
                    MainTimeLabelTop.isHidden = true
            }
            
            case .Bottom:
                SunViewTop.isHidden = true
                SunViewBottom.isHidden = false
                if Settings.GetTimeLabel() != .None
                {
                    MainTimeLabelBottom.isHidden = true
                    MainTimeLabelTop.isHidden = false
            }
        }
    }
    
    /// Initialize/draw the grid on the Earth. Which lines are drawn depend on user settings.
    /// - Parameter Radians: Rotational value of the prime meridians.
    func DrawGrid(_ Radians: Double)
    {
        if GridOverlay.layer.sublayers != nil
        {
            for Layer in GridOverlay.layer.sublayers!
            {
                if Layer.name == "PrimeMeridian"
                {
                    Layer.removeFromSuperlayer()
                }
            }
        }
        GridOverlay.backgroundColor = UIColor.clear
        let Grid = CAShapeLayer()
        Grid.name = "ViewGrid"
        Grid.bounds = GridOverlay.frame
        Grid.frame = GridOverlay.frame
        let Lines = UIBezierPath()
        let CenterH = Grid.bounds.size.width / 2.0
        let CenterV = Grid.bounds.size.height / 2.0
        if Settings.ShowNoonMeridians()
        {
            Lines.move(to: CGPoint(x: CenterH, y: 0))
            Lines.addLine(to: CGPoint(x: CenterH, y: Grid.frame.size.height))
            Lines.move(to: CGPoint(x: 0, y: CenterV))
            Lines.addLine(to: CGPoint(x: Grid.frame.size.width, y: CenterV))
        }
        
        let MeridianLayer = CAShapeLayer()
        MeridianLayer.fillColor = UIColor.clear.cgColor
        MeridianLayer.strokeColor = UIColor.systemYellow.withAlphaComponent(0.5).cgColor
        MeridianLayer.lineWidth = 1.0
        let Meridians = UIBezierPath()
        if Settings.ShowPrimeMeridians()
        {
            MeridianLayer.name = "PrimeMeridian"
            MeridianLayer.frame = GridOverlay.bounds
            MeridianLayer.bounds = GridOverlay.bounds
            Meridians.move(to: CGPoint(x: CenterH, y: 0))
            Meridians.addLine(to: CGPoint(x: CenterH, y: Grid.frame.size.height))
            Meridians.move(to: CGPoint(x: 0, y: CenterV))
            Meridians.addLine(to: CGPoint(x: Grid.frame.size.width, y: CenterV))
            let Rotation = CATransform3DMakeRotation(CGFloat(-Radians), 0.0, 0.0, 1.0)
            MeridianLayer.transform = Rotation
        }
        if Settings.ShowTropics()
        {
            let TropicDistance: CGFloat = 23.43666
            let TropicPercent = Grid.bounds.size.width * (TropicDistance / 180.0)
            let CancerWidth = CenterH - TropicPercent
            let Cancer = UIBezierPath(ovalIn: CGRect(x: CenterH - (CancerWidth / 2.0),
                                                     y: CenterV - (CancerWidth / 2.0),
                                                     width: CancerWidth,
                                                     height: CancerWidth))
            let CapricornWidth = CenterH + TropicPercent
            let Capricorn = UIBezierPath(ovalIn: CGRect(x: CenterH - (CapricornWidth / 2.0),
                                                        y: CenterV - (CapricornWidth / 2.0),
                                                        width: CapricornWidth,
                                                        height: CapricornWidth))
            Meridians.append(Cancer)
            Meridians.append(Capricorn)
        }
        if Settings.ShowPolarCircles()
        {
            let PolarCircle: CGFloat = 66.55
            let InnerPercent = Grid.bounds.size.width * (PolarCircle / 180.0)
            let InnerWidth = CenterH - InnerPercent
            let InnerCircle = UIBezierPath(ovalIn: CGRect(x: CenterH - (InnerWidth / 2.0),
                                                          y: CenterV - (InnerWidth / 2.0),
                                                          width: InnerWidth,
                                                          height: InnerWidth))
            let OuterPercent = Grid.bounds.size.width * (PolarCircle / 180.0)
            let OuterWidth = CenterH + OuterPercent
            let OuterCircle = UIBezierPath(ovalIn: CGRect(x: CenterH - (OuterWidth / 2.0),
                                                          y: CenterV - (OuterWidth / 2.0),
                                                          width: OuterWidth,
                                                          height: OuterWidth))
            Meridians.append(InnerCircle)
            Meridians.append(OuterCircle)
        }
        if Settings.ShowEquator()
        {
            let Equator = UIBezierPath(ovalIn: CGRect(x: CenterH / 2,
                                                      y: CenterV / 2,
                                                      width: CenterH,
                                                      height: CenterV))
            Meridians.append(Equator)
        }
        MeridianLayer.path = Meridians.cgPath
        GridOverlay.layer.addSublayer(MeridianLayer)
        Grid.strokeColor = UIColor.black.withAlphaComponent(0.5).cgColor
        Grid.lineWidth = 1.0
        Grid.fillColor = UIColor.clear.cgColor
        Grid.path = Lines.cgPath
        GridOverlay.layer.addSublayer(Grid)
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
    
    /// Updates the current time (which may or may not be visible given user settings) as well as
    /// rotates the Earth image to keep it aligned with the sun.
    @objc func TimeUpdater()
    {
        let Now = GetUTC()
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
        RotateImageTo(PrettyPercent)
        #if true
        if Top10.count > 0
        {
            if SingleTask.NotCompleted(&TestCities)
            {
                let FinalOffset = Settings.GetSunLocation() == .Bottom ? 0.0 : OriginalOrientation
                let Radial = MakeRadialTime(From: PrettyPercent, With: FinalOffset)
                PlotCities(InCityList: Top10, RadialTime: Radial, CityListChanged: false)
            }
        }
        #endif
    }
    var TestCities: UUID? = nil
    
    let SecondsInDay: Int = 60 * 60 * 24
    
    func GetUTC() -> Date
    {
        return Date()
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
        if PreviousPercent == Percent
        {
            return
        }
        PreviousPercent = Percent
        let FinalOffset = Settings.GetSunLocation() == .Bottom ? 0.0 : OriginalOrientation
        //Be sure to rotate the proper direction based on the map.
        #if false
        var Degrees = 360.0 * Percent - FinalOffset
        //Degrees = Settings.GetSunLocation() == .Bottom ? 360.0 - Degrees : Degrees
        let Radians = Degrees * Double.pi / 180.0
        #else
        let Radians = MakeRadialTime(From: Percent, With: FinalOffset)
        #endif
        let Rotation = CATransform3DMakeRotation(CGFloat(-Radians), 0.0, 0.0, 1.0)
        WorldViewer.layer.transform = Rotation
        if Settings.ShowGrid()
        {
            DrawGrid(Radians)
        }
        if Settings.ShowCities()
        {
            PlotCities(InCityList: Top10, RadialTime: Radians, CityListChanged: true)
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
            let CityPath = PlotCity3(SomeCity, Diameter: (CityLayer?.bounds.width)!)
            Bezier.append(CityPath)
        }
        CityLayer?.fillColor = UIColor.red.cgColor
        CityLayer?.strokeColor = UIColor.black.cgColor
        CityLayer?.lineWidth = 1.0
        CityLayer?.path = Bezier.cgPath
        let Rotation = CATransform3DMakeRotation(CGFloat(-RadialTime), 0.0, 0.0, 1.0)
        CityLayer?.transform = Rotation
    }
    
        let HalfCircumference: Double = 40075.0 / 2.0
    
    func PlotCity3(_ PlotMe: City, Diameter: CGFloat) -> UIBezierPath
    {
        let Latitude = PlotMe.Latitude
        let Longitude = PlotMe.Longitude
        let Half = Double(Diameter / 2.0)
        let Ratio: Double = Half / HalfCircumference
        let CitySize: CGFloat = 10.0
        let CityDotSize = CGSize(width: CitySize, height: CitySize)
        let PointModifier = Double(CGFloat(Half) - (CitySize / 2.0))
        
        var Distance = DistanceFromNorthPole(To: GeoPoint2(Latitude, Longitude))
        Distance = Distance * Ratio
        var CityBearing = Bearing(Start: GeoPoint2(90.0, 0.0), End: GeoPoint2(Latitude, Longitude))
        CityBearing = (CityBearing + 90.0).ToRadians()
        let PointX = Distance * cos(CityBearing) + PointModifier
        let PointY = Distance * sin(CityBearing) + PointModifier
        let Origin = CGPoint(x: PointX, y: PointY)

        let City = UIBezierPath(ovalIn: CGRect(origin: Origin, size: CityDotSize))
     return City
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
    
    func LawOfCosines(Point1: GeoPoint2, Point2: GeoPoint2) -> Double
    {
        let Term1 = sin(Point1.Latitude.ToRadians()) * sin(Point2.Latitude.ToRadians())
        let Term2 = cos(Point1.Latitude.ToRadians()) * cos(Point2.Latitude.ToRadians())
        let Term3 = cos(Point2.Longitude.ToRadians() - Point1.Longitude.ToRadians())
        var V = acos(Term1 + (Term2 * Term3))
        V = V * 6367.4447
        return V
    }
    
    func DistanceFromNorthPole(To: GeoPoint2) -> Double
    {
        return LawOfCosines(Point1: GeoPoint2(90.0, 0.0), Point2: To)
    }

    func PrettyPoint(_ Point: CGPoint) -> String
    {
        let X = Double(Point.x).RoundedTo(3)
        let Y = Double(Point.y).RoundedTo(3)
        return "(\(X),\(Y))"
    }
    
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
    
    /// Instantiate the settings controller.
    @IBSegueAction func InstantiateSettingsNavigator(_ coder: NSCoder) -> SettingsNavigationViewer?
    {
        let Controller = SettingsNavigationViewer(coder: coder)
        Controller?.Delegate = self
        return Controller
    }
    
    @IBOutlet weak var SettingsButton: UIButton!
    @IBOutlet weak var GridOverlay: UIView!
    @IBOutlet weak var SunViewTop: UIImageView!
    @IBOutlet weak var SunViewBottom: UIImageView!
    @IBOutlet weak var MainTimeLabelBottom: UILabel!
    @IBOutlet weak var MainTimeLabelTop: UILabel!
    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var WorldViewer: UIImageView!
}

extension Double
{
    func RoundedTo(_ Count: Int) -> Double
    {
        let Multiplier = pow(10.0, Count)
        let Value = Int(self * Double(truncating: Multiplier as NSNumber))
        return Double(Value) / Double(truncating: Multiplier as NSNumber)
    }
    
    func ToRadians() -> Double
    {
        return self * Double.pi / 180.0
    }
    
    func ToDegrees() -> Double
    {
        return self * 180.0 / Double.pi
    }
}
