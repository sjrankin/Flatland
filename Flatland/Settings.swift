//
//  Settings.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/26/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Settings
{
    public static func Initialize()
    {
        //See if we've already initialized the defaults. If so, just return.
        if let _ = UserDefaults.standard.string(forKey: "Initialized")
        {
            return
        }
        UserDefaults.standard.set("WasInitialized", forKey: "Initialized")
        SetTimeLabel(.UTC)
        SetImageCenter(.NorthPole)
        SetSunLocation(.Top)
        SetGrid(true)
        SetEquator(true)
        SetTropics(true)
        SetPolarCircles(true)
        SetPrimeMeridians(true)
        SetNoonMeridians(true)
        SetShowCities(true)
        SetWorldCities100(true)
        SetAfricanCities100(false)
        SetAsianCities100(false)
        SetEuropeanCities100(false)
        SetNorthAmericanCities100(false)
        SetSouthAmericanCities100(false)
        SetCapitalCities(true)
        SetUserLocations(true)
        SetShowLocalData(true)
        SetLocations([])
    }
    
    // MARK: - Location list settings.
    
    public static func SetLocations(_ List: [(ID: UUID, Coordinates: GeoPoint2, Name: String, Color: UIColor)])
    {
        if List.count == 0
        {
            UserDefaults.standard.set("", forKey: "UserLocations")
            return
        }
        var LocationList = ""
        for (ID, Location, Name, Color) in List
        {
            var Item = ID.uuidString + ","
            Item.append("\(Location.Latitude),\(Location.Longitude),")
            Item.append("\(Name),")
            var ColorName = ""
            switch Color
            {
                case UIColor.black:
                ColorName = "Black"
                
                case UIColor.white:
                ColorName = "White"
                
                case UIColor.cyan:
                ColorName = "Cyan"
                
                case UIColor.magenta:
                ColorName = "Magenta"
                
                case UIColor.yellow:
                ColorName = "Yellow"
                
                case UIColor.red:
                ColorName = "Red"
                
                case UIColor.green:
                ColorName = "Green"
                
                case UIColor.blue:
                ColorName = "Blue"
                
                case UIColor.orange:
                ColorName = "Orange"
                
                case UIColor.systemPink:
                ColorName = "Pink"
                
                default:
                ColorName = "Red"
            }
            Item.append("\(ColorName);")
            LocationList.append(Item)
        }
        UserDefaults.standard.set(LocationList, forKey: "UserLocations")
    }
    
    public static func GetLocations() -> [(ID: UUID, Coordinates: GeoPoint2, Name: String, Color: UIColor)]
    {
                    var Results = [(ID: UUID, Coordinates: GeoPoint2, Name: String, Color: UIColor)]()
        if let Raw = UserDefaults.standard.string(forKey: "UserLocations")
        {
            let Locations = Raw.split(separator: ";", omittingEmptySubsequences: true)
            for Where in Locations
            {
                var ID: UUID = UUID()
                var Lat: Double = 0.0
                var Lon: Double = 0.0
                var Name: String = ""
                var Color: UIColor = UIColor.red
                let Raw = String(Where)
                let Parts = Raw.split(separator: ",", omittingEmptySubsequences: true)
                if Parts.count == 5
                {
                    for Index in 0 ..< Parts.count
                    {
                        let Part = String(Parts[Index]).trimmingCharacters(in: CharacterSet.whitespaces)
                        switch Index
                        {
                            case 0:
                            ID = UUID(uuidString: Part)!
                            
                            case 1:
                            Lat = Double(Part)!
                            
                            case 2:
                            Lon = Double(Part)!
                            
                            case 3:
                                Name = Part
                            
                            case 4:
                                switch Part
                            {
                                case "Red":
                                    Color = UIColor.red
                                
                                case "Green":
                                    Color = UIColor.green
                                
                                case "Blue":
                                    Color = UIColor.blue
                                
                                case "Cyan":
                                    Color = UIColor.cyan
                                
                                case "Magenta":
                                    Color = UIColor.magenta
                                
                                case "Yellow":
                                    Color = UIColor.yellow
                                
                                case "Orange":
                                    Color = UIColor.orange
                                
                                case "Pink":
                                    Color = UIColor.systemPink
                                
                                default:
                                    Color = UIColor.red
                            }
                            default:
                            break
                        }
                    }
                }
                Results.append((ID: ID, GeoPoint2(Lat, Lon), Name: Name, Color: Color))
            }
        }
        else
        {
            return []
        }
        return Results
    }
    
    // MARK: - General view settings.
    
    public static func GetTimeLabel() -> TimeLabels
    {
        if let Value = UserDefaults.standard.string(forKey: "TimeLabels")
        {
            if let Final = TimeLabels(rawValue: Value)
            {
                return Final
            }
            UserDefaults.standard.set(TimeLabels.UTC.rawValue, forKey: "TimeLabels")
            return .UTC
        }
        UserDefaults.standard.set(TimeLabels.UTC.rawValue, forKey: "TimeLabels")
        return .UTC
    }
    
    public static func SetTimeLabel(_ NewLabel: TimeLabels)
    {
        UserDefaults.standard.set(NewLabel.rawValue, forKey: "TimeLabels")
    }
    
    public static func GetImageCenter() -> ImageCenters
    {
        if let Value = UserDefaults.standard.string(forKey: "ImageCenter")
        {
            if let Final = ImageCenters(rawValue: Value)
            {
                return Final
            }
            UserDefaults.standard.set(ImageCenters.NorthPole.rawValue, forKey: "ImageCenter")
            return .NorthPole
        }
        UserDefaults.standard.set(ImageCenters.NorthPole.rawValue, forKey: "ImageCenter")
        return .NorthPole
    }
    
    public static func SetImageCenter(_ NewCenter: ImageCenters)
    {
        UserDefaults.standard.set(NewCenter.rawValue, forKey: "ImageCenter")
    }
    
    public static func GetSunLocation() -> SunLocations
    {
        if let Value = UserDefaults.standard.string(forKey: "SunLocation")
        {
            if let Final = SunLocations(rawValue: Value)
            {
                return Final
            }
            UserDefaults.standard.set(SunLocations.Top.rawValue, forKey: "SunLocation")
            return .Top
        }
        UserDefaults.standard.set(SunLocations.Top.rawValue, forKey: "SunLocation")
        return .Top
    }
    
    public static func SetSunLocation(_ NewLocation: SunLocations)
    {
        UserDefaults.standard.set(NewLocation.rawValue, forKey: "SunLocation")
    }
    
    // MARK: - Grid-related settings.
    
    public static func ShowGrid() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "ShowGrid")
    }
    
    public static func SetGrid(_ Show: Bool)
    {
        UserDefaults.standard.set(Show, forKey: "ShowGrid")
    }
    
    public static func ShowEquator() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "ShowEquator")
    }
    
    public static func SetEquator(_ Show: Bool)
    {
        UserDefaults.standard.set(Show, forKey: "ShowEquator")
    }
    
    public static func ShowTropics() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "ShowTropics")
    }
    
    public static func SetTropics(_ Show: Bool)
    {
        UserDefaults.standard.set(Show, forKey: "ShowTropics")
    }
    
    public static func ShowPolarCircles() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "ShowPolarCircles")
    }
    
    public static func SetPolarCircles(_ Show: Bool)
    {
        UserDefaults.standard.set(Show, forKey: "ShowPolarCircles")
    }
    
    public static func ShowPrimeMeridians() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "ShowPrimeMeridians")
    }
    
    public static func SetPrimeMeridians(_ Show: Bool)
    {
        UserDefaults.standard.set(Show, forKey: "ShowPrimeMeridians")
    }
    
    public static func ShowNoonMeridians() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "ShowNoonMeridians")
    }
    
    public static func SetNoonMeridians(_ Show: Bool)
    {
        UserDefaults.standard.set(Show, forKey: "ShowNoonMeridians")
    }
    
    // MARK: - City/location-related settings.
    
    public static func ShowCities() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "ShowCities")
    }
    
    public static func SetShowCities(_ Show: Bool)
    {
        UserDefaults.standard.set(Show, forKey: "ShowCities")
    }
    
    public static func ShowWorldCities100() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "ShowWorldCities")
    }
    
    public static func SetWorldCities100(_ Show: Bool)
    {
        UserDefaults.standard.set(Show, forKey: "ShowWorldCities")
    }
    
    public static func ShowAsianCities100() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "ShowAsianCities")
    }
    
    public static func SetAsianCities100(_ Show: Bool)
    {
        UserDefaults.standard.set(Show, forKey: "ShowAsianCities")
    }
    
    public static func ShowAfricanCities100() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "ShowAfricanCities")
    }
    
    public static func SetAfricanCities100(_ Show: Bool)
    {
        UserDefaults.standard.set(Show, forKey: "ShowAfricanCities")
    }
    
    public static func ShowEuropeanCities100() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "ShowEuropeanCities")
    }
    
    public static func SetEuropeanCities100(_ Show: Bool)
    {
        UserDefaults.standard.set(Show, forKey: "ShowEuropeanCities")
    }
    
    public static func ShowNorthAmericanCities100() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "ShowNorthAmericanCities")
    }
    
    public static func SetNorthAmericanCities100(_ Show: Bool)
    {
        UserDefaults.standard.set(Show, forKey: "ShowNorthAmericanCities")
    }
    
    public static func ShowSouthAmericanCities100() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "ShowSouthAmericanCities")
    }
    
    public static func SetSouthAmericanCities100(_ Show: Bool)
    {
        UserDefaults.standard.set(Show, forKey: "ShowSouthAmericanCities")
    }
    
    public static func ShowCapitalCities() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "ShowCapitalCities")
    }
    
    public static func SetCapitalCities(_ Show: Bool)
    {
        UserDefaults.standard.set(Show, forKey: "ShowCapitalCities")
    }
    
    public static func ShowUserLocations() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "ShowUserLocations")
    }
    
    public static func SetUserLocations(_ Show: Bool)
    {
        UserDefaults.standard.set(Show, forKey: "ShowUserLocations")
    }
    
    //MARK: - Local settings display.
    
    public static func GetShowLocalData() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "ShowLocalData")
    }
    
    public static func SetShowLocalData(_ Show: Bool)
    {
        UserDefaults.standard.set(Show, forKey: "ShowLocalData")
    }
    
    public static func GetLocalLatitude() -> Double?
    {
        if let Value = UserDefaults.standard.string(forKey: "UserLatitude")
        {
            if let Final = Double(Value)
            {
                return Final
            }
        }
        return nil
    }
    
    public static func SetLocalLatitude(_ NewLatitude: Double)
    {
        let Raw = "\(NewLatitude)"
        UserDefaults.standard.set(Raw, forKey: "UserLatitude")
    }
    
    public static func GetLocalLongitude() -> Double?
    {
        if let Value = UserDefaults.standard.string(forKey: "UserLongitude")
        {
            if let Final = Double(Value)
            {
                return Final
            }
        }
        return nil
    }
    
    public static func SetLocalLongitude(_ NewLatitude: Double)
    {
        let Raw = "\(NewLatitude)"
        UserDefaults.standard.set(Raw, forKey: "UserLongitude")
    }
    
    public static func GetLocalTimeZoneOffset() -> Int
    {
        return UserDefaults.standard.integer(forKey: "LocalTimeZoneOffset")
    }
    
    public static func SetLocalTimeZoneOffset(_ NewOffset: Int)
    {
        UserDefaults.standard.set(NewOffset, forKey: "LocalTimeZoneOffset")
    }
    
    public static let GlobeMapList: [MapTypes: String] =
        [
            .Standard: "FlatEarthMap",
            .BlueMarble: "LandMask2",
            .DarkBlueMarble: "DarkLandMask",
            .Simple: "SimpleMap1",
            .Continents: "SimpleMapContinents",
            .SimpleBorders1: "SimpleMapWithBorders1",
            .SimpleBorders2: "SimpleMapWithBordersButNoBackground",
            .Dots: "DotMap"
    ]
    
    public static let FlatMapList: [MapTypes: String] =
        [
            .Standard: "FlatEarthMap",
            .BlueMarble: "LandMask2",
            .DarkBlueMarble: "DarkLandMask",
            .Simple: "SimpleMap1",
            .Continents: "SimpleMapContinents",
            .SimpleBorders1: "SimpleMapWithBorders1",
            .SimpleBorders2: "SimpleMapWithBordersButNoBackground",
            .Dots: "DotMap"
    ]
}

// MARK: - Enums for some settings.

/// The available time label types.
enum TimeLabels: String, CaseIterable
{
    /// Do not display the time.
    case None = "None"
    /// Time is in UTC.
    case UTC = "UTC"
    /// Time is in current local timezone.
    case Local = "Local"
}

/// Determines whether the north pole or the south pole is at the center of the world image.
enum ImageCenters: String, CaseIterable
{
    /// North pole is in the center.
    case NorthPole = "NorthPole"
    /// South pole is in the center.
    case SouthPole = "SouthPole"
}

/// Determines the location of the sun graphic (and by implication, the time label as well).
enum SunLocations: String, CaseIterable
{
    /// Do not display the sun.
    case Hidden = "NoSun"
    /// Sun is at the top.
    case Top = "Top"
    /// Sun is at the bottom.
    case Bottom = "Bottom"
}

enum MapTypes: String, CaseIterable
{
    case Standard = "Standard"
    case BlueMarble = "Blue Marble"
    case DarkBlueMarble = "Dark Blue Marble"
    case Simple = "Simple"
    case SimpleBorders1 = "Simple with Borders 1"
    case SimpleBorders2 = "Simple with Borders 2"
        case Continents = "Continents"
    case Dots = "Dotted Continents"
}
