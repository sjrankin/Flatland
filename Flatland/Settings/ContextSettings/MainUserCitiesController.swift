//
//  MainUserCitiesController.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class MainUserCitiesController: UITableViewController, ChildClosed,
    UIPickerViewDelegate, UIPickerViewDataSource
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
            UserLocationSetLabel.text = "is set"
        }
        HomeStylePicker.layer.borderColor = UIColor.black.cgColor
        let CurrentStyle = Settings.ShowHomeLocation()
        var CurrentIndex = 0
        var Index = 0
        for SomeStyle in HomeLocationViews.allCases
        {
            HomeStyles.append(SomeStyle.rawValue)
            if SomeStyle == CurrentStyle
            {
                CurrentIndex = Index
            }
            Index = Index + 1
        }
        HomeStylePicker.reloadAllComponents()
        HomeStylePicker.selectRow(CurrentIndex, inComponent: 0, animated: true)
    }
    
    var HomeStyles = [String]()
    
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
    
    @IBSegueAction func InstantiateUserCityListEditor(_ coder: NSCoder) -> UserCityListView?
    {
        let Controller = UserCityListView(coder: coder)
        Controller?.ParentDelegate = self
        Controller?.MainObject = MainObject
        return Controller
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return HomeStyles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if let FinalStyle = HomeLocationViews(rawValue: HomeStyles[row])
        {
            Settings.SetShowHomeLocation(FinalStyle)
            IsDirty = true
            MainObject?.GlobeObject()?.PlotHomeLocation()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return HomeStyles[row]
    }
    
    @IBOutlet weak var HomeStylePicker: UIPickerView!
    @IBOutlet weak var UserLocationSetLabel: UILabel!
    @IBOutlet weak var ShowUserCitiesSwitch: UISwitch!
}
