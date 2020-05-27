//
//  +FlatView.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/1/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension MainView
{
    /// Sets the visibility of either the 3D globe or 2D map depending on the passed boolean.
    /// - Parameter FlatIsVisible: If true, 2D maps are visible. If false, 3D maps are visible.
    func SetFlatlandVisibility(FlatIsVisible: Bool)
    {
        NightMaskView.isHidden = !FlatIsVisible
        WorldViewer.isHidden = !FlatIsVisible
        GridOverlay.isHidden = !FlatIsVisible
        HourLayer2D.isHidden = !FlatIsVisible
        HourLayer2D.backgroundColor = UIColor.clear
        Show2DHours()
        if !FlatIsVisible
        {
            SunViewTop?.alpha = 0.0
            SunViewBottom?.alpha = 0.0
            MainTimeLabelBottom.isHidden = true
            MainTimeLabelTop.isHidden = false
        }
        else
        {
            SunViewTop?.alpha = 1.0
            SunViewBottom?.alpha = 1.0
            UpdateSunLocations()
        }
    }
    
    /// Set the night mask for 2D maps.
    func SetNightMask()
    {
        if Settings.GetViewType() == .Globe3D
        {
            return
        }
        if !Settings.ShowNight()
        {
            NightMaskView.image = nil
            return
        }
        if let Image = GetNightMask(ForDate: Date())
        {
            NightMaskView.image = Image
        }
        else
        {
            print("No night mask for \(Date()) found.")
        }
    }
    
    /// Given a date, return a mask image for a flat map.
    /// - Parameter From: The date for the night mask.
    /// - Returns: Name of the night mask image file.
    func MakeNightMaskName(From: Date) -> String
    {
        let Day = Calendar.current.component(.day, from: From)
        let Month = Calendar.current.component(.month, from: From) - 1
        let MonthName = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][Month]
        let Prefix = Settings.GetImageCenter() == .NorthPole ? "" : "South_"
        return "\(Prefix)\(Day)_\(MonthName)"
    }
    
    /// Get a night mask image for a flat map for the specified date.
    /// - Parameter ForDate: The date of the night mask.
    /// - Returns: Image for the passed date (and flat map orientation). Nil return on error.
    func GetNightMask(ForDate: Date) -> UIImage?
    {
        let ImageName = MakeNightMaskName(From: ForDate)
        #if false
        if let CachedMask = NightMaskCache[ImageName]
        {
            return CachedMask
        }
        #endif
        var MaskAlpha = Settings.NightMaskAlpha()
        if MaskAlpha == 0.0
        {
            MaskAlpha = 0.4
            Settings.SetNightMaskAlpha(MaskAlpha)
        }
        let MaskImage = UIImage(named: ImageName)!
        let Final = MaskImage.Alpha(CGFloat(MaskAlpha))
        NightMaskCache[ImageName] = Final
        return Final
    }
    
    /// Show hours for the 2D view. The hour style is determined by user settings.
    func Show2DHours()
    {
        if Settings.GetViewType() == .Globe3D || Settings.GetViewType() == .CubicWorld
        {
            HourLayer2D.isHidden = false
            HourLayer2D.layer.sublayers?.removeAll()
            return
        }
        if Settings.GetHourValueType() != .None
        {
            HourLayer2D.isHidden = false
            HourLayer2D.layer.zPosition = 60000
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
            var HourOffset: CGFloat = 0.0
            if HourType != .RelativeToLocation
            {
                let Rotation = CATransform3DMakeRotation(0.0, 0.0, 0.0, 1.0)
                HourLayer2D.layer.transform = Rotation
            }
            else
            {
                HourOffset = -0.5
            }
            var HourList = [0, -1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
            let InitialOffset = Settings.GetImageCenter() == .SouthPole ? 5 : 6
            HourList = HourList.Shift(By: InitialOffset)
            if let LocalLongitude = Settings.GetLocalLongitude()
            {
                var Long = Int(LocalLongitude / 15.0)
                Long = Long * Int(Settings.GetImageCenter() == .SouthPole ? -1 : 1)
                HourList = HourList.Shift(By: Long)
            }
            for Hour in 0 ... 23
            {
                let Angle = (CGFloat(Hour) + HourOffset) / 24.0 * 360.0
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
                        if let _ = Settings.GetLocalLongitude()
                        {
                            DisplayHour = HourList[Hour]
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
                    
                    default:
                        return
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
    
    /// Make a nice-looking attributed text string to use as hour displays.
    /// - Parameter Hour: The hour value to display.
    /// - Parameter Font: The font of the hour value.
    /// - Parameter Color: The color of the text.
    /// - Parameter StrokeColor: The color of the stroke of the text.
    /// - Parameter StrokeThickness: The thickness of the stroke. Specify a negative number to ensure
    ///                              `Color` is used to fill the text.
    /// - Parameter IncludeSide: If true, "+" will prefix all positive numbers.
    /// - Returns: Tuple of the attributed string, the width of the text, and the height of the text.
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
    
    /// Update the location of the sun. The sun can be on top or on the bottom and swaps places
    /// with the time label.
    func UpdateSunLocations()
    {
        if Settings.GetViewType() == .Globe3D
        {
            return
        }
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
    
    /// Convert the passed time (in terms of percent of a day) into a radian.
    /// - Parameter From: The percent of the day that has passed.
    /// - Parameter With: Offset value to subtract from the number of degrees intermediate value.
    /// - Returns: Radial equivalent of the time percent.
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
    
    /// Plot the cities in the passed list on to the 2D map.
    /// - Parameter InCityList: The list of cities to plot.
    /// - Parameter RadialTime: The current time (in UTC) expressed as radians.
    /// - Parameter CityListChanged: Notifies this function that the list of cities changed since
    ///                              the previous call.
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
                let LocationLayer = PlotLocation(Location, Name, Color, (CityLayer?.bounds.width)!)
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
    
    /// Draw the specified city on a 2D map.
    /// - Parameter PlotMe: The city to plot.
    /// - Parameter Diameter: The diamter of the map.
    /// - Returns: A `UIBezierPath` with size and location ready for plotting on the main layer.
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
    
    /// Plot a point on the 2D map based on the passed point.
    /// - Parameter Location: The location where to plot.
    /// - Parameter Name: The name of the location.
    /// - Parameter Color: The color of the plotted point.
    /// - Parameter Diameter: The diameter of the 2D map.
    /// - Returns: A `CAShapeLayer` with the location plotted.
    func PlotLocation(_ Location: GeoPoint2, _ Name: String, _ Color: UIColor, _ Diameter: CGFloat) -> CAShapeLayer
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
    
    /// Hide cities by removing the city layer.
    func HideCities()
    {
        if CityLayer != nil
        {
            CityLayer?.removeFromSuperlayer()
            CityLayer = nil
        }
    }
}
