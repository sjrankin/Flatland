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
        if SeaNode != nil
        {
            SeaNode?.removeAllActions()
            SeaNode?.removeFromParentNode()
            SeaNode = nil
        }
        if LineNode != nil
        {
            LineNode?.removeAllActions()
            LineNode?.removeFromParentNode()
            LineNode = nil
        }
        if SystemNode != nil
        {
            SystemNode?.removeAllActions()
            SystemNode?.removeFromParentNode()
            SystemNode = nil
        }

        SystemNode = SCNNode()
        
        let EarthSphere = SCNSphere(radius: 10)
        EarthSphere.segmentCount = 100
        let SeaSphere = SCNSphere(radius: 10)
        SeaSphere.segmentCount = 100
        let LineSphere = SCNSphere(radius: 10.2)
        LineSphere.segmentCount = 100

        EarthNode = SCNNode(geometry: EarthSphere)
        EarthNode?.position = SCNVector3(0.0, 0.0, 0.0)
        #if true
        EarthNode?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "BaseWorldMap")
        #else
                EarthNode?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "EarthLand")
        #endif
        EarthNode?.geometry?.firstMaterial?.specular.contents = UIColor.clear
        
        SeaNode = SCNNode(geometry: SeaSphere)
        SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
        SeaNode?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "EarthSea")
        SeaNode?.geometry?.firstMaterial?.specular.contents = UIColor.white
        
        LineNode = SCNNode(geometry: LineSphere)
        LineNode?.position = SCNVector3(0.0, 0.0, 0.0)
        let GridLines = MakeGridLines(Width: 3600, Height: 1800, LineColor: UIColor.systemRed)
        LineNode?.geometry?.firstMaterial?.diffuse.contents = GridLines
        LineNode?.castsShadow = false
        
        let Declination = Sun.Declination(For: Date())
        SystemNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
        
        EarthView.prepare([EarthNode!, SeaNode!, LineNode!], completionHandler:
            {
             success in
                if success
                {
                    self.SystemNode?.addChildNode(self.EarthNode!)
                    //self.SystemNode?.addChildNode(self.SeaNode!)
                    self.SystemNode?.addChildNode(self.LineNode!)
                    self.EarthView.scene?.rootNode.addChildNode(self.SystemNode!)
                }
        }
            )

        let EarthRotate = SCNAction.rotateBy(x: 0.0, y: 360.0 * CGFloat.pi / 180.0, z: 0.0, duration: 30.0)
        let RotateForever = SCNAction.repeatForever(EarthRotate)
        EarthNode?.runAction(RotateForever)
        //SeaNode?.runAction(RotateForever)
        
        LineNode?.runAction(RotateForever)
    }
    
    var RotationAccumulator: CGFloat = 0.0
    
    var SystemNode: SCNNode? = nil
    var LineNode: SCNNode? = nil
    var EarthNode: SCNNode? = nil
    var SeaNode: SCNNode? = nil
    
    func MakeImageBase(Width: CGFloat, Height: CGFloat, FillColor: UIColor) -> UIImage
    {
        let ImageSize = CGSize(width: Width, height: Height)
        return UIGraphicsImageRenderer(size: ImageSize).image
            {
                RenderContext in
                FillColor.setFill()
                RenderContext.fill(CGRect(origin: .zero, size: ImageSize))
        }
    }
    
    func MakeGridLines(Width: CGFloat, Height: CGFloat, LineColor: UIColor) -> UIImage
    {
        let Base = MakeImageBase(Width: Width, Height: Height, FillColor: UIColor.clear)
        UIGraphicsBeginImageContext(Base.size)
        
        Base.draw(at: .zero)
        
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setLineWidth(5.0)
        ctx?.setStrokeColor(LineColor.withAlphaComponent(0.75).cgColor)
        
        for Longitude in Longitudes.allCases
        {
            let Y = Height * CGFloat(Longitude.rawValue)
            ctx?.move(to: CGPoint(x: 0, y: Y))
            ctx?.addLine(to: CGPoint(x: Width, y: Y))
            ctx?.strokePath()
        }
        
        for Latitude in Latitudes.allCases
        {
            let X = Width * CGFloat(Latitude.rawValue)
            ctx?.move(to: CGPoint(x: X, y: 0))
            ctx?.addLine(to: CGPoint(x: X, y: Height))
            

            ctx?.strokePath()
        }
        
        let Final = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Final!
    }

    @IBAction func HandleResetButtonPressed(_ sender: Any)
    {
    }
    
    @IBOutlet weak var EarthView: SCNView!
}

//Cancer & Capricorn: 23.43667 (per 90)
//Arctic & Antarctic: 66.56083 (per 90) = 73.9565% from equator, = 26.0435% from equator to pole, = 13.0218% of distance from remote pole

enum Longitudes: Double, CaseIterable
{
    case Equator = 0.5
    case ArcticCircle = 0.869782
    case AntarcticCircle = 0.130218
    case TropicOfCancer = 0.61718
    case TropicOfCapricorn = 0.38282
}

enum Latitudes: Double, CaseIterable
{
    case PrimeMeridian = 0.5
    case AntiPrimeMerician = 0.995
}

extension UIImage
    {
        /// Rotate the instance image to the number of passed radians.
        /// - Note: See [Rotating UIImage in Swift](https://stackoverflow.com/questions/27092354/rotating-uiimage-in-swift/47402811#47402811)
        /// - Parameter Radians: Number of radians to rotate the image to.
        func Rotate(Radians: CGFloat) -> UIImage
        {
            var NewSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: Radians)).size
            NewSize.width = floor(NewSize.width)
            NewSize.height = floor(NewSize.height)
            UIGraphicsBeginImageContextWithOptions(NewSize, false, self.scale)
            let Context = UIGraphicsGetCurrentContext()
            Context?.translateBy(x: NewSize.width / 2, y: NewSize.height / 2)
            Context?.rotate(by: Radians)
            self.draw(in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2,
                                 width: self.size.width, height: self.size.height))
            let Rotated = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return Rotated!
        }
}
