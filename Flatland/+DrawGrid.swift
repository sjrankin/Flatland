//
//  +DrawGrid.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/5/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension MainView
{
    /// Initialize/draw the grid on the Earth. Which lines are drawn depend on user settings.
    /// - Parameter Radians: Rotational value of the prime meridians.
    func DrawGrid(_ Radians: Double)
    {
        if GridOverlay.layer.sublayers != nil
        {
            for Layer in GridOverlay.layer.sublayers!
            {
                if Layer.name == "PrimeMeridian"
                {
                    Layer.removeFromSuperlayer()
                }
            }
        }
        GridOverlay.backgroundColor = UIColor.clear
        let Grid = CAShapeLayer()
        Grid.name = "ViewGrid"
        Grid.bounds = GridOverlay.frame
        Grid.frame = GridOverlay.frame
        let Lines = UIBezierPath()
        let CenterH = Grid.bounds.size.width / 2.0
        let CenterV = Grid.bounds.size.height / 2.0
        if Settings.ShowNoonMeridians()
        {
            Lines.move(to: CGPoint(x: CenterH, y: 0))
            Lines.addLine(to: CGPoint(x: CenterH, y: Grid.frame.size.height))
            Lines.move(to: CGPoint(x: 0, y: CenterV))
            Lines.addLine(to: CGPoint(x: Grid.frame.size.width, y: CenterV))
        }
        
        let MeridianLayer = CAShapeLayer()
        MeridianLayer.fillColor = UIColor.clear.cgColor
        MeridianLayer.strokeColor = UIColor.systemYellow.withAlphaComponent(0.5).cgColor
        MeridianLayer.lineWidth = 1.0
        let Meridians = UIBezierPath()
        if Settings.ShowPrimeMeridians()
        {
            MeridianLayer.name = "PrimeMeridian"
            MeridianLayer.frame = GridOverlay.bounds
            MeridianLayer.bounds = GridOverlay.bounds
            Meridians.move(to: CGPoint(x: CenterH, y: 0))
            Meridians.addLine(to: CGPoint(x: CenterH, y: Grid.frame.size.height))
            Meridians.move(to: CGPoint(x: 0, y: CenterV))
            Meridians.addLine(to: CGPoint(x: Grid.frame.size.width, y: CenterV))
            let Rotation = CATransform3DMakeRotation(CGFloat(-Radians), 0.0, 0.0, 1.0)
            MeridianLayer.transform = Rotation
        }
        if Settings.ShowTropics()
        {
            let TropicDistance: CGFloat = 23.43666
            let TropicPercent = Grid.bounds.size.width * (TropicDistance / 180.0)
            let CancerWidth = CenterH - TropicPercent
            let Cancer = UIBezierPath(ovalIn: CGRect(x: CenterH - (CancerWidth / 2.0),
                                                     y: CenterV - (CancerWidth / 2.0),
                                                     width: CancerWidth,
                                                     height: CancerWidth))
            let CapricornWidth = CenterH + TropicPercent
            let Capricorn = UIBezierPath(ovalIn: CGRect(x: CenterH - (CapricornWidth / 2.0),
                                                        y: CenterV - (CapricornWidth / 2.0),
                                                        width: CapricornWidth,
                                                        height: CapricornWidth))
            Meridians.append(Cancer)
            Meridians.append(Capricorn)
        }
        if Settings.ShowPolarCircles()
        {
            let PolarCircle: CGFloat = 66.55
            let InnerPercent = Grid.bounds.size.width * (PolarCircle / 180.0)
            let InnerWidth = CenterH - InnerPercent
            let InnerCircle = UIBezierPath(ovalIn: CGRect(x: CenterH - (InnerWidth / 2.0),
                                                          y: CenterV - (InnerWidth / 2.0),
                                                          width: InnerWidth,
                                                          height: InnerWidth))
            let OuterPercent = Grid.bounds.size.width * (PolarCircle / 180.0)
            let OuterWidth = CenterH + OuterPercent
            let OuterCircle = UIBezierPath(ovalIn: CGRect(x: CenterH - (OuterWidth / 2.0),
                                                          y: CenterV - (OuterWidth / 2.0),
                                                          width: OuterWidth,
                                                          height: OuterWidth))
            Meridians.append(InnerCircle)
            Meridians.append(OuterCircle)
        }
        if Settings.ShowEquator()
        {
            let Equator = UIBezierPath(ovalIn: CGRect(x: CenterH / 2,
                                                      y: CenterV / 2,
                                                      width: CenterH,
                                                      height: CenterV))
            Meridians.append(Equator)
        }
        MeridianLayer.path = Meridians.cgPath
        GridOverlay.layer.addSublayer(MeridianLayer)
        Grid.strokeColor = UIColor.black.withAlphaComponent(0.5).cgColor
        Grid.lineWidth = 1.0
        Grid.fillColor = UIColor.clear.cgColor
        Grid.path = Lines.cgPath
        GridOverlay.layer.addSublayer(Grid)
    }
}
