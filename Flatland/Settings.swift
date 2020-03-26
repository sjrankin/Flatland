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
        SetPrimeMeridians(true)
        SetNoonMeridians(true)
    }
    
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
}

enum TimeLabels: String, CaseIterable
{
    case None = "None"
    case UTC = "UTC"
    case Local = "Local"
}

enum ImageCenters: String, CaseIterable
{
    case NorthPole = "NorthPole"
    case SouthPole = "SouthPole"
}

enum SunLocations: String, CaseIterable
{
    case Hidden = "NoSun"
    case Top = "Top"
    case Bottom = "Bottom"
}
