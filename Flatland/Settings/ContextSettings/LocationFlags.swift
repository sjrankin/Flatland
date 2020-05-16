//
//  LocationFlags.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/16/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class LocationFlags: UITableViewController
{
    public weak var MainObject: MainProtocol? = nil
    public weak var ParentDelegate: ChildClosed? = nil
    var IsDirty = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        PolarFlagsSwitch.isOn = Settings.ShowPolarFlags()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        ParentDelegate?.ChildWindowClosed(IsDirty)
        super.viewWillDisappear(animated)
    }
    
    @IBAction func HandlePolarFlagsChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetShowPolarFlags(Switch.isOn)
            IsDirty = true
            MainObject?.GlobeObject()?.PlotPolarFlags(Switch.isOn)
        }
    }
    
    @IBOutlet weak var PolarFlagsSwitch: UISwitch!
}
