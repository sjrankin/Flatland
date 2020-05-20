//
//  WorldHeritageSiteView2.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/20/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class WorldHeritageSiteView2: UITableViewController
{
    public weak var MainObject: MainProtocol? = nil
    public weak var ParentDelegate: ChildClosed? = nil
    var IsDirty = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ShowSitesSwitch.isOn = Settings.ShowWorldHeritageSites()
        switch Settings.GetWorldHeritageSiteTypeFilter()
        {
            case .Both:
                SiteTypeSegment.selectedSegmentIndex = 3
            
            case .Cultural:
                SiteTypeSegment.selectedSegmentIndex = 2
            
            case .Natural:
                SiteTypeSegment.selectedSegmentIndex = 1
            
            case .Either:
                SiteTypeSegment.selectedSegmentIndex = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        ParentDelegate?.ChildWindowClosed(IsDirty)
        super.viewWillDisappear(animated)
    }
    
    @IBAction func HandleShowSitesChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetShowWorldHeritageSites(Switch.isOn)
            IsDirty = true
            MainObject?.GlobeObject()?.PlotWorldHeritageSites()
        }
    }
    
    @IBAction func HandleSiteTypeChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            switch Segment.selectedSegmentIndex
            {
                case 0:
                    Settings.SetWorldHeritageSiteTypeFilter(.Either)
                
                case 1:
                    Settings.SetWorldHeritageSiteTypeFilter(.Natural)
                
                case 2:
                    Settings.SetWorldHeritageSiteTypeFilter(.Cultural)
                
                case 3:
                    Settings.SetWorldHeritageSiteTypeFilter(.Both)
                
                default:
                return
            }
            IsDirty = true
            MainObject?.GlobeObject()?.PlotWorldHeritageSites()
        }
    }
    
    @IBOutlet weak var SiteTypeSegment: UISegmentedControl!
    @IBOutlet weak var ShowSitesSwitch: UISwitch!
}
