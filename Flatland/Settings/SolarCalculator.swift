//
//  SolarCalculator.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/2/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class SolarCalculator: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let UserLat = Settings.GetLocalLatitude()
        {
            if let UserLon = Settings.GetLocalLongitude()
            {
                let Offset = Settings.GetLocalTimeZoneOffset()
                PresetLocations.insert(("Current Location", UserLat, UserLon, Offset), at: 0)
            }
        }
        PresetLocationPicker.reloadAllComponents()
        TimezonePicker.reloadAllComponents()
        SunriseResult.text = ""
        SunsetResult.text = ""
        NoonResult.text = ""
                //TimezonePicker.selectRow(12, inComponent: 0, animated: true)
        PresetLocationPicker.selectRow(0, inComponent: 0, animated: true)
        let (_, FirstLat, FirstLon, Offset) = PresetLocations[0]
        if let FirstIndex = Timezones.firstIndex(of: Offset)
        {
            TimezonePicker.selectRow(FirstIndex, inComponent: 0, animated: true)
        }
        else
        {
            TimezonePicker.selectRow(12, inComponent: 0, animated: true)
        }
        LatitudeBox.text = "\(FirstLat)"
        LongitudeBox.text = "\(FirstLon)"
        SolarDatePicker.date = Date()
        NoonResult.text = ""
        SunriseResult.text = ""
        SunsetResult.text = ""
        DaytimeResult.text = ""
        NighttimeResult.text = ""
        SolarDatePicker.layer.borderColor = UIColor.black.cgColor
        SolarDatePicker.layer.borderWidth = 0.5
        SolarDatePicker.layer.cornerRadius = 5.0
        TimezonePicker.layer.borderColor = UIColor.black.cgColor
        TimezonePicker.layer.borderWidth = 0.5
        TimezonePicker.layer.cornerRadius = 5.0
        PresetLocationPicker.layer.borderColor = UIColor.black.cgColor
        PresetLocationPicker.layer.borderWidth = 0.5
        PresetLocationPicker.layer.cornerRadius = 5.0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView
        {
            case PresetLocationPicker:
                return PresetLocations.count
            
            case TimezonePicker:
                return Timezones.count
            default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch pickerView
        {
            case PresetLocationPicker:
                let (Name, _, _, _) = PresetLocations[row]
                return Name
            
            case TimezonePicker:
                let Value = Timezones[row]
                var Prefix = ""
                if Value > 0
                {
                    Prefix = "+"
                }
                return "\(Prefix)\(Value)"
            
            default:
                return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        switch pickerView
        {
            case PresetLocationPicker:
                let (_, Lat, Lon, Offset) = PresetLocations[row]
                LatitudeBox.text = "\(Lat)"
                LongitudeBox.text = "\(Lon)"
                let OffsetIndex = Timezones.firstIndex(of: Offset)!
                TimezonePicker.selectRow(OffsetIndex, inComponent: 0, animated: true)
            
            default:
                return
        }
    }
    
    func IsValidCoordinate(In TextBox: UITextField) -> Bool
    {
        if let Raw = TextBox.text
        {
            if let _ = Double(Raw)
            {
                return true
            }
        }
        return false
    }
    
    func LocationValid() -> Bool
    {
        return IsValidCoordinate(In: LatitudeBox) && IsValidCoordinate(In: LongitudeBox)
    }
    
    func GetCoordinate(From TextField: UITextField) -> Double
    {
        if let Raw = TextField.text
        {
            if let RawValue = Double(Raw)
            {
                return RawValue
            }
        }
        fatalError("Unexpected bad value in text field.")
    }
    
    func GetLocation() -> (Latitude: Double, Longitude: Double)
    {
        let Lat = GetCoordinate(From: LatitudeBox)
        let Lon = GetCoordinate(From: LongitudeBox)
        return (Lat, Lon)
    }
    
    @IBAction func HandleCalculateButtonPressed(_ sender: Any)
    {
        if !LocationValid()
        {
            return
        }
        let TimezoneIndex = TimezonePicker.selectedRow(inComponent: 0)
        let Timezone = Timezones[TimezoneIndex]
        let PreSolarDate = SolarDatePicker.date
        let Cal = Calendar.current
        let Day = Cal.component(.day, from: PreSolarDate)
        let Month = Cal.component(.month, from: PreSolarDate)
        let Year = Cal.component(.year, from: PreSolarDate)
        var Components = DateComponents()
        Components.day = Day
        Components.month = Month
        Components.year = Year
        let SolarDate = Cal.date(from: Components)
        let (CurrentLatitude, CurrentLongitude) = GetLocation()
        let Location = GeoPoint2(CurrentLatitude, CurrentLongitude)
        let SunCalc = Sun()
        var AbsoluteSunrise = 0
        var AbsoluteSunset = 24 * 60 * 60
        let index = PresetLocationPicker.selectedRow(inComponent: 0)
        print("Calculating solar times for \"\(PresetLocations[index].0)\"")
        #if true
        if let SunriseSeconds = SunCalc.SunriseAsSeconds(For: SolarDate!, At: Location, TimeZoneOffset: Timezone)
        {
            AbsoluteSunrise = SunriseSeconds
            let WorkingSunrise = AbsoluteSunrise
            //AbsoluteSunrise = abs(SunriseSeconds + (Timezone * 60 * 60))
            //let WorkingSunrise = AbsoluteSunrise % (24 * 60 * 60)
            let (Hours, Minutes, Seconds) = Date.SecondsToTime(WorkingSunrise)
            var Final = "\(Hours):"
            if Minutes < 10
            {
                Final.append("0")
            }
            Final.append("\(Minutes):")
            if Seconds < 10
            {
                Final.append("0")
            }
            Final.append("\(Seconds)")
            SunriseResult.text = Final
        }
        else
        {
            SunriseResult.text = "No rise"
        }
        if let SunsetSeconds = SunCalc.SunsetAsSeconds(For: SolarDate!, At: Location, TimeZoneOffset: Timezone)
        {
            //AbsoluteSunset = abs(SunsetSeconds + (Timezone * 60 * 60))
            //if AbsoluteSunset < AbsoluteSunrise
            //{
            //    AbsoluteSunset = AbsoluteSunset + 24 * 60 * 60
            //}
            //AbsoluteSunset = AbsoluteSunset % (24 * 60 * 60)
            AbsoluteSunset = SunsetSeconds
            let (Hours, Minutes, Seconds) = Date.SecondsToTime(AbsoluteSunset)
            var Final = "\(Hours):"
            if Minutes < 10
            {
                Final.append("0")
            }
            Final.append("\(Minutes):")
            if Seconds < 10
            {
                Final.append("0")
            }
            Final.append("\(Seconds)")
            SunsetResult.text = Final
        }
        else
        {
            SunsetResult.text = "No set"
        }
        let DayDuration = abs(AbsoluteSunrise - AbsoluteSunset)
        let NightDuration = abs(DayDuration - 24 * 60 * 60)
        let NoonTimeSeconds = (DayDuration / 2) + AbsoluteSunrise
        let NoonTime = Date.DateFrom(Percent: Double(NoonTimeSeconds) / Double(24 * 60 * 60))
        NoonResult.text = "\(NoonTime.PrettyTime())"
        let DayString = Date.PrettyTimeParts(From: DayDuration)
        let NightString = Date.PrettyTimeParts(From: NightDuration)
        DaytimeResult.text = DayString
        NighttimeResult.text = NightString
        #else
        var SunRTime: Date = Date.DateFrom(Percent: 0.0)
        var SunSTime: Date = Date.DateFrom(Percent: 1.0)
        if let SunriseTime = SunCalc.Sunrise(For: SolarDate!, At: Location, TimeZoneOffset: Timezone)
        {
            print("  Sunrise[\(SunriseTime)] local: \(SunriseTime.ToLocal()), UTC: \(SunriseTime.ToUTC())")
            SunriseResult.text = "\(SunriseTime.PrettyTime())"
            SunRTime = SunriseTime
        }
        else
        {
            SunriseResult.text = "No rise"
        }
        if let SunsetTime = SunCalc.Sunset(For: SolarDate!, At: Location, TimeZoneOffset: Timezone)
        {
           print("  Sunset[\(SunsetTime)] local: \(SunsetTime.ToLocal()), UTC: \(SunsetTime.ToUTC())\n")
            SunsetResult.text = "\(SunsetTime.PrettyTime())"
            SunSTime = SunsetTime
        }
        else
        {
            SunsetResult.text = "No set"
        }
            let DayDuration = abs(SunSTime.AsSeconds() - SunRTime.AsSeconds())
        let NightDuration = abs(DayDuration - 24 * 60 * 60)
            let NoonTimeSeconds = (DayDuration / 2) + SunRTime.AsSeconds()
            let NoonTime = Date.DateFrom(Percent: Double(NoonTimeSeconds) / Double(24 * 60 * 60))
            NoonResult.text = "\(NoonTime.PrettyTime())"
        let DayString = Date.PrettyTimeParts(From: DayDuration)
        let NightString = Date.PrettyTimeParts(From: NightDuration)
        DaytimeResult.text = DayString
        NighttimeResult.text = NightString
        #endif
    }
    
    @IBAction func HandleLatitudeChanged(_ sender: Any)
    {
        if let TextField = sender as? UITextField
        {
            if !IsValidCoordinate(In: TextField)
            {
                TextField.backgroundColor = UIColor.red
                UIView.animate(withDuration: 1.0,
                               animations:
                    {
                        TextField.backgroundColor = UIColor.white
                })
            }
        }
    }
    
    @IBAction func HandleLongitudeChanged(_ sender: Any)
    {
        if let TextField = sender as? UITextField
        {
            if !IsValidCoordinate(In: TextField)
            {
                TextField.backgroundColor = UIColor.red
                UIView.animate(withDuration: 1.0,
                               animations:
                    {
                        TextField.backgroundColor = UIColor.white
                })
            }
        }
    }
    
    var Timezones = [12,11,10,9,8,7,6,5,4,3,2,1,0,-1,-2,-3,-4,-5,-6,-7,-8,-9,-10,-11]
    
    var PresetLocations: [(String, Double, Double, Int)] =
    [
        ("London", 51.5074, -0.1278, 0),
        ("Paris", 48.8566, 2.3522, 1),
        ("Amsterdam", 52.3667, 4.8945, 1),
        ("Cape Town", -33.9249, 18.4241, 2),
        ("Tokyo", 35.6762, 139.6503, 9),
        ("Canberra", -35.2809, 179.13, 10),
        ("Sydney", -33.8668, 151.2093, 10),
        ("San Francisco", 37.7749, -122.4194, -8),
        ("Santiago", -33.4489, -70.6693, -3),
        ("Quito", -0.1807, -78.4678, -5),
        ("New York", 40.7128, -74.006, -4),
        ("Moscow", 55.7558, 37.6173, 3),
        ("Cairo", 30.0444, 31.2357, 2)
    ]
    
    @IBOutlet weak var NighttimeResult: UILabel!
    @IBOutlet weak var DaytimeResult: UILabel!
    @IBOutlet weak var NoonResult: UILabel!
    @IBOutlet weak var SunsetResult: UILabel!
    @IBOutlet weak var SunriseResult: UILabel!
    @IBOutlet weak var LongitudeBox: UITextField!
    @IBOutlet weak var LatitudeBox: UITextField!
    @IBOutlet weak var SolarDatePicker: UIDatePicker!
    @IBOutlet weak var PresetLocationPicker: UIPickerView!
    @IBOutlet weak var TimezonePicker: UIPickerView!
    
}
