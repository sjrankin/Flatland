//
//  MainProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/16/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

protocol MainProtocol: class
{
    func GlobeObject() -> GlobeView?
    func MainViewTypeChanged()
    func SetTexture(_ MapType: MapTypes)
    func ShowLocalData(_ Show: Bool)
    func ShowCities(_ Show: Bool)
    func SetNightMask()
    func ShowZoomingStars()
    func HideZoomingStars()
    func SetDisplayLanguage()
}
