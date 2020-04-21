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
    public weak var ChangeDelegate: SomethingChanged? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        PolarSwitch.isOn = Settings.ShowPolarCircles()
        EquatorSwitch.isOn = Settings.ShowEquator()
        TropicSwitch.isOn = Settings.ShowTropics()
        PrimeMeridianSwitch.isOn = Settings.ShowPrimeMeridians()
        NoonMeridianSwitch.isOn = Settings.ShowNoonMeridians()
        MinorGridSwitch.isOn = Settings.ShowMinorGridLines()
        var Gap = Settings.GetMinorGridLineGap()
        if Gap == 0.0
        {
            Gap = 15.0
            Settings.SetMinorGridLineGap(Gap)
        }
        if !ValidGaps.contains(Gap)
        {
            Gap = 15.0
        }
        if let GapIndex = ValidGaps.firstIndex(of: Gap)
        {
            GapSegment.selectedSegmentIndex = GapIndex
        }
        else
        {
            GapSegment.selectedSegmentIndex = 1
        }
        
        FlatlandMapPicker.layer.borderColor = UIColor.black.cgColor
        GlobeMapPicker.layer.borderColor = UIColor.black.cgColor
        
        GlobeMapPicker.reloadAllComponents()
        FlatlandMapPicker.reloadAllComponents()
    }
    
    let ValidGaps = [5.0, 15.0, 30.0, 45.0]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView
        {
            case GlobeMapPicker:
                return MapManager.GlobeMapList.count
            
            case FlatlandMapPicker:
                return MapManager.FlatMapList.count
            
            default:
                return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch pickerView
        {
            case GlobeMapPicker:
                return MapManager.GlobeMapList[row].rawValue
            
            case FlatlandMapPicker:
                return MapManager.FlatMapList[row].rawValue
            
            default:
                return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        switch pickerView
        {
            case FlatlandMapPicker:
                let MapType = MapManager.FlatMapList[row]
                Settings.SetFlatlandMapType(MapType)
                ChangeDelegate?.Changed(Key: "FlatMap", Value: true as Any)
            
            case GlobeMapPicker:
                let MapType = MapManager.GlobeMapList[row]
                Settings.SetGlobeMapType(MapType)
                            ChangeDelegate?.Changed(Key: "RoundMap", Value: true as Any)
            
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
                
                case MinorGridSwitch:
                    Settings.SetMinorGridLines(Switch.isOn)
                
                default:
                    break
            }
        }
    }
    
    @IBAction func HandleMinorGapChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            if Segment.selectedSegmentIndex > ValidGaps.count - 1
            {
                return
            }
            let Gap = ValidGaps[Segment.selectedSegmentIndex]
            Settings.SetMinorGridLineGap(Gap)
        }
    }
    
    @IBOutlet weak var GapSegment: UISegmentedControl!
    @IBOutlet weak var MinorGridSwitch: UISwitch!
    @IBOutlet weak var NoonMeridianSwitch: UISwitch!
    @IBOutlet weak var PrimeMeridianSwitch: UISwitch!
    @IBOutlet weak var PolarSwitch: UISwitch!
    @IBOutlet weak var TropicSwitch: UISwitch!
    @IBOutlet weak var EquatorSwitch: UISwitch!
    @IBOutlet weak var FlatlandMapPicker: UIPickerView!
    @IBOutlet weak var GlobeMapPicker: UIPickerView!
}
