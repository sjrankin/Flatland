//
//  +Locations.swift
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
    /// Add the home location to the globe.
    /// - Note: The home location has shifting colors and rotates to make it obviouse where it is.
    /// - Parameter Latitude: The latitude of the home location.
    /// - Parameter Longitude: The longitude of the home location.
    /// - Parameter ToSurface: The parent node.
    func AddLocation(Latitude: Double, Longitude: Double, ToSurface: SCNNode)
    {
        let (X, Y, Z) = ToECEF(Latitude, Longitude, Radius: 10)
        #if true
        let Home = SCNNode(geometry: SCNSphere(radius: 0.16))
        #else
        let Home = SCNNode(geometry: SCNBox(width: 5, height: 5, length: 5, chamferRadius: 0.5))
                Home.scale = SCNVector3(0.04, 0.04, 0.04)
        #endif
        Home.name = "HomeLocation"
        Home.geometry?.firstMaterial?.diffuse.contents = UIColor(hue: 0.0, saturation: 1.0, brightness: 0.5, alpha: 1.0)
        Home.geometry?.firstMaterial?.specular.contents = UIColor.white
        Home.castsShadow = true
        Home.position = SCNVector3(X, Y, Z)
        ToSurface.addChildNode(Home)
        let ChangeDuration: CGFloat = 3.0
        var HueValue = 0.0
        let ColorAction = SCNAction.customAction(duration: Double(ChangeDuration))
        {
            (Node, ElapsedTime) in
            HueValue = HueValue + 0.01
            if HueValue > 1.0
            {
                HueValue = 0.0
            }
            Node.geometry?.firstMaterial?.diffuse.contents = UIColor(hue: CGFloat(HueValue), saturation: 1.0, brightness: 1.0, alpha: 1.0)
            //Node.geometry?.firstMaterial?.emission.contents = UIColor(hue: CGFloat(HueValue), saturation: 1.0, brightness: 1.0, alpha: 1.0)
        }
        let ColorForever = SCNAction.repeatForever(ColorAction)
        Home.runAction(ColorForever)
        #if false
        let RotateValue = CGFloat.pi / 180.0 * 360.0
        let Rotator = SCNAction.rotateBy(x: RotateValue * 1.1,
                                         y: RotateValue * 0.9,
                                         z: RotateValue * 0.5,
                                         duration: Double(ChangeDuration * 3.7))
        let RotateForever = SCNAction.repeatForever(Rotator)
        Home.runAction(RotateForever)
        #endif
    }
    
    /// Draws a 3D "arrow" shape (a cone and a cylinder) pointing toward the center of the Earth.
    /// - Parameter Latitude: The latitude of the arrow.
    /// - Parameter Longitude: The longitude of the arrow.
    /// - Parameter Radius: The radius of the Earth. (The arrow is plotted above the radius by a
    ///                     constant to ensure the entire arrow is visible.)
    /// - Parameter ToSurface: The surface node where the arrow will be added.
    /// - Parameter IsCurrentLocation: Determines the shape and color of the arrow. If this value is
    ///                                `true`, a stem will be added to the arrow shape and the arrow
    ///                                head will be red with an animation transitioning to yellow and
    ///                                back. Otherwise, there will be no stem and the color is determined
    ///                                by the caller (see `WithColor').
    /// - Parameter WithColor: Ignored if `IsCurrentLocation` is true. Otherwise, this is the color of
    ///                        the arrow head shape.
    func PlotArrow(Latitude: Double, Longitude: Double, Radius: Double, ToSurface: SCNNode,
                   IsCurrentLocation: Bool = false, WithColor: UIColor = UIColor.red)
    {
        let (X, Y, Z) = ToECEF(Latitude, Longitude, Radius: Radius + 0.25)
        let Cone = SCNCone(topRadius: 0.0, bottomRadius: 0.15, height: 0.3)
        let ConeNode = SCNNode(geometry: Cone)
        ConeNode.geometry?.firstMaterial?.diffuse.contents = WithColor
        ConeNode.geometry?.firstMaterial?.specular.contents = UIColor.white
        if !IsCurrentLocation
        {
            ConeNode.geometry?.firstMaterial?.emission.contents = WithColor
        }
        ConeNode.castsShadow = true
        
        if IsCurrentLocation
        {
        let ChangeDuration: Double = 30.0
        var HueValue = 0.0
        var HueIncrement = 0.01
        let ColorAction = SCNAction.customAction(duration: ChangeDuration)
        {
            (Node, ElapsedTime) in
            HueValue = HueValue + HueIncrement
            if HueValue > Double(63.0 / 360.0)
            {
                HueIncrement = HueIncrement * -1.0
                HueValue = HueValue + HueIncrement
            }
            else
            {
                if HueValue < 0.0
                {
                    HueIncrement = HueIncrement * -1.0
                    HueValue = 0.0
                }
            }
            Node.geometry?.firstMaterial?.diffuse.contents = UIColor(hue: CGFloat(HueValue), saturation: 1.0, brightness: 1.0, alpha: 1.0)
        }
        let ColorForever = SCNAction.repeatForever(ColorAction)
        ConeNode.runAction(ColorForever)
        }
        
        let ArrowNode = SCNNode()
        ArrowNode.name = "ArrowNode"
        ArrowNode.addChildNode(ConeNode)
        
        if IsCurrentLocation
        {
        let Cylinder = SCNCylinder(radius: 0.04, height: 0.5)
        let CylinderNode = SCNNode(geometry: Cylinder)
        CylinderNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0)
        CylinderNode.geometry?.firstMaterial?.specular.contents = UIColor.white
        CylinderNode.castsShadow = true
        CylinderNode.position = SCNVector3(0.0, -0.3, 0.0)
                    ArrowNode.addChildNode(CylinderNode)
        }
            
        ArrowNode.position = SCNVector3(X, Y, Z)
        
        let YRotation = Latitude + 90.0
        let XRotation = Longitude + 180.0
        ArrowNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)

        ToSurface.addChildNode(ArrowNode)
    }
    
    /// Plot cities on the Earth.
    /// - Parameter On: The main sphere node upon which to plot cities.
    /// - Parameter WithRadius: The radius of there Earth sphere node.
    func PlotCities(On: SCNNode, WithRadius: CGFloat)
    {
        let CityList = Cities()
        var TestCities = CityList.TopNCities(N: 50, UseMetroPopulation: true)
 
        let UserLocations = Settings.GetLocations()
        for (_, Location, Name, Color) in UserLocations
        {
            let UserCity = City(Continent: "NoName", Country: "No Name", Name: Name, Population: nil, MetroPopulation: nil, Latitude: Location.Latitude, Longitude: Location.Longitude)
            UserCity.CityColor = Color
            UserCity.IsUserCity = true
            TestCities.append(UserCity)
        }
        
        if let LocalLongitude = Settings.GetLocalLongitude()
        {
            if let LocalLatitude = Settings.GetLocalLatitude()
            {
                PlotArrow(Latitude: LocalLatitude, Longitude: LocalLongitude, Radius: 10.0,
                          ToSurface: On, IsCurrentLocation: true)
            }
        }
        
        let CitySize: CGFloat = 0.15
        for City in TestCities
        {
            if City.IsUserCity
            {
                #if true
                PlotArrow(Latitude: City.Latitude, Longitude: City.Longitude, Radius: 10.0, ToSurface: On,
                          IsCurrentLocation: false, WithColor: City.CityColor)
                #else
                let CityShape = SCNCone(topRadius: 0.0, bottomRadius: CitySize, height: CitySize * 3.5)
                let CityNode = SCNNode(geometry: CityShape)
                CityNode.geometry?.firstMaterial?.diffuse.contents = City.CityColor
                CityNode.geometry?.firstMaterial?.emission.contents = City.CityColor
                CityNode.castsShadow = true
                let (X, Y, Z) = ToECEF(City.Latitude, City.Longitude, Radius: 10)//Double(10 - (CitySize / 2)))
                CityNode.position = SCNVector3(X, Y, Z)
                var NodeRotation = 0.0
                if City.Latitude >= 0
                {
                    NodeRotation = 90.0 - City.Latitude
                }
                else
                {
                    NodeRotation = -90 + City.Latitude
                }
                //print("Node rotation for \(City.Latitude)° is \(NodeRotation)")
                NodeRotation = NodeRotation.Radians
                CityNode.eulerAngles = SCNVector3(0.0, NodeRotation, 0.0)
                On.addChildNode(CityNode)
                #endif
            }
            else
            {
                let CityShape = SCNSphere(radius: CitySize)
                let CityNode = SCNNode(geometry: CityShape)
                CityNode.geometry?.firstMaterial?.diffuse.contents = City.CityColor
                CityNode.geometry?.firstMaterial?.emission.contents = UIImage(named: "CitySphereTexture")
                CityNode.castsShadow = true
                let (X, Y, Z) = ToECEF(City.Latitude, City.Longitude, Radius: Double(10 - (CitySize / 2)))
                CityNode.position = SCNVector3(X, Y, Z)
                On.addChildNode(CityNode)
            }
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
}
