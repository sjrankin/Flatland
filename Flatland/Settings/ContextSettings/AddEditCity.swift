//
//  AddEditCity.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class AddEditCity: UITableViewController
{
    public weak var ParentDelegate: ChildClosed? = nil
    var IsDirty = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        ParentDelegate?.ChildWindowClosed(IsDirty)
        super.viewWillDisappear(animated)
    }
}
