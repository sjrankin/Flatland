//
//  MainSettingsMenuController.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/12/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class MainSettingsMenuController: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        switch Settings.GetHourValueType()
        {
            case .None:
                HourTypeSegment.selectedSegmentIndex = 0
            
            case .RelativeToLocation:
                HourTypeSegment.selectedSegmentIndex = 3
            
            case .RelativeToNoon:
                HourTypeSegment.selectedSegmentIndex = 2
            
            case .Solar:
                HourTypeSegment.selectedSegmentIndex = 1
        }
        if Settings.GetViewType() == .FlatMap
        {
            let Index = Settings.GetImageCenter() == .NorthPole ? 0 : 1
            MapViewSegment.selectedSegmentIndex = Index
        }
        else
        {
            MapViewSegment.selectedSegmentIndex = 2
        }
    }
    
    @IBAction func HandleMapTypeChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            switch Segment.selectedSegmentIndex
            {
                case 0:
                    Settings.SetViewType(.FlatMap)
                    Settings.SetImageCenter(.NorthPole)
                
                case 1:
                    Settings.SetViewType(.FlatMap)
                    Settings.SetImageCenter(.SouthPole)
                
                case 2:
                    Settings.SetViewType(.Globe3D)
                
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleHourTypeChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            switch Segment.selectedSegmentIndex
            {
                case 0:
                    Settings.SetHourValueType(.None)
                
                case 1:
                    Settings.SetHourValueType(.Solar)
                
                case 2:
                    Settings.SetHourValueType(.RelativeToNoon)
                
                case 3:
                    Settings.SetHourValueType(.RelativeToLocation)
                
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleDoneButtonPressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var DoneButton: UIBarButtonItem!
    @IBOutlet weak var HourTypeSegment: UISegmentedControl!
    @IBOutlet weak var MapViewSegment: UISegmentedControl!
}
