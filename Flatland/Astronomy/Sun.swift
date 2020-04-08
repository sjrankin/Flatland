//
//  Sun.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Functions related to the sun's position.
class Sun
{
    /// Default initializer.
    /// - Note: If this initializer is called, unless you set `ClassLatitude`, `ClassLongitude`,
    ///         and `ClassTimeZoneOffset` manually, you will get a fatal error if you call the
    ///         incorrect version of `Sunrise` or `Sunset` (specifically those version that do not
    ///         pass the location).
    init()
    {
        ClassLatitude = nil
        ClassLongitude = nil
    }
    
    /// Initializer.
    /// - Parameter Location: The location whose relation to the location of the sun is resolved here.
    /// - Parameter Zenith: The zenith of the sky. Defaults to `90.833`.
    /// - Parameter Offset: Time zone offset in number of seconds from UT.
    init(Location: GeoPoint2, Zenith: Double = 90.833, Offset: Int)
    {
        self.Zenith = Zenith
        ClassTimeZoneOffset = Offset
        ClassLatitude = Location.Latitude
        ClassLongitude = Location.Longitude
    }
    
    var ClassLatitude: Double? = nil
    var ClassLongitude: Double? = nil
    var Zenith: Double = 90.83
    var ClassTimeZoneOffset: Int? = nil
    
    /// "Normalizes" the passed value between 0.0 and `Max`.
    /// - Parameter Value: The value to normalized.
    /// - Parameter Max: The maximum value returned.
    /// - Returns: A value between 0.0 and `Max`.
    func Normalize(_ Value: Double, Max: Double) -> Double
    {
        var Working = Value
        if Value < 0
        {
            Working = Working + Max
        }
        if Value > Max
        {
            Working = Working - Max
        }
        return Working
    }
    
    /// Calculate the sunrise of sunset time for the passed date and location.
    /// - Note: See [Sunrise/sunset times in C](https://stackoverflow.com/questions/7064531/sunrise-sunset-times-in-c)
    /// - Parameter TargetDate: The date used to calculate sunrise/sunset times. Only the `.day`, `.month`,
    ///                         and `.year` components are used.
    /// - Parameter Latitude: The latitude of the location.
    /// - Parameter Longitude: the longitude of the location.
    /// - Parameter Offset: The location's timezone offset in number of seconds. For example, JST
    ///                     has an offset of +9 - this value should be passed as 60 * 60 * 9. Timezones
    ///                     in the western hemisphere will have negative offsets.
    /// - Parameter ForRise: If true, the sunrise time will be returned. If false, the sunset time
    ///                      will be returned.
    /// - Returns: The adjusted (for timezone offset) time for either sunrise or sunset (see `ForRise`).
    ///            If nil is returned, there is no sunset or sunrise, depending on the value of
    ///            `ForRise` - in other words, if you pass `true` in `ForRise` and nil is returned,
    ///            there was no sunrise on the given date at the given location.
    func SunriseSunset(_ TargetDate: Date, Latitude: Double, Longitude: Double, Offset: Int, ForRise: Bool = true) -> Date?
    {
        var Cal = Calendar(identifier: .gregorian)
        Cal.timeZone = TimeZone(identifier: "UTC")!
        guard let NI = Cal.ordinality(of: .day, in: .year, for: TargetDate) else
        {
            return nil
        }
        let N: Double = Double(NI)
        let RadLatitude = Latitude.Radians
        let RadZenith = Zenith.Radians
        
        let LongitudeHour = Longitude / 15.0
        var t: Double = 0.0
        if ForRise
        {
            t = N + ((6.0 - LongitudeHour) / 24.0)
        }
        else
        {
            t = N + ((18.0 - LongitudeHour) / 24.0)
        }
        
        let MeanAnomaly: Double = (0.9856 * t) - 3.289
        let MA = MeanAnomaly.Radians
        
        let L1 = 1.916 * sin(MA)
        let L2 = 0.020 * sin(2.0 * MA)
        var L = MeanAnomaly + L1 + L2 + 282.634
        L = Normalize(L, Max: 360.0)
        
        var RA = atan(0.91764 * tan(L.Radians)).Degrees
        RA = Normalize(RA, Max: 360.0)
        let LQuad = floor(L / 90.0) * 90.0
        let RAQuad = floor(RA / 90.0) * 90.0
        RA = RA + (LQuad - RAQuad)
        RA = RA / 15.0
        
        let SinDec: Double = 0.39782 * sin(L.Radians)
        let CosDec: Double = cos(asin(SinDec))
        
        let CosH = (cos(RadZenith) - (SinDec * sin(RadLatitude))) / (CosDec * cos(RadLatitude))
        if ForRise
        {
            if CosH > 1.0
            {
                print("CosH=\(CosH): No sun rise.")
                return nil
            }
        }
        else
        {
            if CosH < -1.0
            {
                print("CosH=\(CosH): No sun set.")
                return nil
            }
        }
        
        var H: Double = 360.0 - acos(CosH).Degrees
        if !ForRise
        {
            H = acos(CosH).Degrees
        }
        H = H / 15
        
        let T: Double = H + RA - (0.06571 * t) - 6.622
        let UT = Normalize(T - LongitudeHour, Max: 24.0)
        
        let Hour = floor(UT)
        let Minute = floor((UT - Hour) * 60.0)
        let Second = (((UT - Hour) * 60) - Minute) * 60.0
        let IsYesterday = LongitudeHour > 0 && UT > 12 && ForRise
        let IsTomorrow = LongitudeHour < 0 && UT < 12 && !ForRise
        
        var SetDate: Date = Date()
        if IsYesterday
        {
            SetDate = Date(timeInterval: -(60 * 60 * 24), since: Date())
        }
        else
            if IsTomorrow
            {
                SetDate = Date(timeInterval: (60 * 60 * 24), since: Date())
        }
        var Components = Cal.dateComponents([.day, .month, .year], from: SetDate)
        Components.hour = Int(Hour)
        Components.minute = Int(Minute)
        Components.second = Int(Second)
        Cal.timeZone = TimeZone(identifier: "UTC")!
        let AlmostFinal = Cal.date(from: Components)
        return Date(timeInterval: 60 * 60 * Double(Offset), since: AlmostFinal!)
    }
    
    /// Returns the sunrise time for the passed location and date.
    /// - Parameter For: The date used to calculate the sunrise at the passed location.
    /// - Parameter At: The location where the sunrise time will be calculated.
    /// - Parameter TimeZoneOffset: Number of seconds that represents the timezone offset for the
    ///             location with positive values for the eastern hemisphere and negative values
    ///             for the western hemisphere.
    /// - Returns: The time (only the time components are valid) for sunrise given the passed
    ///            parameters. If nil is returned, there was no sunrise at that location and date.
    func Sunrise(For TargetDate: Date, At Location: GeoPoint2, TimeZoneOffset: Int) -> Date?
    {
        return SunriseSunset(TargetDate, Latitude: Location.Latitude, Longitude: Location.Longitude, Offset: TimeZoneOffset, ForRise: true)
    }
    
    /// Returns the sunset time for the passed location and date.
    /// - Parameter For: The date used to calculate the sunset at the passed location.
    /// - Parameter At: The location where the sunset time will be calculated.
    /// - Parameter TimeZoneOffset: Number of seconds that represents the timezone offset for the
    ///             location with positive values for the eastern hemisphere and negative values
    ///             for the western hemisphere.
    /// - Returns: The time (only the time components are valid) for sunset given the passed
    ///            parameters. If nil is returned, there was no sunset at that location and date.
    func Sunset(For TargetDate: Date, At Location: GeoPoint2, TimeZoneOffset: Int) -> Date?
    {
        return SunriseSunset(TargetDate, Latitude: Location.Latitude, Longitude: Location.Longitude, Offset: TimeZoneOffset, ForRise: false)
    }
    
    /// Returns the sunrise for the previously set (via the initializer or by setting the `ClassLatitude`
    /// `ClassLongitude`, **and** `ClassTimeZoneOffset` manually) location.
    /// - Warning: If any of `ClassLatitude`, `ClassLongitude`, of `ClassTimeZoneOffset` is nil, a
    ///            fatal error will be generated.
    /// - Parameter For: The date whose sunrise will be returned.
    /// - Returns: The time for the sunrise in the previously set location. If nil, no sunrise at that
    ///            location on the passed date.
    func Sunrise(For TargetDate: Date) -> Date?
    {
        if ClassLatitude == nil || ClassLongitude == nil || ClassTimeZoneOffset == nil
        {
            fatalError("Location not set for sunrise.")
        }
        return Sunrise(For: TargetDate, At: GeoPoint2(ClassLatitude!, ClassLongitude!), TimeZoneOffset: ClassTimeZoneOffset!)
    }
    
    /// Returns the sunset for the previously set (via the initializer or by setting the `ClassLatitude`
    /// `ClassLongitude`, **and** `ClassTimeZoneOffset` manually) location.
    /// - Warning: If any of `ClassLatitude`, `ClassLongitude`, of `ClassTimeZoneOffset` is nil, a
    ///            fatal error will be generated.
    /// - Parameter For: The date whose sunset will be returned.
    /// - Returns: The time for the sunset in the previously set location. If nil, no sunset at that
    ///            location on the passed date.
    func Sunset(For TargetDate: Date) -> Date?
    {
        if ClassLatitude == nil || ClassLongitude == nil || ClassTimeZoneOffset == nil
        {
            fatalError("Location not set for sunset.")
        }
        return Sunset(For: TargetDate, At: GeoPoint2(ClassLatitude!, ClassLongitude!), TimeZoneOffset: ClassTimeZoneOffset!)
    }
    
    /// Return the number of seconds for the `.Second`, `.Minute`, and `.Hour` components of the
    /// passed date.
    /// - Parameter Value: The date whose time components are returned as seconds.
    /// - Returns: Number of seconds in the time components of the passed date.
    func SecondsInDate(_ Value: Date) -> Int
    {
        let Cal = Calendar.current
        let Seconds = Cal.component(.second, from: Value)
        let Minutes = Cal.component(.minute, from: Value)
        let Hours = Cal.component(.hour, from: Value)
        return Seconds + (Minutes * 60) + (Hours * 60 * 60)
    }
    
    /// Returns the length of the day based on the passed sunrise and sunset times. If both parameters
    /// are nil, 0 is returned.
    /// - Parameter Sunrise: The sunrise time. Only the time portion is used. If this parameter is
    ///                      nil, the sunrise is treated as midnight.
    /// - Parameter sunset: The sunset time. Only the time portion is used. If this parameter is
    ///                     nil, the sunset is treated as midnight.
    /// - Returns: Number of seconds the sun is visible during the day.
    func DaylightTime(Sunrise: Date?, Sunset: Date?) -> Int
    {
        if Sunrise == nil && Sunset == nil
        {
            return 0
        }
        var StartSecond = 0
        if Sunrise != nil
        {
            StartSecond = SecondsInDate(Sunrise!)
        }
        var SecondEnd = SecondsInDay
        if Sunset != nil
        {
            SecondEnd = SecondsInDate(Sunset!)
        }
        return SecondEnd - StartSecond
    }
    
    /// Returns the percent of day the sunrise and sunset occured.
    /// - Parameter Sunrise: The time of the sunrise (only the time components are used). If nil, there
    ///                      was no sunrise so sunrise is treated as midnight.
    /// - Parameter Sunset: The time of the sunset (only the time components are used). If nil, there
    ///                      was no sunset so sunrise is treated as midnight.
    /// Returns: Tuple with the sunrise percent and sunset percent. If both `Sunrise` and `Sunset` are
    ///          nil, `(0.0, 0.0)` is returned indicating no sunrise or no sunset (eg, polar darkness during
    ///          the local winter).
    func SunPercents(Sunrise: Date?, Sunset: Date?) -> (Double, Double)?
    {
        if Sunrise == nil && Sunset == nil
        {
            return (0.0, 0.0)
        }
        let SunriseSeconds = Sunrise == nil ? 0 : SecondsInDate(Sunrise!)
        let SunsetSeconds = Sunset == nil ? SecondsInDay : SecondsInDate(Sunset!)
        return (Double(SunriseSeconds) / Double(SecondsInDay), Double(SunsetSeconds) / Double(SecondsInDay))
    }
    
    let SecondsInDay = 24 * 60 * 60
}

extension Double
{
    var Radians: Double
    {
        get
        {
            return self * Double.pi / 180.0
        }
    }
    
    var Degrees: Double
    {
        get
        {
            return self * 180.0 / Double.pi
        }
    }
}