//
//  Settings.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/26/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ProgramSettings: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource,
    SomethingChanged
{
    weak var Delegate: SettingsProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let Parent = self.parent as? SettingsNavigationViewer
        {
            Delegate = Parent.Delegate
        }
        if Delegate == nil
        {
            print("No delegate")
        }
        switch Settings.GetTimeLabel()
        {
            case .None:
                TimeLabelSegment.selectedSegmentIndex = 0
            
            case .UTC:
                TimeLabelSegment.selectedSegmentIndex = 1
            
            case .Local:
                TimeLabelSegment.selectedSegmentIndex = 2
        }
        switch Settings.GetImageCenter()
        {
            case .NorthPole:
                ImageCenterSegment.selectedSegmentIndex = 0
            
            case .SouthPole:
                ImageCenterSegment.selectedSegmentIndex = 1
        }

        ShowCitiesSwitch.isOn = Settings.ShowCities()
        TimePicker.date = Date()
        ShowLocalDataSwitch.isOn = Settings.GetShowLocalData()
        for Offset in -12 ... 12
        {
            Offsets.append(Offset)
        }
                DebugOffsetPicker.reloadAllComponents()
        if let Index = Offsets.firstIndex(where: {$0 == 0})
        {
        DebugOffsetPicker.selectRow(Index, inComponent: 0, animated: true)
        }
        DebugOffsetPicker.layer.borderColor = UIColor.black.cgColor
        DebugOffsetPicker.layer.borderWidth = 0.5
        DebugOffsetPicker.layer.cornerRadius = 5.0
    }
    
    var Offsets = [Int]()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        Offsets.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        var Offset = Offsets[row]
        let Sign = Offset < 0 ? "-" : "+"
        Offset = abs(Offset)
        return "\(Sign)\(Offset)"
    }
    
    @IBAction func HandleTimeLabelChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            switch Index
            {
                case 0:
                    Settings.SetTimeLabel(.None)
                
                case 1:
                    Settings.SetTimeLabel(.UTC)
                
                case 2:
                    Settings.SetTimeLabel(.Local)
                
                default:
                    Settings.SetTimeLabel(.UTC)
            }
        }
    }
    
    @IBAction func HandleImageCenterChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            switch Index
            {
                case 0:
                    Settings.SetImageCenter(.NorthPole)
                
                case 1:
                    Settings.SetImageCenter(.SouthPole)
                
                default:
                    Settings.SetImageCenter(.NorthPole)
            }
        }
    }
    
    @IBAction func HandleShowGridChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetGrid(Switch.isOn)
        }
    }
    
    @IBAction func HandleShowEquatorChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetEquator(Switch.isOn)
        }
    }
    
    @IBAction func HandleShowTropicsChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetTropics(Switch.isOn)
        }
    }
    
    @IBAction func HandleShowPrimeMerdiansChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetPrimeMeridians(Switch.isOn)
        }
    }
    
    @IBAction func HandleShowNoonMeridiansChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetNoonMeridians(Switch.isOn)
        }
    }
    
    @IBAction func HandleShowPolarCirclesChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetPolarCircles(Switch.isOn)
        }
    }
    
    @IBAction func HandleShowCitiesChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetShowCities(Switch.isOn)
        }
    }
    
    @IBAction func HandleDonePressed(_ sender: Any)
    {
        Delegate?.SettingsDone()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleSetTimeButtonPressed(_ sender: Any)
    {
        let Index = DebugOffsetPicker.selectedRow(inComponent: 0)
        let Offset = Offsets[Index]
        let ForceTime = TimePicker.date
        Delegate?.ForceTime(NewTime: ForceTime, WithOffset: Offset)
    }
    
    @IBAction func HandleShowLocalDataChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetShowLocalData(Switch.isOn)
        }
    }
    
    @IBSegueAction func Instantiate3DTest(_ coder: NSCoder) -> Test3D?
    {
        Delegate?.StopTimers() 
        return Test3D(coder: coder)
    }
    
    @IBSegueAction func InstantiateMapSettings(_ coder: NSCoder) -> MapSettings?
    {
        let Controller = MapSettings(coder: coder)
        Controller?.ChangeDelegate = self
        return Controller
    }
    
    func Changed(Key: String, Value: Any)
    {
        switch Key
        {
            case "FlatMap", "RoundMap":
                Delegate?.ChangeMap()
            
            default:
            break
        }
    }
    
    @IBOutlet weak var DebugOffsetPicker: UIPickerView!
    @IBOutlet weak var ShowLocalDataSwitch: UISwitch!
    @IBOutlet weak var ShowCitiesSwitch: UISwitch!
    @IBOutlet weak var ImageCenterSegment: UISegmentedControl!
    @IBOutlet weak var TimeLabelSegment: UISegmentedControl!
    @IBOutlet weak var TimePicker: UIDatePicker!
}
