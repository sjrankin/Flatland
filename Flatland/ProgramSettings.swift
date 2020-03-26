//
//  Settings.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/26/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ProgramSettings: UITableViewController
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
        switch Settings.GetSunLocation()
        {
            case .Hidden:
                SunSegment.selectedSegmentIndex = 0
            
            case .Top:
                SunSegment.selectedSegmentIndex = 1
            
            case .Bottom:
                SunSegment.selectedSegmentIndex = 2
        }
        ShowGridSwitch.isOn = Settings.ShowGrid()
        ShowEquatorSwitch.isOn = Settings.ShowEquator()
        ShowTropicsSwitch.isOn = Settings.ShowTropics()
        ShowPrimeMerdiansSwitch.isOn = Settings.ShowPrimeMeridians()
        ShowNoonMerdiansSwitch.isOn = Settings.ShowNoonMeridians()
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
    
    
    @IBAction func HandleSunLocationChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            switch Index
            {
                case 0:
                    Settings.SetSunLocation(.Hidden)
                
                case 1:
                    Settings.SetSunLocation(.Top)
                
                case 2:
                    Settings.SetSunLocation(.Bottom)
                
                default:
                    Settings.SetSunLocation(.Top)
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
    
    @IBAction func HandleDonePressed(_ sender: Any)
    {
        Delegate?.SettingsDone()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var ShowNoonMerdiansSwitch: UISwitch!
    @IBOutlet weak var ShowPrimeMerdiansSwitch: UISwitch!
    @IBOutlet weak var ShowTropicsSwitch: UISwitch!
    @IBOutlet weak var ShowEquatorSwitch: UISwitch!
    @IBOutlet weak var ShowGridSwitch: UISwitch!
    @IBOutlet weak var SunSegment: UISegmentedControl!
    @IBOutlet weak var ImageCenterSegment: UISegmentedControl!
    @IBOutlet weak var TimeLabelSegment: UISegmentedControl!
}
