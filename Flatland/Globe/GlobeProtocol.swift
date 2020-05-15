//
//  GlobeProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/11/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

protocol GlobeProtocol: class
{
    func PlotSatellite(Satellite: Satellites, At: GeoPoint2)
}