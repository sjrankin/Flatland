//
//  MapSetController.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/14/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class MapSetController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    public weak var MainObject: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        MapCategoryTable.layer.borderColor = UIColor.black.cgColor
        MapTable.layer.borderColor = UIColor.black.cgColor
        for Category in MapCategories.allCases
        {
            CategoryList.append((Category, Category.rawValue))
        }
        MapCategoryTable.reloadData()
        if let InitialCategory = MapManager.CategoryFor(Map: Settings.GetGlobeMapType())
        {
            let Index = CategoryIndex(For: InitialCategory)
            MapCategoryTable.selectRow(at: IndexPath(row: Index, section: 0),
                                       animated: true, scrollPosition: UITableView.ScrollPosition.middle)
            FillMapList(InitialCategory)
        }
        CurrentMap.text = Settings.GetGlobeMapType().rawValue
    }
    
    func CategoryIndex(For Category: MapCategories) -> Int
    {
        var Index = 0
        for (SomeCategory, _) in CategoryList
        {
            if SomeCategory == Category
            {
                return Index
            }
            Index = Index + 1
        }
        return 0
    }
    
    var CategoryList = [(MapCategories, String)]()
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        switch tableView
        {
            case MapTable:
                return 45.0
            
            case MapCategoryTable:
                return 45.0
            
            default:
                return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch tableView
        {
            case MapTable:
                return MapList.count
            
            case MapCategoryTable:
                return CategoryList.count
            
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView
        {
            case MapTable:
                let Cell = UITableViewCell(style: .default, reuseIdentifier: "MapCell")
                Cell.textLabel?.text = MapList[indexPath.row].1
                if Settings.GetGlobeMapType() == MapList[indexPath.row].0
                {
                    Cell.accessoryType = .checkmark
                }
                else
                {
                    Cell.accessoryType = .none
                }
                return Cell
            
            case MapCategoryTable:
                let Cell = UITableViewCell(style: .default, reuseIdentifier: "CategoryCell")
                Cell.textLabel?.text = CategoryList[indexPath.row].1
                return Cell
            
            default:
                return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch tableView
        {
            case MapTable:
                let NewMap = MapList[indexPath.row].0
                Settings.SetGlobeMapType(NewMap)
                Settings.SetFlatlandMapType(NewMap)
                MapTable.reloadData()
                CurrentMap.text = NewMap.rawValue
                MainObject?.SetTexture(NewMap)
            
            case MapCategoryTable:
                let Category = CategoryList[indexPath.row].0
                FillMapList(Category)
            
            default:
                break
        }
    }
    
    func FillMapList(_ Category: MapCategories)
    {
        MapList.removeAll()
        let Maps = MapManager.GetMapsInCategory(Category)
        for Map in Maps
        {
            MapList.append((Map, Map.rawValue))
        }
        MapTable.reloadData()
    }
    
    var MapList = [(MapTypes, String)]()
    
    @IBOutlet weak var CurrentMap: UILabel!
    @IBOutlet weak var MapCategoryTable: UITableView!
    @IBOutlet weak var MapTable: UITableView!
}
