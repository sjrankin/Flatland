//
//  WorldHeritageSiteView.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/20/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class WorldHeritageSiteView: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    public weak var MainObject: MainProtocol? = nil
    public weak var ParentDelegate: ChildClosed? = nil
    var IsDirty = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        CountryPicker.layer.borderColor = UIColor.black.cgColor
        YearPicker.layer.borderColor = UIColor.black.cgColor
        if let TheMainObject = MainObject
        {
            MasterList = TheMainObject.GetWorldHeritageSites()
            FilteredList = MainView.FilterWorldHeritageSites(MasterList)
            YearList = MainView.WorldHeritageInscriptionDates(FilteredList)
            CountryList = MainView.WorldHeritageCountryList(FilteredList)
            CountryList.insert("All Countries", at: 0)
            SiteCountLabel.text = "\(FilteredList.count) sites selected"
            SetSelectedPickerValues()
        }
        ShowSitesSwitch.isOn = Settings.ShowWorldHeritageSites()
        switch Settings.GetWorldHeritageSiteTypeFilter()
        {
            case .Natural:
                SiteTypeSegment.selectedSegmentIndex = 0
            
            case .Cultural:
                SiteTypeSegment.selectedSegmentIndex = 1
            
            case .Both:
                SiteTypeSegment.selectedSegmentIndex = 2
            
            case .Either:
                SiteTypeSegment.selectedSegmentIndex = 3
        }
        switch Settings.GetWorldHeritageSiteInscribedYearFilter()
        {
            case .Only:
                YearFilterSegment.selectedSegmentIndex = 0
            
            case .UpTo:
                YearFilterSegment.selectedSegmentIndex = 1
            
            case .After:
                YearFilterSegment.selectedSegmentIndex = 2
            
            case .All:
                YearFilterSegment.selectedSegmentIndex = 3
        }
    }
    
    var MasterList = [WorldHeritageSite]()
    var FilteredList = [WorldHeritageSite]()
    var YearList = [Int]()
    var CountryList = [String]()
    
    override func viewWillDisappear(_ animated: Bool)
    {
        ParentDelegate?.ChildWindowClosed(IsDirty)
        super.viewWillDisappear(animated)
    }
    
    @IBAction func HandleResetButtonPressed(_ sender: Any)
    {
        FilteredList = MasterList
        Settings.SetWorldHeritageSiteTypeFilter(.Either)
        Settings.SetWorldHeritageSiteInscribedYearFilter(.All)
        Settings.SetWorldHeritageSiteInscribedYear(nil)
        Settings.SetWorldHeritageSiteCountry("")
        Settings.SetShowWorldHeritageSites(false)
        ShowSitesSwitch.isOn = false
        YearFilterSegment.selectedSegmentIndex = 3
        SiteTypeSegment.selectedSegmentIndex = 3
        YearList = MainView.WorldHeritageInscriptionDates(FilteredList)
        CountryList = MainView.WorldHeritageCountryList(FilteredList)
        CountryPicker.reloadAllComponents()
        YearPicker.reloadAllComponents()
        SiteCountLabel.text = "\(FilteredList.count) sites selected"
    }
    
    @IBAction func HandleShowSitesChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetShowWorldHeritageSites(Switch.isOn)
            IsDirty = true
        }
    }
    
    @IBAction func HandleTypeSiteChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            switch Index
            {
                case 0:
                    Settings.SetWorldHeritageSiteTypeFilter(.Natural)
                
                case 1:
                    Settings.SetWorldHeritageSiteTypeFilter(.Cultural)
                
                case 2:
                    Settings.SetWorldHeritageSiteTypeFilter(.Both)
                
                case 3:
                    Settings.SetWorldHeritageSiteTypeFilter(.Either)
                
                default:
                    return
            }
            IsDirty = true
            MasterUpdate()
        }
    }
    
    @IBAction func HandleYearFilterSegmentChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            switch Index
            {
                case 0:
                    Settings.SetWorldHeritageSiteInscribedYearFilter(.Only)
                
                case 1:
                    Settings.SetWorldHeritageSiteInscribedYearFilter(.UpTo)
                
                case 2:
                    Settings.SetWorldHeritageSiteInscribedYearFilter(.After)
                
                case 3:
                    Settings.SetWorldHeritageSiteInscribedYearFilter(.All)
                
                default:
                    return
            }
            IsDirty = true
            MasterUpdate()
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView
        {
            case YearPicker:
                return YearList.count
            
            case CountryPicker:
                return CountryList.count
            
            default:
                return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        switch pickerView
        {
            case YearPicker:
                let YView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
                let YLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
                YLabel.font = UIFont.systemFont(ofSize: 15.0)
                YLabel.text = "\(YearList[row])"
                YView.addSubview(YLabel)
                return YView
            
            case CountryPicker:
                let CView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
                let CLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
                CLabel.font = UIFont.systemFont(ofSize: 14.0)
                CLabel.text = CountryList[row]
                CView.addSubview(CLabel)
                return CView
            
            default:
                return UIView()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        switch pickerView
        {
            case YearPicker:
                let SelectedYear = YearList[row]
                Settings.SetWorldHeritageSiteInscribedYear(SelectedYear)
            
            case CountryPicker:
                let SelectedCountry = CountryList[row]
                if SelectedCountry == "All Countries"
                {
                    Settings.SetWorldHeritageSiteCountry("")
                }
                else
                {
                    Settings.SetWorldHeritageSiteCountry(SelectedCountry)
            }
            
            default:
                return
        }
        IsDirty = true
        MasterUpdate()
    }
    
    func MasterUpdate()
    {
        FilteredList = MainView.FilterWorldHeritageSites(FilteredList)
        YearList = MainView.WorldHeritageInscriptionDates(FilteredList)
        CountryList = MainView.WorldHeritageCountryList(FilteredList)
        CountryList.insert("All Countries", at: 0)
        print("Master update country count: \(FilteredList.count)")
        SiteCountLabel.text = "\(FilteredList.count) sites selected"
        SetSelectedPickerValues()
    }
    
    func SetSelectedPickerValues()
    {
        if let SelectedYear = Settings.GetWorldHeritageSiteInscribedYear()
        {
            if let Index = YearList.firstIndex(of: SelectedYear)
            {
                YearPicker.selectRow(Index, inComponent: 0, animated: true)
            }
        }
        let SelectedCountry = Settings.GetWorldHeritageSiteCountry()
        if !SelectedCountry.isEmpty
        {
            if let Index = CountryList.firstIndex(of: SelectedCountry)
            {
                CountryPicker.selectRow(Index, inComponent: 0, animated: true)
            }
        }
    }
    
    @IBOutlet weak var SiteCountLabel: UILabel!
    @IBOutlet weak var YearFilterSegment: UISegmentedControl!
    @IBOutlet weak var SiteTypeSegment: UISegmentedControl!
    @IBOutlet weak var YearPicker: UIPickerView!
    @IBOutlet weak var CountryPicker: UIPickerView!
    @IBOutlet weak var ShowSitesSwitch: UISwitch!
}
