//
//  SomethingChanged.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

protocol SomethingChanged: class
{
    func Changed(Key: String, Value: Any)
}
