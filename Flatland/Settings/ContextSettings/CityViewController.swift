//
//  CityViewController.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class CityViewController: UITableViewController
{
    public weak var ParentDelegate: ChildClosed? = nil
    var IsDirty = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        switch Settings.CityDisplayType()
        {
            case .UniformEmbedded:
                CityShapeSegment.selectedSegmentIndex = 0
            
            case .RelativeEmbedded:
                CityShapeSegment.selectedSegmentIndex = 1
            
            case .RelativeFloating:
                CityShapeSegment.selectedSegmentIndex = 2
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        ParentDelegate?.ChildWindowClosed(IsDirty)
        super.viewWillDisappear(animated)
    }
    
    @IBAction func HandleCityShapeChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            switch Segment.selectedSegmentIndex
            {
                case 0:
                    Settings.SetCityDisplayType(.UniformEmbedded)
                
                case 1:
                    Settings.SetCityDisplayType(.RelativeEmbedded)
                
                case 2:
                    Settings.SetCityDisplayType(.RelativeFloating)
                
                default:
                    return
            }
            IsDirty = true
        }
    }
    
    @IBOutlet weak var CityShapeSegment: UISegmentedControl!
}
