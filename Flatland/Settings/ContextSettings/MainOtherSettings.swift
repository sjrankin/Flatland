//
//  MainOtherSettings.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/17/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class MainOtherSettings: UITableViewController, ChildClosed,
    UIPickerViewDelegate, UIPickerViewDataSource
{
    public weak var MainObject: MainProtocol? = nil
    public weak var ParentDelegate: ChildClosed? = nil
    var IsDirty = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        LanguagePicker.layer.borderColor = UIColor.black.cgColor
        ShowLocalDataSwitch.isOn = Settings.GetShowLocalData()
        let Index = Settings.GetDisplayLanguage() == .English ? 0 : 1
        LanguagePicker.selectRow(Index, inComponent: 0, animated: true)
    }
    
    let LanguageList = ["English", "日本語"]
    
    override func viewWillDisappear(_ animated: Bool)
    {
        ParentDelegate?.ChildWindowClosed(IsDirty)
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
        LanguageList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return LanguageList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let Language = row == 0 ? DisplayLanguages.English : DisplayLanguages.Japanese
        Settings.SetDisplayLanguage(Language)
        MainObject?.SetDisplayLanguage()
        MainObject?.GlobeObject()?.SetDisplayLanguage()
    }
    
    @IBAction func HandleShowLocalDataChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetShowLocalData(Switch.isOn)
            MainObject?.ShowLocalData(Switch.isOn)
        }
    }
    
    @IBOutlet weak var LanguagePicker: UIPickerView!
    @IBOutlet weak var ShowLocalDataSwitch: UISwitch!
}
