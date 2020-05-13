//
//  SmallVersion.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/12/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class SmallVersion: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        Label1.text = Versioning.ApplicationName
        Label2.text = Versioning.MakeVersionString(IncludeVersionSuffix: true)
        Label3.text = Versioning.MakeBuildString()
        Label4.text = Versioning.CopyrightText()
    }
    
    @IBOutlet weak var Label1: UILabel!
    @IBOutlet weak var Label2: UILabel!
    @IBOutlet weak var Label3: UILabel!
    @IBOutlet weak var Label4: UILabel!
}
