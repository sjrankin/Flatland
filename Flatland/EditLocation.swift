//
//  EditLocation.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class EditLocation: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    weak var Delegate: LocationEdited? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Delegate?.GetLocation(ID: &LocationID, Coordinates: &Location, Name: &LocationName, Color: &LocationColor)
        ColorPicker.layer.borderWidth = 0.5
        ColorPicker.layer.cornerRadius = 5.0
        ColorPicker.layer.borderColor = UIColor.black.cgColor
        ColorPicker.reloadAllComponents()
    }
    
    var LocationID: UUID = UUID()
    var Location: GeoPoint2 = GeoPoint2()
    var LocationName: String = ""
    var LocationColor: UIColor = UIColor.systemYellow
    
    let ColorList: [(Name: String, Color: UIColor)] =
    [
        ("Red", UIColor.red),
        ("Green", UIColor.green),
        ("Blue", UIColor.blue),
        ("Cyan", UIColor.cyan),
        ("Magenta", UIColor.magenta),
        ("Yellow", UIColor.yellow),
        ("Orange", UIColor.orange),
        ("Pink", UIColor.systemPink),
        ("Black", UIColor.black),
        ("White", UIColor.white)
    ]
    
    var WasCanceled = false
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        WasCanceled = true
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        if !WasCanceled
        {
            Delegate?.UpdatedLocation(ID: LocationID, Coordinates: Location, Name: LocationName, Color: LocationColor)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return ColorList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
        return 30.0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let ColorV = ColorView(frame: CGRect(x: 0, y: 0, width: 100, height: 30), Color: ColorList[row].Color, Name: ColorList[row].Name)
        return ColorV
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("Selected color: \(ColorList[row].Name)")
    }
    
    @IBAction func HandleLatitudeBox(_ sender: Any)
    {
    }
    
    @IBAction func HandleLongitudeBox(_ sender: Any)
    {
    }
    
    @IBOutlet weak var ColorPicker: UIPickerView!
    @IBOutlet weak var LongitudeBox: UITextField!
    @IBOutlet weak var LatitudeBox: UITextField!
    @IBOutlet weak var NameBox: UITextField!
}

class ColorView: UIView
{
    init(frame: CGRect, Color: UIColor, Name: String)
    {
        super.init(frame: frame)
        Initialize(WithFrame: frame)
        ColorSwatch?.backgroundColor = Color
        ColorName?.text = Name
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        Initialize(WithFrame: frame)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize(WithFrame: CGRect(x: 0, y: 0, width: 100, height: 30))
    }
    
    func Initialize(WithFrame: CGRect)
    {
        ColorSwatch = UIView(frame: CGRect(x: 10, y: 2, width: 60, height: 26))
        ColorSwatch?.layer.borderColor = UIColor.black.cgColor
        ColorSwatch?.layer.borderWidth = 0.5
        ColorSwatch?.layer.cornerRadius = 5.0
        self.addSubview(ColorSwatch!)
        ColorName = UILabel(frame: CGRect(x: 50, y: 6, width: 100, height: 20))
        self.addSubview(ColorName!)
    }
    
    var ColorSwatch: UIView? = nil
    var ColorName: UILabel? = nil
}
