//
//  MapSettings.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/16/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class MapSettings: UITableViewController
{
    public weak var ChangeDelegate: SomethingChanged? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        ShowNightSwitch.isOn = Settings.ShowNight()
        PolarSwitch.isOn = Settings.ShowPolarCircles()
        EquatorSwitch.isOn = Settings.ShowEquator()
        TropicSwitch.isOn = Settings.ShowTropics()
        PrimeMeridianSwitch.isOn = Settings.ShowPrimeMeridians()
        NoonMeridianSwitch.isOn = Settings.ShowNoonMeridians()
        MinorGridSwitch.isOn = Settings.ShowMinorGridLines()
        var Gap = Settings.GetMinorGridLineGap()
        if Gap == 0.0
        {
            Gap = 15.0
            Settings.SetMinorGridLineGap(Gap)
        }
        if !ValidGaps.contains(Gap)
        {
            Gap = 15.0
        }
        if let GapIndex = ValidGaps.firstIndex(of: Gap)
        {
            GapSegment.selectedSegmentIndex = GapIndex
        }
        else
        {
            GapSegment.selectedSegmentIndex = 1
        }
        let Alpha = Settings.GetTransparencyLevel()
        if !ValidTransparencies.contains(Alpha)
        {
            TransparencySegment.selectedSegmentIndex = 0
        }
        else
        {
            if let AlphaIndex = ValidTransparencies.firstIndex(of: Alpha)
            {
                TransparencySegment.selectedSegmentIndex = AlphaIndex
            }
            else
            {
                TransparencySegment.selectedSegmentIndex = 0
            }
        }
    }
    
    let ValidGaps = [5.0, 15.0, 30.0, 45.0]
    
    @IBAction func HandleGridSwitchChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            switch Switch
            {
                case NoonMeridianSwitch:
                    Settings.SetNoonMeridians(Switch.isOn)
                
                case EquatorSwitch:
                    Settings.SetEquator(Switch.isOn)
                
                case TropicSwitch:
                    Settings.SetTropics(Switch.isOn)
                
                case PolarSwitch:
                    Settings.SetPolarCircles(Switch.isOn)
                
                case PrimeMeridianSwitch:
                    Settings.SetPrimeMeridians(Switch.isOn)
                
                case MinorGridSwitch:
                    Settings.SetMinorGridLines(Switch.isOn)
                
                default:
                    break
            }
        }
    }
    
    @IBAction func HandleMinorGapChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            if Segment.selectedSegmentIndex > ValidGaps.count - 1
            {
                return
            }
            let Gap = ValidGaps[Segment.selectedSegmentIndex]
            Settings.SetMinorGridLineGap(Gap)
        }
    }
    
    @IBAction func HandleNewTransparency(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            if Segment.selectedSegmentIndex > ValidTransparencies.count - 1
            {
                return
            }
            let Alpha = ValidTransparencies[Segment.selectedSegmentIndex]
            Settings.SetTransparencyLevel(Alpha)
            ChangeDelegate?.Changed(Key: "GlobalAlpha", Value: Alpha as Any)
        }
    }
       
    let ValidTransparencies = [0.0, 0.1, 0.25, 0.35, 0.5]
    
    @IBAction func HandleShowNightChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetShowNight(Switch.isOn)
        }
    }
    
    @IBOutlet weak var ShowNightSwitch: UISwitch!
    @IBOutlet weak var TransparencySegment: UISegmentedControl!
    @IBOutlet weak var GapSegment: UISegmentedControl!
    @IBOutlet weak var MinorGridSwitch: UISwitch!
    @IBOutlet weak var NoonMeridianSwitch: UISwitch!
    @IBOutlet weak var PrimeMeridianSwitch: UISwitch!
    @IBOutlet weak var PolarSwitch: UISwitch!
    @IBOutlet weak var TropicSwitch: UISwitch!
    @IBOutlet weak var EquatorSwitch: UISwitch!
}
