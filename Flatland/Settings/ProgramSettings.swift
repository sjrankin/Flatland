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
    SomethingChanged, ChildClosed
{
    weak var Delegate: SettingsProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let Parent = self.parent as? SettingsNavigationViewer
        {
            Delegate = Parent.Delegate
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
        ShowStarsSwitch.isOn = Settings.ShowStars()
        ShowLocalDataSwitch.isOn = Settings.GetShowLocalData()
        ShowMoonlightSwitch.isOn = Settings.GetShowMoonlight()
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
    
    @IBAction func HandleShowLocalDataChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetShowLocalData(Switch.isOn)
        }
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
            
            case "GlobalAlpha":
                Delegate?.AlphaChanged() 
            
            default:
            break
        }
    }
    
    @IBAction func HandleShowStarsChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetShowStars(Switch.isOn)
        }
    }
    
    @IBSegueAction func HandleAboutInstantiated(_ coder: NSCoder) -> AboutView?
    {
        objc_sync_enter(AboutBlock)
        defer{objc_sync_exit(AboutBlock)}
        print("Instantiating about: \(Date())")
        
        WorkingIndicator.isHidden = false
        WorkingLabel.isHidden = false
        let Controller = AboutView(coder: coder)
        Controller?.ClosedDelegate = self
        return Controller
    }
    
    var AboutBlock: NSObject = NSObject()
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?
    {
        objc_sync_enter(AboutBlock)
        defer{objc_sync_exit(AboutBlock)}
            print("Will select row at \(indexPath): \(Date())")
        WorkingIndicator.isHidden = false
        WorkingLabel.isHidden = false
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
     print("Selected row at \(indexPath): \(Date())")
    }
    
    func ChildWindowClosed(_ Dirty: Bool)
    {
        WorkingIndicator.isHidden = true
        WorkingLabel.isHidden = true
    }
    
    @IBAction func HandleShowMoonlightChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetShowMoonlight(Switch.isOn)
        }
    }
    
    @IBOutlet weak var ShowMoonlightSwitch: UISwitch!
    @IBOutlet weak var WorkingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var WorkingLabel: UILabel!
    @IBOutlet weak var ShowStarsSwitch: UISwitch!
    @IBOutlet weak var ShowLocalDataSwitch: UISwitch!
    @IBOutlet weak var ShowCitiesSwitch: UISwitch!
    @IBOutlet weak var ImageCenterSegment: UISegmentedControl!
    @IBOutlet weak var TimeLabelSegment: UISegmentedControl!
}
