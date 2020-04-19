//
//  CitySelectorView.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class CitySelectorView: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource,
    CLLocationManagerDelegate
{
    var LocationManager = CLLocationManager()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ShowWorldCitiesSwitch.isOn = Settings.ShowWorldCities100()
        ShowAfricanCitiesSwitch.isOn = Settings.ShowAfricanCities100()
        ShowAsianCitiesSwitch.isOn = Settings.ShowAsianCities100()
        ShowEuropeanCitiesSwitch.isOn = Settings.ShowEuropeanCities100()
        ShowNorthAmericanSwitch.isOn = Settings.ShowNorthAmericanCities100()
        ShowSouthAmericanSwitch.isOn = Settings.ShowSouthAmericanCities100()
        ShowCapitalCitiesSwitch.isOn = Settings.ShowCapitalCities()
        ShowUserLocationsSwitch.isOn = Settings.ShowUserLocations()
        if let Lat = Settings.GetLocalLatitude()
        {
            LocalLatitudeBox.text = "\(Lat)"
        }
        else
        {
            LocalLatitudeBox.text = ""
        }
        if let Lon = Settings.GetLocalLongitude()
        {
            LocalLongitudeBox.text = "\(Lon)"
        }
        else
        {
            LocalLongitudeBox.text = ""
        }
        TimeZonePicker.layer.borderColor = UIColor.black.cgColor
        TimeZonePicker.layer.borderWidth = 0.5
        TimeZonePicker.layer.cornerRadius = 5.0
        MakeTimeZoneList()
        let LocalOffset = Settings.GetLocalTimeZoneOffset()
        for Index in 0 ..< TimeZones.count
        {
            if TimeZones[Index] == LocalOffset
            {
                TimeZonePicker.selectRow(Index, inComponent: 0, animated: true)
                break
            }
        }
        #if os(macOS)
        GetLocationButton.isHidden = true
        #endif
    }
    
    func MakeTimeZoneList()
    {
        for Offset in -12 ... 14
        {
            TimeZones.append(Offset)
        }
    }
    
    var TimeZones = [Int]()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return TimeZones.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        let Label = "\(TimeZones[row])"
        return Label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let NewOffset = TimeZones[row]
        Settings.SetLocalTimeZoneOffset(NewOffset)
    }
    
    @IBAction func HandleShow100CitiesChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetWorldCities100(Switch.isOn)
        }
    }
    
    @IBAction func HandleShowAfrica100Changed(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetAfricanCities100(Switch.isOn)
        }
    }
    
    @IBAction func HandleShowAsia100Changed(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetAsianCities100(Switch.isOn)
        }
    }
    
    @IBAction func HandleShowEurope100Changed(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetEuropeanCities100(Switch.isOn)
        }
    }
    
    @IBAction func HandleShowNorthAmerica100Changed(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetNorthAmericanCities100(Switch.isOn)
        }
    }
    
    @IBAction func HandleShowSouthAmerica100Changed(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetSouthAmericanCities100(Switch.isOn)
        }
    }
    
    @IBAction func HandleShowCapitalCitiesChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetCapitalCities(Switch.isOn)
        }
    }
    
    @IBAction func HandleShowUserLocationsChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetUserLocations(Switch.isOn)
        }
    }
    
    @IBAction func HandleFindLocation(_ sender: Any)
    {
        LocationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled()
        {
            LocationManager.delegate = self
            LocationManager.desiredAccuracy = kCLLocationAccuracyBest
            LocationManager.startUpdatingLocation()
            GetLocationButton.isEnabled = false
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        guard let Location = manager.location?.coordinate else
        {
            return
        }
        LocalLongitudeBox.text = "\(Location.longitude.RoundedTo(4))"
        LocalLatitudeBox.text = "\(Location.latitude.RoundedTo(4))"
        LocationManager.stopUpdatingLocation()
        GetLocationButton.isEnabled = true
        Settings.SetLocalLatitude(Location.latitude.RoundedTo(4))
        Settings.SetLocalLongitude(Location.longitude.RoundedTo(4))
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        LocationManager.stopUpdatingLocation()
        super.viewWillAppear(animated)
    }
    
    func ValidateLatitude(_ Raw: String?) -> Bool
    {
        if let RawValue = Raw
        {
            if let Lat = Double(RawValue)
            {
                if Lat < -90.0 || Lat > 90.0
                {
                    return false
                }
                return true
            }
        }
        return false
    }
    
    @IBAction func HandleLatitudeTextChanged(_ sender: Any)
    {
        if let TextField = sender as? UITextField
        {
            if ValidateLatitude(TextField.text)
            {
                let Raw = Double(TextField.text!)
                Settings.SetLocalLatitude(Raw!)
            }
            else
            {
                let OldTextBG = TextField.backgroundColor!
                TextField.textColor = UIColor.yellow
                TextField.backgroundColor = UIColor.red
                UIView.animate(withDuration: 0.5,
                               animations:
                    {
                        TextField.textColor = UIColor.black
                        TextField.backgroundColor = OldTextBG
                }, completion:
                    {
                        Completed in
                        if Completed
                        {
                            TextField.text = ""
                        }
                })
            }
        }
    }
    
    func ValidateLongitude(_ Raw: String?) -> Bool
    {
        if let RawValue = Raw
        {
            if let Lon = Double(RawValue)
            {
                if Lon < -180.0 || Lon > 180.0
                {
                    return false
                }
                return true
            }
        }
        return false
    }
    
    @IBAction func HandleLongitudeTextChanged(_ sender: Any)
    {
        if let TextField = sender as? UITextField
        {
            if ValidateLongitude(TextField.text)
            {
                let Raw = Double(TextField.text!)
                Settings.SetLocalLongitude(Raw!)
            }
            else
            {
                let OldTextBG = TextField.backgroundColor!
                TextField.textColor = UIColor.yellow
                TextField.backgroundColor = UIColor.red
                UIView.animate(withDuration: 0.5,
                               animations:
                    {
                        TextField.textColor = UIColor.black
                        TextField.backgroundColor = OldTextBG
                }, completion:
                    {
                        Completed in
                        if Completed
                        {
                            TextField.text = ""
                        }
                })
            }
        }
    }
    
    @IBOutlet weak var GetLocationButton: UIButton!
    @IBOutlet weak var TimeZonePicker: UIPickerView!
    @IBOutlet weak var LocalLongitudeBox: UITextField!
    @IBOutlet weak var LocalLatitudeBox: UITextField!
    @IBOutlet weak var ShowWorldCitiesSwitch: UISwitch!
    @IBOutlet weak var ShowAfricanCitiesSwitch: UISwitch!
    @IBOutlet weak var ShowAsianCitiesSwitch: UISwitch!
    @IBOutlet weak var ShowEuropeanCitiesSwitch: UISwitch!
    @IBOutlet weak var ShowNorthAmericanSwitch: UISwitch!
    @IBOutlet weak var ShowSouthAmericanSwitch: UISwitch!
    @IBOutlet weak var ShowCapitalCitiesSwitch: UISwitch!
    @IBOutlet weak var ShowUserLocationsSwitch: UISwitch!
}
