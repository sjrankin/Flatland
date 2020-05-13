//
//  MapMenu.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/12/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class MapMenu: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        MapTable.layer.backgroundColor = UIColor.black.cgColor
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        return UITableViewCell()
    }
    
    @IBAction func HandleBackButtonPressed(_ sender: Any)
    {
    }
    
    @IBAction func HandleSelectButtonPressed(_ sender: Any)
    {
    }
    
    @IBAction func HandleCloseButtonPressed(_ sender: Any)
    {
    }
    
    @IBOutlet weak var CloseButton: UIButton!
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var SelectButton: UIButton!
    @IBOutlet weak var MapTable: UITableView!
}
