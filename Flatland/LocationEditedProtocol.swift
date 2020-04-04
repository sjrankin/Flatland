//
//  LocationEditedProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

protocol LocationEdited: class
{
    func GetLocation(ID: inout UUID, Coordinates: inout GeoPoint2, Name: inout String, Color: inout UIColor)
    func UpdatedLocation(ID: UUID, Coordinates: GeoPoint2, Name: String, Color: UIColor)
}
