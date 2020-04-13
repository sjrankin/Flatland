//
//  SettingsProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/26/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

protocol SettingsProtocol: class
{
    func SettingsDone()
    func ForceTime(NewTime: Date, WithOffset: Int)
}
