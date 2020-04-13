//
//  Test3D.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/12/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class Test3D: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitializeView()
    }
    
    func InitializeView()
    {
        if EarthView == nil
        {
            fatalError("EarthView missing")
        }
        EarthView.autoenablesDefaultLighting = false
        EarthView.scene = SCNScene()
        EarthView.backgroundColor = UIColor.black
        
        let Camera = SCNCamera()
        Camera.fieldOfView = 90.0
        Camera.usesOrthographicProjection = true
        Camera.orthographicScale = 12
        CameraNode = SCNNode()
        CameraNode.camera = Camera
        CameraNode.position = SCNVector3(0.0, 0.0, 16.0)
        
        let Light = SCNLight()
        Light.type = .omni
        Light.intensity = 800
        Light.castsShadow = true
        Light.shadowColor = UIColor.black.withAlphaComponent(0.80)
        Light.shadowMode = .forward
        Light.shadowRadius = 10.0
        Light.color = UIColor.white
        LightNode = SCNNode()
        LightNode.light = Light
        LightNode.position = SCNVector3(0.0, 0.0, 80.0)
        
        EarthView.scene?.rootNode.addChildNode(CameraNode)
        EarthView.scene?.rootNode.addChildNode(LightNode)
        
        AddEarth()
    }
    
    var CameraNode = SCNNode()
    var LightNode = SCNNode()
    
    func AddEarth()
    {
        if EarthNode != nil
        {
            EarthNode?.removeAllActions()
            EarthNode?.removeFromParentNode()
            EarthNode = nil
        }
        if LineNode != nil
        {
            LineNode?.removeAllActions()
            LineNode?.removeFromParentNode()
            LineNode = nil
        }
        #if true
        let Sphere = SCNSphere(radius: 10)
        Sphere.segmentCount = 100
        let LineSphere = SCNSphere(radius: 10.2)
        LineSphere.segmentCount = 100
        #else
        let Sphere = SCNBox(width: 15, height: 15, length: 15, chamferRadius: 1.0)
        #endif
        EarthNode = SCNNode(geometry: Sphere)
        EarthNode?.position = SCNVector3(0.0, 0.0, 0.0)
        EarthNode?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "BaseWorldMap")
        EarthNode?.geometry?.firstMaterial?.specular.contents = UIColor.white
        
        LineNode = SCNNode(geometry: LineSphere)
        LineNode?.position = SCNVector3(0.0, 0.0, 0.0)
        LineNode?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "WorldMapLines")
        LineNode?.castsShadow = false
        
        let Declination = Sun.Declination(For: Date())
        print("Declination=\(Declination)")
        let Now = Date()
        var Cal = Calendar(identifier: .gregorian)
        Cal.timeZone = TimeZone(identifier: "UTC")!
        let Hour = Cal.component(.hour, from: Now)
        let Minute = Cal.component(.minute, from: Now)
        let Second = Cal.component(.second, from: Now)
        let UTCSeconds = Second + (Minute * 60) + (Hour * 60 * 60)
        let Percent = Double(UTCSeconds) / Double(24 * 60 * 60)
        let Rotation = Percent * 360.0
        print("\(Hour), \(Minute), \(Second), Degrees=\(Rotation)")
        EarthNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
        LineNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
        EarthNode?.rotation = SCNVector4(0.0, 1.0, 0.0, 90.0.Radians)
        LineNode?.rotation = SCNVector4(0.0, 1.0, 0.0, 90.0.Radians)
        EarthNode?.rotation = SCNVector4(1.0, 0.0, 0.0, Declination.Radians)
        LineNode?.rotation = SCNVector4(1.0, 0.0, 0.0, Declination.Radians)
//        EarthNode?.rotation = SCNVector4(1.0,0.0,0.0, Declination.Radians)
        print("Pivot point=\(EarthNode?.pivot)")
        
        EarthView.prepare([EarthNode!, LineNode!], completionHandler:
            {
             success in
                if success
                {
                    self.EarthView.scene?.rootNode.addChildNode(self.EarthNode!)
                    self.EarthView.scene?.rootNode.addChildNode(self.LineNode!)
                }
        }
            )

        let EarthRotate = SCNAction.rotateBy(x: 0.0, y: 360.0 * CGFloat.pi / 180.0, z: 0.0, duration: 30.0)
        let RotateForever = SCNAction.repeatForever(EarthRotate)
        EarthNode?.runAction(RotateForever)
        
        LineNode?.runAction(RotateForever)
    }
    
    var RotationAccumulator: CGFloat = 0.0
    
    var LineNode: SCNNode? = nil
    var EarthNode: SCNNode? = nil

    @IBAction func HandleResetButtonPressed(_ sender: Any)
    {
    }
    
    @IBOutlet weak var EarthView: SCNView!
}
