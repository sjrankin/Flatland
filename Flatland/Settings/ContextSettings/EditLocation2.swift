//
//  EditLocation2.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class EditLocation2: UITableViewController, ChildClosed,
    UIPickerViewDelegate, UIPickerViewDataSource
{
    public weak var MainObject: MainProtocol? = nil
    public weak var ParentDelegate: ChildClosed? = nil
    public weak var LocationDelegate: LocationEdited? = nil
    var IsDirty = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        LocationDelegate?.GetLocation(ID: &LocationID, Coordinates: &Location, Name: &LocationName,
                              Color: &LocationColor, Editing: &IsEditing)
        CityColorList = ColorList.SimpleColorList()
        ColorPicker.layer.borderWidth = 0.5
        ColorPicker.layer.cornerRadius = 5.0
        ColorPicker.layer.borderColor = UIColor.black.cgColor
        ColorPicker.reloadAllComponents()
        if IsEditing
        {
            self.title = "Edit Location"
            NameBox.text = LocationName
            LatitudeBox.text = "\(Location.Latitude.RoundedTo(4))"
            LongitudeBox.text = "\(Location.Longitude.RoundedTo(4))"
            for Index in 0 ..< CityColorList.count
            {
                if CityColorList[Index].Color == LocationColor
                {
                    ColorPicker.selectRow(Index, inComponent: 0, animated: true)
                    break
                }
            }
        }
        else
        {
            self.title = "Add Location"
            ColorPicker.selectRow(0, inComponent: 0, animated: true)
            NameBox.text = ""
            LatitudeBox.text = "0.0"
            LongitudeBox.text = "0.0"
            Location.Latitude = 0.0
            Location.Longitude = 0.0
            LocationColor = UIColor.red
            LocationName = "unnamed"
        }
    }
    
    var CityColorList = [(Name: String, Color: UIColor)]()
    var IsEditing: Bool = false
    var LocationID: UUID = UUID()
    var Location: GeoPoint2 = GeoPoint2()
    var LocationName: String = ""
    var LocationColor: UIColor = UIColor.systemYellow
    var WasCanceled = false
    
    override func viewWillDisappear(_ animated: Bool)
    {
        ParentDelegate?.ChildWindowClosed(IsDirty)
        if WasCanceled
        {
            print("Changes cancelled")
        }
        else
        {
            if IsEditing
            {
                LocationDelegate?.UpdatedLocation(ID: LocationID, Coordinates: Location, Name: LocationName, Color: LocationColor)
            }
            else
            {
                LocationDelegate?.AddedLocation(Coordinates: Location, Name: LocationName, Color: LocationColor)
            }
        }
        super.viewWillDisappear(animated)
    }
    
    func ChildWindowClosed(_ Dirty: Bool)
    {
        if Dirty
        {
            IsDirty = Dirty
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return CityColorList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
        return 30.0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let ColorV = ColorView(frame: CGRect(x: 0, y: 0, width: 100, height: 30), Color: CityColorList[row].Color, Name: CityColorList[row].Name)
        return ColorV
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        LocationColor = CityColorList[row].Color
    }
    
    @IBAction func NameFinishedEditing(_ sender: Any)
    {
        if let TextBox = sender as? UITextField
        {
            if var Value = TextBox.text
            {
                if Value.isEmpty
                {
                    Value = "unnamed"
                }
                LocationName = Value.trimmingCharacters(in: CharacterSet.whitespaces)
            }
        }
    }
    
    func Validate(Latitude: Bool, Value: String?, Updated: inout Bool) -> Double
    {
        if Value == nil
        {
            Updated = true
            return 0.0
        }
        if let AValue = Double(Value!)
        {
            if Latitude
            {
                if AValue < -90.0
                {
                    Updated = true
                    return -90.0
                }
                if AValue > 90.0
                {
                    Updated = true
                    return 90.0
                }
                Updated = false
                return AValue
            }
            else
            {
                if AValue < -180.0
                {
                    Updated = true
                    return -180.0
                }
                if AValue > 180.0
                {
                    Updated = true
                    return 180.0
                }
                Updated = false
                return AValue
            }
        }
        Updated = true
        return 0.0
    }
    
    @IBAction func LatitudeEditingEnded(_ sender: Any)
    {
        if let TextBox = sender as? UITextField
        {
            var WasUpdated: Bool = false
            let Value = Validate(Latitude: true, Value: TextBox.text!, Updated: &WasUpdated)
            if WasUpdated
            {
                TextBox.text = "\(Value)"
            }
            Location.Latitude = Value
        }
    }
    
    @IBAction func LongitudeEditingEnded(_ sender: Any)
    {
        if let TextBox = sender as? UITextField
        {
            var WasUpdated: Bool = false
            let Value = Validate(Latitude: false, Value: TextBox.text!, Updated: &WasUpdated)
            if WasUpdated
            {
                TextBox.text = "\(Value)"
            }
            Location.Longitude = Value
        }
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        WasCanceled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var ColorPicker: UIPickerView!
    @IBOutlet weak var LongitudeBox: UITextField!
    @IBOutlet weak var LatitudeBox: UITextField!
    @IBOutlet weak var NameBox: UITextField!
}

class ColorView2: UIView
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
        ColorName = UILabel(frame: CGRect(x: 110, y: 6, width: 100, height: 20))
        self.addSubview(ColorName!)
    }
    
    var ColorSwatch: UIView? = nil
    var ColorName: UILabel? = nil
}
