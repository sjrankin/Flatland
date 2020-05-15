//
//  MainUserCitiesController.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class MainUserCitiesController: UITableViewController, ChildClosed
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ShowUserCitiesSwitch.isOn = Settings.ShowUserLocations()
        if Settings.GetLocalLatitude() == nil || Settings.GetLocalLongitude() == nil
        {
            UserLocationSetLabel.text = "not set"
        }
        else
        {
            UserLocationSetLabel.text = "set"
        }
    }
    
    @IBAction func HandleShowUserCitiesChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            ShowUserCitiesSwitch.isOn = Switch.isOn
        }
    }
    
    func ChildWindowClosed(_ Dirty: Bool)
    {
        if Dirty
        {
            
        }
    }
    
    @IBSegueAction func InstantiateCityLists(_ coder: NSCoder) -> CityListSelectorView?
    {
        let Controller = CityListSelectorView(coder: coder)
        Controller?.ParentDelegate = self 
        return Controller
    }
    
    @IBSegueAction func InstantiateUserLocation(_ coder: NSCoder) -> UserLocationSettingController?
    {
        let Controller = UserLocationSettingController(coder: coder)
        Controller?.ParentDelegate = self
        return Controller
    }
    
    @IBSegueAction func InstantiateCityViews(_ coder: NSCoder) -> CityViewController?
    {
        let Controller = CityViewController(coder: coder)
        Controller?.ParentDelegate = self
        return Controller
    }
    
    @IBOutlet weak var UserLocationSetLabel: UILabel!
    @IBOutlet weak var ShowUserCitiesSwitch: UISwitch!
}
