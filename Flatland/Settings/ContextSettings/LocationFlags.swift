//
//  LocationFlags.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/16/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class LocationFlags: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    public weak var MainObject: MainProtocol? = nil
    public weak var ParentDelegate: ChildClosed? = nil
    var IsDirty = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        for SomeShape in PolarShapes.allCases
        {
            PolarShapeList.append(SomeShape.rawValue)
        }
        PolarShapePicker.reloadAllComponents()
        let Current = Settings.GetPolarShape()
        var Index = 0
        for ShapeName in PolarShapeList
        {
            if ShapeName == Current.rawValue
            {
                PolarShapePicker.selectRow(Index, inComponent: 0, animated: true)
                break
            }
            Index = Index + 1
        }
    }
    
    var PolarShapeList = [String]()
    
    override func viewWillDisappear(_ animated: Bool)
    {
        ParentDelegate?.ChildWindowClosed(IsDirty)
        super.viewWillDisappear(animated)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let Raw = PolarShapeList[row]
        if let Final = PolarShapes(rawValue: Raw)
        {
        Settings.SetPolarShape(Final)
            IsDirty = true
            MainObject?.GlobeObject()?.PlotPolarShape()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return PolarShapeList[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return PolarShapeList.count
    }
    
    @IBOutlet weak var PolarShapePicker: UIPickerView!
}
