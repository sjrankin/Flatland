//
//  CityColorSelector.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/17/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class CityColorSelector: UIViewController, ChildClosed,
    UIPickerViewDelegate, UIPickerViewDataSource,
    UITableViewDelegate, UITableViewDataSource
{
    public weak var MainObject: MainProtocol? = nil
    public weak var ParentDelegate: ChildClosed? = nil
    var IsDirty = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        PopulateCityColors()
        CityColorTable.reloadData()
    }
    
    func PopulateCityColors()
    {
        CityColors.removeAll()
        for CityList in CityLists.allCases
        {
            let Color = Settings.CityListColor(For: CityList)
            CityColors.append((NiceNames[CityList]!, Color))
        }
    }
    
    let NiceNames: [CityLists: String] =
    [
        .AfricanCities: "Africa",
        .AsianCities: "Asia",
        .EuropeanCities: "Europe",
        .NorthAmericanCities: "North America",
        .SouthAmericanCities: "South America",
        .CaptialCities: "Capital Cities",
        .WorldCities: "World Cities"
    ]
    
    var CityColors = [(String, UIColor)]()
    
    func CityTypeFromName(_ Name: String) -> CityLists?
    {
        for (CityType, ListName) in NiceNames
        {
            if ListName == Name
            {
                return CityType
            }
        }
        return nil
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        ParentDelegate?.ChildWindowClosed(IsDirty)
        super.viewWillDisappear(animated)
    }
    
    func ChildWindowClosed(_ Dirty: Bool)
    {
    }
    
    // MARK: - Color picker handling.
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return ColorList.Colors.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let SomeColor = ColorList.Colors[row]
        let View = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 200, height: 30)))
        let Label = UILabel(frame: CGRect(x: 1, y: 5, width: 110, height: 20))
        Label.text = SomeColor.Name
        View.addSubview(Label)
        let Swatch = UIView(frame: CGRect(x: 120, y: 5, width: 80, height: 20))
        Swatch.layer.borderWidth = 0.5
        Swatch.layer.borderColor = UIColor.black.cgColor
        Swatch.layer.cornerRadius = 5.0
        Swatch.backgroundColor = SomeColor.Color
        View.addSubview(Swatch)
        return View
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if let Index = CityColorTable.indexPathForSelectedRow?.row
        {
            let OldName = CityColors[Index].0
            CityColors[Index] = (OldName, ColorList.Colors[row].Color)
            CityColorTable.reloadData()
            CityColorTable.selectRow(at: IndexPath(row: Index, section: 0), animated: true, scrollPosition: .none)
            if let CityType = CityTypeFromName(OldName)
            {
                Settings.SetCityListColor(For: CityType, Color: ColorList.Colors[row].Color)
                MainObject?.GlobeObject()?.PlotCities()
            }
        }
    }
    
    func SelectPickerColor(_ Color: UIColor)
    {
        var Index = 0
        for SomeColor in ColorList.Colors
        {
            if SomeColor.Color == Color
            {
                CityColorPicker.selectRow(Index, inComponent: 0, animated: true)
            }
            Index = Index + 1
        }
    }
    
    // MARK: - City list handling.
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return CityColors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = CityColorCell(style: .default, reuseIdentifier: "CityColorCell")
        let SomeColor = CityColors[indexPath.row]
        Cell.SetColor(Name: SomeColor.0, Color: SomeColor.1)
        return Cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let CityColor = CityColors[indexPath.row].1
        SelectPickerColor(CityColor)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return CityColorCell.Height
    }
    
    @IBAction func HandleResetPressed(_ sender: Any)
    {
        for CityType in CityLists.allCases
        {
            let DefaultColor = Settings.CityListColor(For: CityType, ReturnDefault: true)
            Settings.SetCityListColor(For: CityType, Color: DefaultColor)
        }
        PopulateCityColors()
        CityColorTable.reloadData()
        MainObject?.GlobeObject()?.PlotCities()
    }
    
    @IBOutlet weak var CityColorTable: UITableView!
    @IBOutlet weak var CityColorPicker: UIPickerView!
}
