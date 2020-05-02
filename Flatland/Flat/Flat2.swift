//
//  Flat2.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/1/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class Flat2: SCNView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        InitializeView()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        InitializeView()
    }
    
    func InitializeView()
    {
        self.allowsCameraControl = false
        self.autoenablesDefaultLighting = false
        self.scene = SCNScene()
        self.backgroundColor = UIColor.clear
        
        let Camera = SCNCamera()
        Camera.fieldOfView = 90.0
        Camera.usesOrthographicProjection = true
        Camera.orthographicScale = 14
        CameraNode = SCNNode()
        CameraNode?.camera = Camera
        CameraNode?.position = SCNVector3(0.0, 0.0, 16.0)
        
        let Light = SCNLight()
        Light.type = .spot
        Light.spotInnerAngle = 90.0
        Light.spotOuterAngle = 95.0
        Light.intensity = 800
        /*
        Light.castsShadow = true
        Light.shadowColor = UIColor.black.withAlphaComponent(0.8)
        Light.shadowMode = .forward
        Light.shadowRadius = 10.0
 */
        Light.color = UIColor.white
        LightNode = SCNNode()
        LightNode?.light = Light
        LightNode?.position = SCNVector3(0.0, 0.0, 10.0)
        LightNode?.eulerAngles = SCNVector3(45.0 * CGFloat.pi / 180.0, 0.0, 0.0)
        
        let MoonLight = SCNLight()
        MoonLight.type = .omni
        MoonLight.intensity = 200
        MoonLight.color = UIColor.cyan
        MoonNode = SCNNode()
        MoonNode?.light = MoonLight
        MoonNode?.position = SCNVector3(0.0, 0.0, 16.0)
        
        self.scene?.rootNode.addChildNode(CameraNode!)
        self.scene?.rootNode.addChildNode(LightNode!)
        self.scene?.rootNode.addChildNode(MoonNode!)
        
        CreateEarth()
    }
    
    var CameraNode: SCNNode? = nil
    var LightNode: SCNNode? = nil
    var MoonNode: SCNNode? = nil
    
    func CreateEarth()
    {
        let EarthShape = SCNPlane(width: 20.0, height: 20.0)
        EarthNode = SCNNode(geometry: EarthShape)
                SetEarthTexture()
        SystemNode = SCNNode()
        SystemNode?.addChildNode(EarthNode!)
        SystemNode?.position = SCNVector3(0.0, 0.0, 1.0)
        self.scene?.rootNode.addChildNode(SystemNode!)
        let Rotate = SCNAction.rotateBy(x: 0.0, y: 0.0, z: CGFloat.pi / 180.0, duration: 0.01)
        let RotateForever = SCNAction.repeatForever(Rotate)
        SystemNode?.runAction(RotateForever)
    }
    
    var EarthNode: SCNNode? = nil
    var SystemNode: SCNNode? = nil
    
    func SetEarthTexture()
    {
        let Test = MapManager.ImageFor(MapType: .Standard, ViewType: .FlatMap, ImageCenter: .SouthPole)
        EarthNode?.geometry?.firstMaterial?.diffuse.contents = Test
        EarthNode?.geometry?.firstMaterial?.specular.contents = UIColor.yellow
    }
}
