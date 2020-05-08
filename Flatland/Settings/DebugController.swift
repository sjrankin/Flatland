//
//  DebugController.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class DebugController: UITableViewController
{
    public weak var SettingsDelegate: SettingsProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let Parent = self.parent as? DebugNavigationViewer
        {
            SettingsDelegate = Parent.Delegate
        }
        if SettingsDelegate == nil
        {
            print("No delegate")
        }
        FreezeTimeSwitch.isOn = false
        TimeMultiplier.selectedSegmentIndex = 0
        FrozenDatePicker.date = Date()
        FreezeDateSwitch.isOn = false
    }
    
    @IBAction func HandleFreezeTimeChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            SettingsDelegate?.FreezeTime(Switch.isOn)
        }
    }
    
    @IBAction func HandleTimeMultiplierChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            if Index >= MultiplierMap.count
            {
                return
            }
            SettingsDelegate?.SetTimeMultiplier(MultiplierMap[Index])
        }
    }
    
    let MultiplierMap: [Double] =
    [
        1.0, 1.5, 2.0, 4.0, 8.0, 10.0, 20.0, 50.0, 100.0
    ]
    
    @IBAction func HandleDonePressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleDateFrozen(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            if Switch.isOn
            {
                SettingsDelegate?.FreezeDate(true, ToDate: FrozenDatePicker.date)
                return
            }
        }
        SettingsDelegate?.FreezeTime(false)
    }
    
    @IBOutlet weak var FreezeDateSwitch: UISwitch!
    @IBOutlet weak var FrozenDatePicker: UIDatePicker!
    @IBOutlet weak var FreezeTimeSwitch: UISwitch!
    @IBOutlet weak var TimeMultiplier: UISegmentedControl!
}
