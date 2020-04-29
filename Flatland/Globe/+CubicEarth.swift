//
//  +CubicEarth.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/29/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension GlobeView
{
    /// Draws a cubical Earth for no other reason than being silly.
    func ShowCubicEarth()
    {
        EarthNode?.removeAllActions()
        EarthNode?.removeFromParentNode()
        SeaNode?.removeAllActions()
        SeaNode?.removeFromParentNode()
        LineNode?.removeAllActions()
        LineNode?.removeFromParentNode()
        SystemNode?.removeAllActions()
        SystemNode?.removeFromParentNode()
        HourNode?.removeAllActions()
        HourNode?.removeFromParentNode()
        
        let EarthCube = SCNBox(width: 10.0, height: 10.0, length: 10.0, chamferRadius: 0.5)
        EarthNode = SCNNode(geometry: EarthCube)
        
        EarthNode?.position = SCNVector3(0.0, 0.0, 0.0)
        EarthNode?.geometry?.materials.removeAll()
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.nx)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.pz)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.px)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.nz)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.ny, Rotated: 270.0)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.py, Rotated: 90.0)!)
        
        EarthNode?.geometry?.firstMaterial?.specular.contents = UIColor.clear
        EarthNode?.geometry?.firstMaterial?.lightingModel = .blinn
        
        UpdateHourLabels(With: Settings.GetHourValueType())
        
        let Declination = Sun.Declination(For: Date())
        SystemNode = SCNNode()
        SystemNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
        HourNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
        
        self.prepare([EarthNode!], completionHandler:
            {
                success in
                if success
                {
                    self.SystemNode?.addChildNode(self.EarthNode!)
                    self.scene?.rootNode.addChildNode(self.SystemNode!)
                }
        }
        )
    }
}
