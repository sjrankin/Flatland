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
    public weak var MainObject: MainProtocol? = nil
    public weak var ParentDelegate: ChildClosed? = nil
    var IsDirty = false
    
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
        switch Settings.ShowHomeLocation()
        {
            case .ShowAsArrow:
                HomeStyleSegment.selectedSegmentIndex = 0
            
            case .ShowAsFlag:
                HomeStyleSegment.selectedSegmentIndex = 1
            
            case .Hide:
                HomeStyleSegment.selectedSegmentIndex = 2
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        ParentDelegate?.ChildWindowClosed(IsDirty)
        super.viewWillDisappear(animated)
    }
    
    @IBAction func HandleShowUserCitiesChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            ShowUserCitiesSwitch.isOn = Switch.isOn
            IsDirty = true
        }
    }
    
    func ChildWindowClosed(_ Dirty: Bool)
    {
        if Dirty
        {
            IsDirty = Dirty
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
    
    @IBAction func HandleHomeLocationStyleChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            switch Segment.selectedSegmentIndex
            {
                case 0:
                    print("As arrow")
                    Settings.SetShowHomeLocation(.ShowAsArrow)
                
                case 1:
                    print("As flag")
                    Settings.SetShowHomeLocation(.ShowAsFlag)
                
                case 2:
                    print("As nothing")
                    Settings.SetShowHomeLocation(.Hide)
                
                default:
                    break
            }
            IsDirty = true
            MainObject?.GlobeObject()?.PlotHomeLocation()
        }
    }
    
    @IBOutlet weak var HomeStyleSegment: UISegmentedControl!
    @IBOutlet weak var UserLocationSetLabel: UILabel!
    @IBOutlet weak var ShowUserCitiesSwitch: UISwitch!
}
