//
//  +MoreLocations.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension MainView
{
    func LoadWorldHeritageSites()
    {
        if let FileURL = Bundle.main.url(forResource: "WorldHeritageSites2019", withExtension: "json")
        {
            do
            {
                
            }
            catch
            {
                print("Error loading world heritage sites: \(error)")
            }
        }
    }
}
