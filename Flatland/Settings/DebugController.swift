//
//  DebugController.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class DebugController: UITableViewController
{
    public weak var SettingsDelegate: SettingsProtocol? = nil
    public weak var MainObject: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let Parent = self.parent as? DebugNavigationViewer
        {
            SettingsDelegate = Parent.Delegate
        }
        FreezeTimeSwitch.isOn = false
        TimeMultiplier.selectedSegmentIndex = 0
        FrozenDatePicker.date = Date()
        FreezeDateSwitch.isOn = false
        LocationStatusLabel.text = ""
        HourRefreshSwitch.isOn = Settings.ResetHoursPeriodically()
        let RawDuration = Int(Settings.GetHourResetDuration())
        if let Index = HourRefreshMap[RawDuration]
        {
            HourRefreshSegment.selectedSegmentIndex = Index
        }
        else
        {
            HourRefreshSegment.selectedSegmentIndex = 3
            Settings.SetHourResetDuration(60.0)
        }
    }
    
    let HourRefreshMap =
    [
        5: 0,
        10: 1,
        30: 2,
        60: 3,
        600: 4,
        1800: 5,
        3600: 6,
        7200: 7
    ]
    
    @IBAction func HandleFreezeTimeChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            SettingsDelegate?.FreezeTime(Switch.isOn)
        }
    }
    
    @IBAction func HandleTimeMultiplierChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            if Index >= MultiplierMap.count
            {
                return
            }
            SettingsDelegate?.SetTimeMultiplier(MultiplierMap[Index])
        }
    }
    
    let MultiplierMap: [Double] =
    [
        1.0, 1.5, 2.0, 4.0, 8.0, 10.0, 20.0, 50.0, 100.0
    ]
    
    @IBAction func HandleDonePressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleDateFrozen(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            if Switch.isOn
            {
                SettingsDelegate?.FreezeDate(true, ToDate: FrozenDatePicker.date)
                return
            }
        }
        SettingsDelegate?.FreezeTime(false)
    }
    
    @IBAction func HandleAddDebugUserLocations(_ sender: Any)
    {
        var IsDirty = false
        var AllUserLocations = Settings.GetLocations()
        if !InSettings(CuzcoID, AllUserLocations)
        {
            AllUserLocations.append((CuzcoID, GeoPoint2(-13.5320, -71.9675), "Cusco", UIColor.systemBlue))
            IsDirty = true
        }
        if !InSettings(AmsterdamID, AllUserLocations)
        {
            AllUserLocations.append((AmsterdamID, GeoPoint2(52.3667, 4.8945), "Amsterdam", UIColor.systemYellow))
            IsDirty = true
        }
        if !InSettings(BaikonurID, AllUserLocations)
        {
            AllUserLocations.append((BaikonurID, GeoPoint2(45.965, 63.305), "Baikonur", UIColor.systemPink))
            IsDirty = true
        }
        if !InSettings(OlduvaiGorgeID, AllUserLocations)
        {
            AllUserLocations.append((OlduvaiGorgeID, GeoPoint2(-2.9896, 35.3539), "Olduvai Gorge", UIColor.systemIndigo))
            IsDirty = true
        }
        if !InSettings(LittleTraversLakeID, AllUserLocations)
        {
            AllUserLocations.append((LittleTraversLakeID, GeoPoint2(44.9221, -85.8409), "Little Traverse Lake", UIColor.brown))
            IsDirty = true
        }
        if !InSettings(ShingleSpringsID, AllUserLocations)
        {
            AllUserLocations.append((ShingleSpringsID, GeoPoint2(38.6691, -120.9360), "Shingle Springs", UIColor.magenta))
            IsDirty = true
        }
        if !InSettings(SharkBayID, AllUserLocations)
        {
            AllUserLocations.append((SharkBayID, GeoPoint2(-25.7834, 113.2988), "Shark Bay", UIColor.white))
            IsDirty = true
        }
        if IsDirty
        {
            Settings.SetLocations(AllUserLocations)
            LocationStatusLabel.text = "Added debug locations"
        }
    }
    
    func InSettings(_ ID: UUID, _ All: [(ID: UUID, Coordinates: GeoPoint2, Name: String, Color: UIColor)]) -> Bool
    {
        for Each in All
        {
            if Each.ID == ID
            {
                return true
            }
        }
        return false
    }
    
        let CuzcoID = UUID(uuidString: "21b476da-aa3c-4e38-b9f0-1a1a9ca9978e")!
    let AmsterdamID = UUID(uuidString: "cde6ca73-cfa7-48ec-8b60-2807bc043f43")!
    let LittleTraversLakeID = UUID(uuidString: "ef1fa739-e920-4e7f-a1d9-a694c3b285cc")!
    let ShingleSpringsID = UUID(uuidString: "bd343d1a-37c1-4851-a99b-1f83f54519ae")!
    let OlduvaiGorgeID = UUID(uuidString: "ec3c9e5d-c982-48a3-aff1-e32a603cdc16")!
    let BaikonurID = UUID(uuidString: "62bc6f0b-96ca-4e18-86b0-1135cb15cbaf")!
    let SharkBayID = UUID(uuidString: "253fd68c-bad7-43a1-bc34-fd720ff44821")!
    
    @IBAction func HandleHourRefreshDurationChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            for (Seconds, SecondIndex) in HourRefreshMap
            {
                if Index == SecondIndex
                {
                    Settings.SetHourResetDuration(Double(Seconds))
                    MainObject?.GlobeObject()?.SetHourResetTimer()
                    return
                }
            }
        }
    }
    
    @IBAction func HandleRefreshHourChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetResetHoursPeriodcially(Switch.isOn)
            MainObject?.GlobeObject()?.SetHourResetTimer()
        }
    }
    
    @IBOutlet weak var HourRefreshSegment: UISegmentedControl!
    @IBOutlet weak var HourRefreshSwitch: UISwitch!
    @IBOutlet weak var LocationStatusLabel: UILabel!
    @IBOutlet weak var FreezeDateSwitch: UISwitch!
    @IBOutlet weak var FrozenDatePicker: UIDatePicker!
    @IBOutlet weak var FreezeTimeSwitch: UISwitch!
    @IBOutlet weak var TimeMultiplier: UISegmentedControl!
}
