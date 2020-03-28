//
//  CitySelectorView.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class CitySelectorView: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ShowWorldCitiesSwitch.isOn = Settings.ShowWorldCities100()
        ShowAfricanCitiesSwitch.isOn = Settings.ShowAfricanCities100()
        ShowAsianCitiesSwitch.isOn = Settings.ShowAsianCities100()
        ShowEuropeanCitiesSwitch.isOn = Settings.ShowEuropeanCities100()
        ShowNorthAmericanSwitch.isOn = Settings.ShowNorthAmericanCities100()
        ShowSouthAmericanSwitch.isOn = Settings.ShowSouthAmericanCities100()
        ShowCapitalCitiesSwitch.isOn = Settings.ShowCapitalCities()
        ShowUserLocationsSwitch.isOn = Settings.ShowUserLocations()
    }
    
    @IBAction func HandleShow100CitiesChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetWorldCities100(Switch.isOn)
        }
    }
    
    @IBAction func HandleShowAfrica100Changed(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetAfricanCities100(Switch.isOn)
        }
    }
    
    @IBAction func HandleShowAsia100Changed(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetAsianCities100(Switch.isOn)
        }
    }
    
    @IBAction func HandleShowEurope100Changed(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetEuropeanCities100(Switch.isOn)
        }
    }
    
    @IBAction func HandleShowNorthAmerica100Changed(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetNorthAmericanCities100(Switch.isOn)
        }
    }
    
    @IBAction func HandleShowSouthAmerica100Changed(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetSouthAmericanCities100(Switch.isOn)
        }
    }
    
    @IBAction func HandleShowCapitalCitiesChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetCapitalCities(Switch.isOn)
        }
    }
    
    @IBAction func HandleShowUserLocationsChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetUserLocations(Switch.isOn)
        }
    }
    
    @IBOutlet weak var ShowWorldCitiesSwitch: UISwitch!
    @IBOutlet weak var ShowAfricanCitiesSwitch: UISwitch!
    @IBOutlet weak var ShowAsianCitiesSwitch: UISwitch!
    @IBOutlet weak var ShowEuropeanCitiesSwitch: UISwitch!
    @IBOutlet weak var ShowNorthAmericanSwitch: UISwitch!
    @IBOutlet weak var ShowSouthAmericanSwitch: UISwitch!
    @IBOutlet weak var ShowCapitalCitiesSwitch: UISwitch!
    @IBOutlet weak var ShowUserLocationsSwitch: UISwitch!
}
