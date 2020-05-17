//
//  MapSettingsView.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/17/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class MapSettingsView: UITableViewController, ChildClosed
{
    public weak var MainObject: MainProtocol? = nil
    public weak var ParentDelegate: ChildClosed? = nil
    var IsDirty = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Show3DStarsSwitch.isOn = Settings.ShowStars()
        Show3DMoonlightSwitch.isOn = Settings.GetShowMoonlight()
        let GlobeAlpha = Settings.GetTransparencyLevel()
        switch GlobeAlpha
        {
            case 0.0:
                GlobeTransparencySegment.selectedSegmentIndex = 0
            
            case 0.15:
                GlobeTransparencySegment.selectedSegmentIndex = 1
            
            case 0.35:
                GlobeTransparencySegment.selectedSegmentIndex = 2
            
            case 0.5:
                GlobeTransparencySegment.selectedSegmentIndex = 3
            
            default:
                GlobeTransparencySegment.selectedSegmentIndex = 0
        }
    }
    
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
    
    @IBAction func Handle2DNightSwitchChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetShowNight(Switch.isOn)
            MainObject?.SetNightMask()
            IsDirty = true
        }
    }
    
    @IBAction func HandleShow3DStarsChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetShowStars(Switch.isOn)
            if Switch.isOn
            {
                MainObject?.ShowZoomingStars()
            }
            else
            {
                MainObject?.HideZoomingStars()
            }
            IsDirty = true
        }
    }
    
    @IBAction func HandleShow3DMoonlightChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetShowMoonlight(Switch.isOn)
            MainObject?.GlobeObject()?.SetMoonlight(Show: Switch.isOn)
            IsDirty = true
        }
    }
    
    @IBAction func HandleGlobeTransparencyChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            switch Segment.selectedSegmentIndex
            {
                case 0:
                    Settings.SetTransparencyLevel(0.0)
                
                case 1:
                    Settings.SetTransparencyLevel(0.15)
                
                case 2:
                    Settings.SetTransparencyLevel(0.35)
                
                case 3:
                    Settings.SetTransparencyLevel(0.5)
                
                default:
                    return
            }
            MainObject?.GlobeObject()?.UpdateSurfaceTransparency()
            IsDirty = true
        }
    }
    
    @IBSegueAction func InstantiateGridLineView(_ coder: NSCoder) -> GridSettingsView?
    {
        let Controller = GridSettingsView(coder: coder)
        Controller?.ParentDelegate = self
        Controller?.MainObject = MainObject
        return Controller
    }
    
    @IBOutlet weak var GlobeTransparencySegment: UISegmentedControl!
    @IBOutlet weak var Show3DMoonlightSwitch: UISwitch!
    @IBOutlet weak var Show3DStarsSwitch: UISwitch!
    @IBOutlet weak var Show2DNightSwitch: UISwitch!
}
