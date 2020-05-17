//
//  CityViewController.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class CityViewController: UITableViewController, ChildClosed
{
    public weak var MainObject: MainProtocol? = nil
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
            
            case .RelativeHeight:
                CityShapeSegment.selectedSegmentIndex = 3
        }
        if Settings.UseMetropolitanPopulation()
        {
            PopSegment.selectedSegmentIndex = 1
        }
        else
        {
            PopSegment.selectedSegmentIndex = 0
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
                
                case 3:
                    Settings.SetCityDisplayType(.RelativeHeight)
                
                default:
                    return
            }
            IsDirty = true
            MainObject?.GlobeObject()?.PlotCities()
        }
    }
    
    @IBAction func HandlePopulationSegmentChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let UseMetro = Segment.selectedSegmentIndex == 1 ? true : false
            Settings.SetUseMetroPopulation(UseMetro)
            IsDirty = true
            MainObject?.GlobeObject()?.PlotCities()
        }
    }
    
    @IBSegueAction func InstantiateCityColors(_ coder: NSCoder) -> CityColorSelector?
    {
        let Controller = CityColorSelector(coder: coder)
        Controller?.ParentDelegate = self
        Controller?.MainObject = MainObject
        return Controller
    }
    
    func ChildWindowClosed(_ Dirty: Bool)
    {
    }
    
    @IBOutlet weak var PopSegment: UISegmentedControl!
    @IBOutlet weak var CityShapeSegment: UISegmentedControl!
}
