//
//  UserCityListView.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class UserCityListView: UIViewController, ChildClosed, LocationEdited,
    UITableViewDelegate, UITableViewDataSource
{
    public weak var MainObject: MainProtocol? = nil
    public weak var ParentDelegate: ChildClosed? = nil
    var IsDirty = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        UserCityTable.layer.borderColor = UIColor.black.cgColor
        UserLocations = Settings.GetLocations()
        if UserLocations.count > 0
        {
            EditCityButton.isEnabled = true
        }
        else
        {
            EditCityButton.isEnabled = false
        }
        UserCityTable.reloadData()
    }
    
    var UserLocations = [(ID: UUID, Coordinates: GeoPoint2, Name: String, Color: UIColor)]()
    
    override func viewWillDisappear(_ animated: Bool)
    {
        Settings.SetLocations(UserLocations)
        if IsDirty
        {
            MainObject?.GlobeObject()?.PlotCities()
        }
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
    
    // MARK: - Table control handling.
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return LocationCell2.CellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return UserLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = LocationCell2(style: .default, reuseIdentifier: "LocationCell")
        Cell.SetData(Name: UserLocations[indexPath.row].Name,
                     Location: UserLocations[indexPath.row].Coordinates,
                     Color: UserLocations[indexPath.row].Color,
                     TableWidth: UserCityTable.frame.width)
        return Cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            IsDirty = true
            UserLocations.remove(at: indexPath.row)
            UserCityTable.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        UserLocations.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        UserCityTable.reloadData()
    }
    
    // MARK: - Button handling for table.
    
    @IBAction func HandleEditTableButton(_ sender: Any)
    {
        UserCityTable.setEditing(!UserCityTable.isEditing, animated: true)
        if UserCityTable.isEditing
        {
            EditTableButton.setTitle("Done", for: .normal)
            AddCityButton.isEnabled = false
            EditCityButton.isEnabled = false
        }
        else
        {
            EditTableButton.setTitle("Edit table", for: .normal)
            AddCityButton.isEnabled = true
            EditCityButton.isEnabled = true
        }
    }
    
    @IBAction func HandleDeleteLocation(_ sender: Any)
    {
        if let Index = UserCityTable.indexPathForSelectedRow
        {
            let Name = UserLocations[Index.row].Name
            let Alert = UIAlertController(title: "Delete Location?",
                                          message: "Do you really want to delete the location \(Name) from your list of locations?",
                preferredStyle: .alert)
            Alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            Alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: DeleteLocation))
            if let PopOver = Alert.popoverPresentationController
            {
                PopOver.sourceView = self.view
                PopOver.permittedArrowDirections = []
                PopOver.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            }
            self.present(Alert, animated: true)
        }
    }
    
    @objc func DeleteLocation(_ Action: UIAlertAction)
    {
        if Action.title == "Yes"
        {
            if let Index = UserCityTable.indexPathForSelectedRow
            {
                UserLocations.remove(at: Index.row)
                UserCityTable.reloadData()
                IsDirty = true
            }
        }
    }
    
    func UpdatedLocation(ID: UUID, Coordinates: GeoPoint2, Name: String, Color: UIColor)
    {
        RemoveLocationWith(ID: ID)
        UserLocations.append((ID: UUID(), Coordinates: Coordinates, Name: Name, Color: Color))
        UserCityTable.reloadData()
    }
    
    func RemoveLocationWith(ID: UUID)
    {
        UserLocations.removeAll(where: {$0.ID == ID})
    }
    
    func AddedLocation(Coordinates: GeoPoint2, Name: String, Color: UIColor)
    {
        UserLocations.append((ID: UUID(), Coordinates: Coordinates, Name: Name, Color: Color))
        UserCityTable.reloadData()
        IsDirty = true
    }
    
    func GetLocation(ID: inout UUID, Coordinates: inout GeoPoint2, Name: inout String,
                     Color: inout UIColor, Editing: inout Bool)
    {
        if let Index = UserCityTable.indexPathForSelectedRow
        {
            ID = UserLocations[Index.row].ID
            Coordinates = UserLocations[Index.row].Coordinates
            Name = UserLocations[Index.row].Name
            Color = UserLocations[Index.row].Color
            Editing = true
        }
    }
    
    var IsEditing: Bool = false
    
    // MARK: - Segue instantiation events.
    
    @IBSegueAction func InstantiateEditLocation(_ coder: NSCoder) -> EditLocation2?
    {
        IsEditing = true
        let Controller = EditLocation2(coder: coder)
        Controller?.ParentDelegate = self
        Controller?.MainObject = MainObject
        Controller?.LocationDelegate = self
        return Controller
    }
    
    @IBSegueAction func InstantiateAddLocation(_ coder: NSCoder) -> EditLocation2?
    {
        IsEditing = false
        let Controller = EditLocation2(coder: coder)
        Controller?.ParentDelegate = self
        Controller?.MainObject = MainObject
        Controller?.LocationDelegate = self
        return Controller
    }
    
    // MARK: - Interface builder outlets.
    
    @IBOutlet weak var EditTableButton: UIButton!
    @IBOutlet weak var UserCityTable: UITableView!
    @IBOutlet weak var AddCityButton: UIButton!
    @IBOutlet weak var ClearListButton: UIButton!
    @IBOutlet weak var EditCityButton: UIButton!
}
