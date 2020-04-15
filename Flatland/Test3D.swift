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
        
        #if false
        let SpotLight = SCNLight()
        SpotLight.type = .spot
        SpotLight.intensity = 900
        SpotLight.castsShadow = true
        SpotLight.shadowColor = UIColor.black.withAlphaComponent(0.80)
        SpotLight.shadowMode = .forward
        SpotLight.shadowRadius = 10.0
        SpotLight.color = UIColor.yellow
        SpotLightNode = SCNNode()
        SpotLightNode.light = SpotLight
        SpotLightNode.position = SCNVector3(0.0, 0.0, 15.0)
        #endif
        
        EarthView.scene?.rootNode.addChildNode(CameraNode)
        EarthView.scene?.rootNode.addChildNode(LightNode)
        #if false
        EarthView.scene?.rootNode.addChildNode(SpotLightNode)
        #endif
        
        AddEarth()
    }
    
    var CameraNode = SCNNode()
    var LightNode = SCNNode()
    var SpotLightNode = SCNNode()
    
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
        EarthNode?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "LandMask2")
        EarthNode?.geometry?.firstMaterial?.specular.contents = UIColor.clear
        
        SeaNode = SCNNode(geometry: SeaSphere)
        SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
        SeaNode?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "SeaMask2")
        SeaNode?.geometry?.firstMaterial?.specular.contents = UIColor.white
        
        LineNode = SCNNode(geometry: LineSphere)
        LineNode?.position = SCNVector3(0.0, 0.0, 0.0)
        let GridLines = MakeGridLines(Width: 3600, Height: 1800, LineColor: UIColor.systemRed)
        LineNode?.geometry?.firstMaterial?.diffuse.contents = GridLines
        LineNode?.castsShadow = false
        
        let Declination = Sun.Declination(For: Date())
        SystemNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
        
        PlotCities(On: EarthNode!, WithRadius: 10)
        
        EarthView.prepare([EarthNode!, SeaNode!, LineNode!], completionHandler:
            {
                success in
                if success
                {
                    self.SystemNode?.addChildNode(self.EarthNode!)
                    self.SystemNode?.addChildNode(self.SeaNode!)
                    self.SystemNode?.addChildNode(self.LineNode!)
                    self.EarthView.scene?.rootNode.addChildNode(self.SystemNode!)
                }
        }
        )
        
        let EarthRotate = SCNAction.rotateBy(x: 0.0, y: 360.0 * CGFloat.pi / 180.0, z: 0.0, duration: 30.0)
        let RotateForever = SCNAction.repeatForever(EarthRotate)
        EarthNode?.runAction(RotateForever)
        SeaNode?.runAction(RotateForever)
        LineNode?.runAction(RotateForever)
    }
    
    /// Plot cities on the Earth.
    /// - Parameter On: The main sphere node upon which to plot cities.
    /// - Parameter WithRadius: The radius of there Earth sphere node.
    func PlotCities(On: SCNNode, WithRadius: CGFloat)
    {
        let CityList = Cities()
        let TestCities = CityList.TopNCities(N: 50, UseMetroPopulation: true)
        let CitySize: CGFloat = 0.15
        for City in TestCities
        {
            let CityShape = SCNSphere(radius: CitySize)
            let CityNode = SCNNode(geometry: CityShape)
            CityNode.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
            CityNode.geometry?.firstMaterial?.emission.contents = UIImage(named: "CitySphereTexture")
            CityNode.castsShadow = true
            let (X, Y, Z) = ToECEF(City.Latitude, City.Longitude, Radius: Double(10 - (CitySize / 2)))
            CityNode.position = SCNVector3(X, Y, Z)
            On.addChildNode(CityNode)
        }
    }
    
    /// Convert the passed latitude and longitude values into a 3D coordinate that can be plotted
    /// on a sphere.
    /// - Note: See [How to map latitude and logitude to a 3D sphere](https://stackoverflow.com/questions/36369734/how-to-map-latitude-and-longitude-to-a-3d-sphere)
    /// - Parameter Latitude: The latitude portion of the 2D coordinate.
    /// - Parameter Longitude: The longitude portion of the 2D coordinate.
    /// - Parameter Radius: The radius of the sphere.
    /// - Returns: Tuple with the X, Y, and Z coordinates for the location on the sphere.
    func ToECEF(_ Latitude: Double, _ Longitude: Double, Radius: Double) -> (Double, Double, Double)
    {
        let Lat = (90 - Latitude).Radians
        let Lon = (90 + Longitude).Radians
        let X = -(Radius * sin(Lat) * cos(Lon))
        let Z = (Radius * sin(Lat) * sin(Lon))
        let Y = (Radius * cos(Lat))
        return (X, Y, Z)
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
    case OtherPrimeMeridian = 0.995
    case AntiPrimeMeridian = 0.25
    case OtherAntiPrimeMeridian = 0.75
}


