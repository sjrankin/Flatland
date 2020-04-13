//
//  Extensions.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/8/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension Double
{
    /// Returns a rounded value of the instance double.
    /// - Note: This "rounding" is nothing more than truncation.
    /// - Parameter Count: Number of places to round to.
    /// - Returns: Rounded value.
    func RoundedTo(_ Count: Int) -> Double
    {
        let Multiplier = pow(10.0, Count)
        let Value = Int(self * Double(truncating: Multiplier as NSNumber))
        return Double(Value) / Double(truncating: Multiplier as NSNumber)
    }
    
    /// Converts the instance value from (an assumed) degrees to radians.
    /// - Returns: Value converted to radians.
    func ToRadians() -> Double
    {
        return self * Double.pi / 180.0
    }
    
    /// Converts the instance value from (an assumed) radians to degrees.
    /// - Returns: Value converted to degrees.
    func ToDegrees() -> Double
    {
        return self * 180.0 / Double.pi
    }
    
    /// Converts the instance value from assumed degrees to radians.
    /// - Returns: Value converted to radians.
    var Radians: Double
    {
        get
        {
            return ToRadians()
        }
    }

    /// Converts the instance value from assumed radians to degrees.
    /// - Returns: Value converted to degrees.
    var Degrees: Double
    {
        get
        {
            return ToDegrees()
        }
    }
}

extension CGFloat
{
    /// Returns a rounded value of the instance CGFloat.
    /// - Note:
    ///     - This "rounding" is nothing more than truncation.
    /// - Parameter Count: Number of places to round to.
    /// - Returns: Rounded value.
    func RoundedTo(_ Count: Int) -> CGFloat
    {
        let Multiplier = pow(10.0, Count)
        let Value = Int(self * CGFloat(Double(truncating: Multiplier as NSNumber)))
        return CGFloat(Value) / CGFloat(Double(truncating: Multiplier as NSNumber))
    }
    
    /// Converts the instance value from (an assumed) degrees to radians.
    /// - Returns: Value converted to radians.
    func ToRadians() -> CGFloat
    {
        return self * CGFloat.pi / 180.0
    }
    
    /// Converts the instance value from (an assumed) radians to degrees.
    /// - Returns: Value converted to degrees.
    func ToDegrees() -> CGFloat
    {
        return self * 180.0 / CGFloat.pi
    }
    
    /// Converts the instance value from assumed degrees to radians.
    /// - Returns: Value converted to radians.
    var Radians: CGFloat
    {
        get
        {
            return ToRadians()
        }
    }
    
    /// Converts the instance value from assumed radians to degrees.
    /// - Returns: Value converted to degrees.
    var Degrees: CGFloat
    {
        get
        {
            return ToDegrees()
        }
    }
}

/// Date extensions.
/// - Note: See [Converting UTC date formal to local](https://stackoverflow.com/questions/29392874/converting-utc-date-format-to-local-nsdate)
extension Date
{
    /// Create a date with the given components.
    /// - Year: The year of the date.
    /// - Month: The month of the date.
    /// - Day: The day of the date.
    /// - Hour: The hour of the day.
    /// - Minute: The minute of the day.
    /// - Second: The second of the day.
    /// - TimeZoneLabel: Valid time zone identifier. If not specified, the current calendar's time
    ///                  zone is used.
    public static func DateFactory(Year: Int, Month: Int, Day: Int, Hour: Int, Minute: Int, Second: Int,
                                  TimeZoneLabel: String? = "UTC") -> Date?
    {
        if Month < 1 || Month > 12
        {
            return nil
        }
        if Day < 1
        {
            return nil
        }
        if Month == 2
        {
            if IsLeapYear(Year)
            {
                if Day > 29
                {
                    return nil
                }
            }
            else
            {
                if Day > 28
                {
                    return nil
                }
            }
        }
        if [1, 3, 5, 7, 8, 10, 12].contains(Month)
        {
            if Day > 31
            {
                return nil
            }
        }
        if Hour < 0 || Hour > 23
        {
            return nil
        }
        if Minute < 0 || Minute > 59
        {
            return nil
        }
        if Second < 0 || Second > 59
        {
            return nil
        }
        var Cal: Calendar!
        if let ZoneLabel = TimeZoneLabel
        {
            Cal = Calendar(identifier: .gregorian)
            if let TZ = TimeZone(identifier: ZoneLabel)
            {
                Cal.timeZone = TZ
            }
            else
            {
                return nil
            }
        }
        else
        {
            Cal = Calendar.current
        }
        var Components = DateComponents()
        Components.year = Year
        Components.month = Month
        Components.day = Day
        Components.hour = Hour
        Components.minute = Minute
        Components.second = Second
        return Cal.date(from: Components)
    }
    
    /// Create a date with the given components. The time is set to 00:00:00.
    /// - Year: The year of the date.
    /// - Month: The month of the date.
    /// - Day: The day of the date.
    public static func DateFactory(Year: Int, Month: Int, Day: Int) -> Date?
    {
        return Date.DateFactory(Year: Year, Month: Month, Day: Day, Hour: 0, Minute: 0, Second: 0)
    }
    
    /// Determines if a given year is a leap year.
    /// - Parameter Year: The year to determine for leap yearness.
    /// - Returns: True if the passed year is a leap year, false if not.
    public static func IsLeapYear(_ Year: Int) -> Bool
    {
        if Year % 400 == 0
        {
            return true
        }
        if Year % 100 == 0
        {
            return false
        }
        if Year % 4 == 0
        {
            return true
        }
        return false
    }
    
    /// Convert a local date to UTC.
    /// - Returns: UTC date equivalent of the instance local date.
    func ToUTC() -> Date
    {
        let TZ = TimeZone.current
        let Seconds = -TimeInterval(TZ.secondsFromGMT(for: self))
        return Date(timeInterval: Seconds, since: self)
    }
    
    /// Convert a UTC date to a local date.
    /// - Returns: Local date equivalent of the instance UTC date.
    func ToLocal() -> Date
    {
        let TZ = TimeZone.current
        let Seconds = TimeInterval(TZ.secondsFromGMT(for: self))
        return Date(timeInterval: Seconds, since: self)
    }
    
    static func SecondsToTime(_ SourceSeconds: Int) -> (Hour: Int, Minute: Int, Second: Int)
    {
        let Hours = SourceSeconds / (60 * 60)
        let Minutes = (SourceSeconds - (Hours * 60 * 60)) / 60
        let Seconds = SourceSeconds - ((Hours * 60 * 60) + (Minutes * 60))
        return (Hours, Minutes, Seconds)
    }
    
    /// Return a date (only the time components are valid) based on the percent of a day that
    /// has passed.
    /// - Parameter Percent: Percent of a day that has passed. Used to calculate the time.
    /// - Parameter WithOffset: Offset value.
    /// - Returns: Date structure with only the time components being valid.
    static func DateFrom(Percent: Double, WithOffset: Int = 0) -> Date
    {
        var Components = DateComponents()
        let Current = Int(abs((24 * 60 * 60) * Percent) - 1)
        let Hours = Current / (60 * 60)
        let Minutes = (Current - (Hours * 60 * 60)) / 60
        let Seconds = Current - ((Hours * 60 * 60) + (Minutes * 60))
        Components.hour = Hours
        Components.minute = Minutes
        Components.second = Seconds
        Components.year = 2020
        Components.month = 4
        Components.day = 12
        let Cal = Calendar(identifier: .gregorian)
        let D = Cal.date(from: Components)
        return D!
    }
    
    static func PrettyTime(From: Date) -> String
    {
        let Cal = Calendar.current
        let Hour = Cal.component(.hour, from: From)
        let Minute = Cal.component(.minute, from: From)
        let Second = Cal.component(.second, from: From)
        var HourS = "\(Hour)"
        if Hour < 10
        {
            HourS = " " + HourS
        }
        var MinuteS = "\(Minute)"
        if Minute < 10
        {
            MinuteS = "0" + MinuteS
        }
        var SecondS = "\(Second)"
        if Second < 10
        {
            SecondS = "0" + SecondS
        }
        return "\(HourS):\(MinuteS):\(SecondS)"
    }
    
    func PrettyTime() -> String
    {
        return Date.PrettyTime(From: self)
    }
    
    func GetTimeZone() -> TimeZone?
    {
        let Cal = Calendar(identifier: .gregorian)
        let Components = Cal.dateComponents([.timeZone], from: self)
        let TZ = Components.timeZone
        return TZ
    }
    
    func AsSeconds() -> Int
    {
        let Cal = Calendar.current
        let Hour = Cal.component(.hour, from: self)
        let Minute = Cal.component(.minute, from: self)
        let Second = Cal.component(.second, from: self)
        return Second + (Minute * 60) + (Hour * 60 * 60)
    }
    
    public var Year: Int
    {
        get
        {
            let Cal = Calendar.current
            return Cal.component(.year, from: self)
        }
    }
    
    public var Month: Int
    {
        get
        {
            let Cal = Calendar.current
            return Cal.component(.month, from: self)
        }
    }
    
    public var Day: Int
    {
        get
        {
            let Cal = Calendar.current
            return Cal.component(.day, from: self)
        }
    }
    
    public var Hour: Int
    {
        get
        {
            let Cal = Calendar.current
            return Cal.component(.hour, from: self)
        }
    }
    
    public var Minute: Int
    {
        get
        {
            let Cal = Calendar.current
            return Cal.component(.minute, from: self)
        }
    }
    
    public var Second: Int
    {
        get
        {
            let Cal = Calendar.current
            return Cal.component(.second, from: self)
        }
    }
    
    public static func UnitDuration(_ SecondCount: Int) -> (Years: Int, Days: Int, Hours: Int, Minutes: Int, Seconds: Int)
    {
        var Working = SecondCount
        let YearCount = Working / SecondsIn(.Year)
        if YearCount > 0
        {
            Working = Working - (YearCount * SecondsIn(.Year))
        }
        let DayCount = Working / SecondsIn(.Day)
        if DayCount > 0
        {
            Working = Working - (DayCount * SecondsIn(.Day))
        }
        let HourCount = Working / SecondsIn(.Hour)
        if HourCount > 0
        {
            Working = Working - (HourCount * SecondsIn(.Hour))
        }
        let MinuteCount = Working / SecondsIn(.Minute)
        if MinuteCount > 0
        {
            Working = Working - (MinuteCount * SecondsIn(.Minute))
        }
        if Working > 59
        {
            fatalError("Too many seconds left over! (\(Working)")
        }
        return (YearCount, DayCount, HourCount, MinuteCount, Working)
    }
    
    public static func SecondsIn(_ Unit: TimeUnits) -> Int
    {
        switch Unit
        {
            case .Minute:
            return 60
            
            case .Hour:
            return 60 * 60
            
            case .Day:
            return 24 * 60 * 60
            
            case .Year:
            return 365 * 24 * 60 * 60
        }
    }
}

public enum TimeUnits
{
    case Year
    case Day
    case Hour
    case Minute
}
