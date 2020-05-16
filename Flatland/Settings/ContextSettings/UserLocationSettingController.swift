//
//  UserLocationSettingController.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class UserLocationSettingController: UITableViewController, CLLocationManagerDelegate,
    UIPickerViewDelegate, UIPickerViewDataSource
{
    // MARK: - Initialization
    
    public weak var ParentDelegate: ChildClosed? = nil
    var LocationManager = CLLocationManager()
    var IsDirty = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
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
        switch Settings.ShowHomeLocation()
        {
            case .ShowAsArrow:
                HomeStyleSegment.selectedSegmentIndex = 0
            
            case .ShowAsFlag:
                HomeStyleSegment.selectedSegmentIndex = 1
            
            case .Hide:
                HomeStyleSegment.selectedSegmentIndex = 2
            
            default:
                break
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        ParentDelegate?.ChildWindowClosed(IsDirty)
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Time zone handling.
    
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
        IsDirty = true
    }
    
    // MARK: - GPS location determination
    
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
        IsDirty = true
    }
    
    // MARK: - Handle manual entry of latitude and longitude.
    
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
                IsDirty = true
            }
            else
            {
                let OldTextBG = UIColor.white
                TextField.textColor = UIColor.yellow
                TextField.backgroundColor = UIColor.red
                UIView.animate(withDuration: 0.5,
                               animations:
                    {
                        TextField.textColor = UIColor.black
                        TextField.backgroundColor = OldTextBG
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
                IsDirty = true
            }
            else
            {
                let OldTextBG = UIColor.white
                TextField.textColor = UIColor.yellow
                TextField.backgroundColor = UIColor.red
                UIView.animate(withDuration: 0.5,
                               animations:
                    {
                        TextField.textColor = UIColor.black
                        TextField.backgroundColor = OldTextBG
                })
            }
        }
    }
    
    // MARK: - General location button handling.
    
    @IBAction func HandleRemoveLocation(_ sender: Any)
    {
        let Alert = UIAlertController(title: "Clear Current Location",
                                      message: "Do you really want to clear your current location?",
                                      preferredStyle: .alert)
        Alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler:
            {
                _ in
                Settings.ClearLocalLocation()
                self.LocalLatitudeBox.text = ""
                self.LocalLongitudeBox.text = ""
                self.TimeZonePicker.selectRow(12, inComponent: 0, animated: true)
                self.IsDirty = true
        }))
        Alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(Alert, animated: true)
    }
    
    @IBAction func HandleHomeLocationStyleChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            switch Segment.selectedSegmentIndex
            {
                case 0:
                    Settings.SetShowHomeLocation(.ShowAsArrow)
                
                case 1:
                    Settings.SetShowHomeLocation(.ShowAsFlag)
                
                case 2:
                    Settings.SetShowHomeLocation(.Hide)
                
                default:
                    break
            }
            IsDirty = true
        }
    }
    
    // MARK: Interface builder outlets.
    
    @IBOutlet weak var HomeStyleSegment: UISegmentedControl!
    @IBOutlet weak var TimeZonePicker: UIPickerView!
    @IBOutlet weak var LocalLongitudeBox: UITextField!
    @IBOutlet weak var LocalLatitudeBox: UITextField!
    @IBOutlet weak var RemoveLocationButton: UIButton!
    @IBOutlet weak var GetLocationButton: UIButton!
}
