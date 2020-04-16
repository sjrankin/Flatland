//
//  MapSettings.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/16/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class MapSettings: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        PolarSwitch.isOn = Settings.ShowPolarCircles()
        EquatorSwitch.isOn = Settings.ShowEquator()
        TropicSwitch.isOn = Settings.ShowTropics()
        PrimeMeridianSwitch.isOn = Settings.ShowPrimeMeridians()
        NoonMeridianSwitch.isOn = Settings.ShowNoonMeridians()
        
        FlatlandMapPicker.layer.borderColor = UIColor.black.cgColor
        GlobeMapPicker.layer.borderColor = UIColor.black.cgColor
        
        GlobeMapPicker.reloadAllComponents()
        FlatlandMapPicker.reloadAllComponents()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView
        {
            case GlobeMapPicker:
                return Settings.GlobeMapList.count
            
            case FlatlandMapPicker:
                return Settings.FlatMapList.count
            
            default:
                return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch pickerView
        {
            case GlobeMapPicker:
                let MapType = MapTypes.allCases[row]
                return Settings.GlobeMapList[MapType]
            
            case FlatlandMapPicker:
                let MapType = MapTypes.allCases[row]
                return Settings.FlatMapList[MapType]
            
            default:
                return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        switch pickerView
        {
            case FlatlandMapPicker:
                let MapType = MapTypes.allCases[row]
                let SelectedMapType = MapType
            
            case GlobeMapPicker:
                let MapType = MapTypes.allCases[row]
                let SelectedMapType = MapType
            
            default:
                return
        }
    }
    
    @IBAction func HandleGridSwitchChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            switch Switch
            {
                case NoonMeridianSwitch:
                    Settings.SetNoonMeridians(Switch.isOn)
                
                case EquatorSwitch:
                    Settings.SetEquator(Switch.isOn)
                
                case TropicSwitch:
                    Settings.SetTropics(Switch.isOn)
                
                case PolarSwitch:
                    Settings.SetPolarCircles(Switch.isOn)
                
                case PrimeMeridianSwitch:
                    Settings.SetPrimeMeridians(Switch.isOn)
                
                default:
                    break
            }
        }
    }
    
    @IBOutlet weak var NoonMeridianSwitch: UISwitch!
    @IBOutlet weak var PrimeMeridianSwitch: UISwitch!
    @IBOutlet weak var PolarSwitch: UISwitch!
    @IBOutlet weak var TropicSwitch: UISwitch!
    @IBOutlet weak var EquatorSwitch: UISwitch!
    @IBOutlet weak var FlatlandMapPicker: UIPickerView!
    @IBOutlet weak var GlobeMapPicker: UIPickerView!
}
