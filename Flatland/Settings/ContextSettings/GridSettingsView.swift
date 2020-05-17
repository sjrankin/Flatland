//
//  GridSettingsView.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/17/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class GridSettingsView: UITableViewController, ChildClosed
{
    public weak var MainObject: MainProtocol? = nil
    public weak var ParentDelegate: ChildClosed? = nil
    var IsDirty = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        EquatorSwitch.isOn = Settings.ShowEquator()
        TropicsSwitch.isOn = Settings.ShowTropics()
        PolarCirclesSwitch.isOn = Settings.ShowPolarCircles()
        PrimeMeridiansSwitch.isOn = Settings.ShowPrimeMeridians()
        NoonMeridiansSwitch.isOn = Settings.ShowNoonMeridians()
        MinorGridLinesSwitch.isOn = Settings.ShowMinorGridLines()
        switch Settings.GetMinorGridLineGap()
        {
            case 5.0:
                GridGapSegment.selectedSegmentIndex = 0
            
            case 15.0:
                GridGapSegment.selectedSegmentIndex = 1
            
            case 30.0:
                GridGapSegment.selectedSegmentIndex = 2
            
            case 45.0:
                GridGapSegment.selectedSegmentIndex = 3
            
            default:
                GridGapSegment.selectedSegmentIndex = 1
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        ParentDelegate?.ChildWindowClosed(IsDirty)
        super.viewWillDisappear(animated)
    }
    
    func ChildWindowClosed(_ Dirty: Bool)
    {
    }
    
    
    @IBAction func HandleGridGapChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            if Segment.selectedSegmentIndex > 3
            {
                return
            }
            let NewGap = [5.0, 15.0, 30.0, 45.0][Segment.selectedSegmentIndex]
            Settings.SetMinorGridLineGap(NewGap)
            IsDirty = true
            MainObject?.GlobeObject()?.SetLineLayer()
        }
    }
    
    @IBAction func HandleGridLineChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            switch Switch
            {
                case MinorGridLinesSwitch:
                    Settings.SetMinorGridLines(Switch.isOn)
                
                case NoonMeridiansSwitch:
                    Settings.SetNoonMeridians(Switch.isOn)
                
                case PrimeMeridiansSwitch:
                    Settings.SetPrimeMeridians(Switch.isOn)
                
                case PolarCirclesSwitch:
                    Settings.SetPolarCircles(Switch.isOn)
                
                case TropicsSwitch:
                    Settings.SetTropics(Switch.isOn)
                
                case EquatorSwitch:
                    Settings.SetEquator(Switch.isOn)
                
                default:
                    return
            }
            IsDirty = true
            MainObject?.GlobeObject()?.SetLineLayer()
        }
    }
    
    @IBOutlet weak var MinorGridLinesSwitch: UISwitch!
    @IBOutlet weak var NoonMeridiansSwitch: UISwitch!
    @IBOutlet weak var PrimeMeridiansSwitch: UISwitch!
    @IBOutlet weak var PolarCirclesSwitch: UISwitch!
    @IBOutlet weak var TropicsSwitch: UISwitch!
    @IBOutlet weak var EquatorSwitch: UISwitch!
    @IBOutlet weak var GridGapSegment: UISegmentedControl!
}
