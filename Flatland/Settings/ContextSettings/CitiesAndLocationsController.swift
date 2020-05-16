//
//  CitiesAndLocationsController.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/16/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class CitiesAndLocationsController: UITableViewController, ChildClosed
{
    public weak var MainObject: MainProtocol? = nil
    public weak var ParentDelegate: ChildClosed? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        ParentDelegate?.ChildWindowClosed(false)
        super.viewWillDisappear(animated)
    }
    
    @IBSegueAction func InstantiateUserCities(_ coder: NSCoder) -> MainUserCitiesController?
    {
        let Controller = MainUserCitiesController(coder: coder)
        Controller?.MainObject = MainObject
        Controller?.ParentDelegate = self
        return Controller
    }
    
    @IBSegueAction func InstantiateCityViews(_ coder: NSCoder) -> CityViewController?
    {
        let Controller = CityViewController(coder: coder)
        Controller?.MainObject = MainObject
        Controller?.ParentDelegate = self
        return Controller
    }
    
    @IBSegueAction func InstantiateFlagsController(_ coder: NSCoder) -> LocationFlags?
    {
        let Controller = LocationFlags(coder: coder)
        Controller?.MainObject = MainObject
        Controller?.ParentDelegate = self
        return Controller
    }
    
    func ChildWindowClosed(_ Dirty: Bool)
    {
    }
}
