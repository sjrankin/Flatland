//
//  LocationEditor.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class LocationEditor: UIViewController, UITableViewDelegate, UITableViewDataSource,
    LocationEdited
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        LocationTable.layer.borderColor = UIColor.black.cgColor
        UserLocations = Settings.GetLocations()
        if UserLocations.count > 0
        {
            EditLocationButton.isEnabled = true
        }
        else
        {
            EditLocationButton.isEnabled = false
        }
        LocationTable.reloadData()
    }
    
    var UserLocations = [(ID: UUID, Coordinates: GeoPoint2, Name: String, Color: UIColor)]()
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return LocationCell.CellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return UserLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = LocationCell(style: .default, reuseIdentifier: "LocationCell")
        Cell.SetData(Name: UserLocations[indexPath.row].Name,
                     Location: UserLocations[indexPath.row].Coordinates,
                     Color: UserLocations[indexPath.row].Color,
                     TableWidth: LocationTable.frame.width)
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
            UserLocations.remove(at: indexPath.row)
            LocationTable.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        UserLocations.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        LocationTable.reloadData()
    }
    
    @IBAction func HandleEditTable(_ sender: Any)
    {
        LocationTable.setEditing(!LocationTable.isEditing, animated: true)
        if LocationTable.isEditing
        {
            EditTableButton.title = "Done"
            AddButton.isEnabled = false
            EditLocationButton.isEnabled = false
        }
        else
        {
            EditTableButton.title = "Edit Table"
            AddButton.isEnabled = true
            EditLocationButton.isEnabled = true
        }
    }
    
    @IBAction func HandleDeleteLocation(_ sender: Any)
    {
        if let Index = LocationTable.indexPathForSelectedRow
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
            if let Index = LocationTable.indexPathForSelectedRow
            {
                UserLocations.remove(at: Index.row)
                LocationTable.reloadData()
            }
        }
    }
    
    func UpdatedLocation(ID: UUID, Coordinates: GeoPoint2, Name: String, Color: UIColor)
    {
        RemoveLocationWith(ID: ID)
        UserLocations.append((ID: UUID(), Coordinates: Coordinates, Name: Name, Color: Color))
        LocationTable.reloadData()
    }
    
    func RemoveLocationWith(ID: UUID)
    {
        UserLocations.removeAll(where: {$0.ID == ID})
    }
    
    func AddedLocation(Coordinates: GeoPoint2, Name: String, Color: UIColor)
    {
        UserLocations.append((ID: UUID(), Coordinates: Coordinates, Name: Name, Color: Color))
        LocationTable.reloadData()
    }
    
    func GetLocation(ID: inout UUID, Coordinates: inout GeoPoint2, Name: inout String,
                     Color: inout UIColor, Editing: inout Bool)
    {
        if let Index = LocationTable.indexPathForSelectedRow
        {
            ID = UserLocations[Index.row].ID
            Coordinates = UserLocations[Index.row].Coordinates
            Name = UserLocations[Index.row].Name
            Color = UserLocations[Index.row].Color
            Editing = true
        }
    }
    
    var IsEditing: Bool = false
    
    @IBSegueAction func InstantiateEditLocation(_ coder: NSCoder) -> EditLocation?
    {
        IsEditing = true
        let Controller = EditLocation(coder: coder)
        Controller?.Delegate = self
        return Controller
    }
    
    @IBSegueAction func InstantiateAddLocation(_ coder: NSCoder) -> EditLocation?
    {
        IsEditing = false
        let Controller = EditLocation(coder: coder)
        Controller?.Delegate = self
        return Controller
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        Settings.SetLocations(UserLocations)
        super.viewWillDisappear(animated)
    }
    
    @IBOutlet weak var AddButton: UIBarButtonItem!
    @IBOutlet weak var EditTableButton: UIBarButtonItem!
    @IBOutlet weak var EditLocationButton: UIBarButtonItem!
    @IBOutlet weak var LocationTable: UITableView!
}
