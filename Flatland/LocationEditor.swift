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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        return UITableViewCell()
    }
    
    @IBAction func HandleAddNewLocation(_ sender: Any)
    {
    }
    
    @IBAction func HandleEditTable(_ sender: Any)
    {
    }
    
    @IBAction func HandleDeleteLocation(_ sender: Any)
    {
    }
    
    func UpdatedLocation(ID: UUID, Coordinates: GeoPoint2, Name: String, Color: UIColor)
    {
    }
    
    func GetLocation(ID: inout UUID, Coordinates: inout GeoPoint2, Name: inout String, Color: inout UIColor)
    {
        
    }
    
    @IBSegueAction func InstantiateLocationEditor(_ coder: NSCoder) -> EditLocation?
    {
        let Controller = EditLocation(coder: coder)
        Controller?.Delegate = self
        return Controller
    }
    
    @IBOutlet weak var LocationTable: UITableView!
}
