//
//  2DTest.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/1/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class Test2D: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //self.view.isUserInteractionEnabled = true
        Test.isUserInteractionEnabled = true
        //Test.allowsCameraControl = true
    }
    
    @IBOutlet weak var Test: Flat2!
}
