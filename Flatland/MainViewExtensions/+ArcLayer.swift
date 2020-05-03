//
//  +ArcLayer.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/8/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Contains functions related to drawing arcs.
extension MainView
{
    /// Make an arc shape. Intended for use to indicate daylight/nighttime.
    /// - Parameter Start: Starting longitude (in degrees).
    /// - Parameter End: Ending longitude (in degrees).
    /// - Parameter ArcWidth: The thickness of the arc which is the extent of the latitude.
    /// - Parameter Center: The center of the arc (which is presumed to be the center of the map).
    /// - Parameter ArcColor: The fill color of the arc.
    /// - Parameter Rectangle: The rectangle of the map view.
    /// - Returns: `CAShapeLayer` with the arc.
    func MakeArc(Start: CGFloat, End: CGFloat, Radius: CGFloat, ArcWidth: CGFloat,
                 Center: CGPoint, ArcColor: UIColor, Rectangle: CGRect) -> CAShapeLayer
    {
        let ArcLayer = CAShapeLayer()
        ArcLayer.frame = Rectangle
        ArcLayer.bounds = Rectangle
        ArcLayer.backgroundColor = UIColor.clear.cgColor
        let Arc = UIBezierPath(arcCenter: Center,
                               radius: Radius - CGFloat(ArcWidth / 2.0),
                               startAngle: (Start - 90).Radians,
                               endAngle: (End - 90).Radians,
                               clockwise: true)
        Arc.lineWidth = 50//ArcWidth
        Arc.stroke()
        ArcLayer.strokeColor = ArcColor.withAlphaComponent(0.5).cgColor
        ArcLayer.lineWidth = CGFloat(50)//ArcWidth)
        ArcLayer.fillColor = UIColor.clear.cgColor
        ArcLayer.path = Arc.cgPath
        return ArcLayer
    }
    
    /// Make an arc shape. Intended for use to indicate daylight/nighttime.
    /// - Parameter Start: Starting longitude (in degrees).
    /// - Parameter End: Ending longitude (in degrees).
    /// - Parameter ArcWidth: The thickness of the arc which is the extent of the latitude.
    /// - Parameter Center: The center of the arc (which is presumed to be the center of the map).
    /// - Parameter ArcColor: The fill color of the arc.
    /// - Parameter Rectangle: The rectangle of the map view.
    /// - Returns: `CAShapeLayer` with the arc.
    func MakeArc(Start: CGFloat, End: CGFloat, Radius: CGFloat, ArcRadius: CGFloat, ArcWidth: CGFloat,
                 Center: CGPoint, ArcColor: UIColor, Rectangle: CGRect) -> CAShapeLayer
    {
        let ArcLayer = CAShapeLayer()
        ArcLayer.frame = Rectangle
        ArcLayer.bounds = Rectangle
        ArcLayer.backgroundColor = UIColor.clear.cgColor
        let Arc = UIBezierPath(arcCenter: Center,
                               radius: Radius - CGFloat(ArcRadius / 1.0),
                               startAngle: (Start - 90).Radians,
                               endAngle: (End - 90).Radians,
                               clockwise: true)
        Arc.lineWidth = ArcWidth
        Arc.stroke()
        ArcLayer.strokeColor = ArcColor.withAlphaComponent(0.5).cgColor
        ArcLayer.lineWidth = CGFloat(ArcWidth)
        ArcLayer.fillColor = UIColor.clear.cgColor
        ArcLayer.path = Arc.cgPath
        return ArcLayer
    }
}
