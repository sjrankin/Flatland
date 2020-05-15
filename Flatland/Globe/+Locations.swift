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
        let RadialOffset = IsCurrentLocation ? 0.25 : 0.1
        let (X, Y, Z) = ToECEF(Latitude, Longitude, Radius: Radius + RadialOffset)
        var ConeTop: CGFloat = 0.0
        var ConeBottom: CGFloat = 0.0
        if IsCurrentLocation
        {
            ConeTop = 0.0
            ConeBottom = 0.15
        }
        else
        {
            ConeTop = 0.15
            ConeBottom = 0.0
        }
        let Cone = SCNCone(topRadius: ConeTop, bottomRadius: ConeBottom, height: 0.3)
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
            CylinderNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)
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
    
    /// Plot a city on the 3D sphere.
    /// - Parameter Latitude: The latitude of the city.
    /// - Parameter Longitude: The longitude of the city.
    /// - Parameter ToSurface: The surface that defines the globe.
    /// - Parameter WithColor: The color of the city shape.
    /// - Parameter RelativeSize: The relative size of the city. Used to determine how large of a
    ///                           city shape to create.
    /// - Parameter RelativeHeight: The relative height of the city over the Earth.
    /// - Parameter LargestSize: The largest city size. This value is multiplied by `RelativeSize`
    ///                          which is assumed to be a normal value.
    /// - Parameter LongestStem: The length of the stem from the Earth to the floating city shape.
    ///                          This value is multiplied by `RelativeHeight` which is assumed to be
    ///                          a normal value.
    func PlotCity2(Latitude: Double, Longitude: Double, Radius: Double, ToSurface: SCNNode,
                   WithColor: UIColor = UIColor.red, RelativeSize: Double = 1.0,
                   RelativeHeight: Double = 1.0, LargestSize: Double = 1.0, LongestStem: Double = 1.0)
    {
        let RadialOffset = 0.1
        let (X, Y, Z) = ToECEF(Latitude, Longitude, Radius: Radius + RadialOffset)

        var CitySize: CGFloat = CGFloat(LargestSize * RelativeSize)
        if CitySize < 0.15
        {
            CitySize = 0.15
        }
        let Sphere = SCNSphere(radius: CitySize)
        let SphereNode = SCNNode(geometry: Sphere)
        SphereNode.geometry?.firstMaterial?.diffuse.contents = WithColor
        SphereNode.geometry?.firstMaterial?.specular.contents = UIColor.white
        
        var CylinderLength = CGFloat(LongestStem * RelativeHeight)
        if CylinderLength < 0.1
        {
            CylinderLength = 0.1
        }
        let Cylinder = SCNCylinder(radius: 0.04, height: CGFloat(LongestStem * RelativeHeight))
        let CylinderNode = SCNNode(geometry: Cylinder)
        CylinderNode.geometry?.firstMaterial?.diffuse.contents = UIColor.systemYellow
        CylinderNode.geometry?.firstMaterial?.specular.contents = UIColor.white
        CylinderNode.castsShadow = true
        CylinderNode.position = SCNVector3(0.0, 0.0, 0.0)
        SphereNode.position = SCNVector3(0.0, -(CylinderLength - CitySize), 0.0)
        
        let FinalNode = SCNNode()
        FinalNode.addChildNode(SphereNode)
        FinalNode.addChildNode(CylinderNode)
        
        FinalNode.position = SCNVector3(X, Y, Z)
        
        let YRotation = Latitude + 90.0
        let XRotation = Longitude + 180.0
        FinalNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)
        
        ToSurface.addChildNode(FinalNode)
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
        let (Max, Min) = Cities.GetPopulationsIn(CityList: TestCities, UseMetroPopulation: true)
        for City in TestCities
        {
            if City.IsUserCity
            {
                PlotArrow(Latitude: City.Latitude, Longitude: City.Longitude, Radius: 10.0, ToSurface: On,
                          IsCurrentLocation: false, WithColor: City.CityColor)
            }
            else
            {
                #if true
                var RelativeSize: Double = 1.0
                if City.Population == nil
                {
                    RelativeSize = Double(Min) / Double(Max)
                }
                else
                {
                    RelativeSize = Double(City.Population!) / Double(Max)
                }
                PlotCity2(Latitude: City.Latitude, Longitude: City.Longitude, Radius: 10.0,
                          ToSurface: On, WithColor: UIColor.yellow, RelativeSize: RelativeSize,
                          RelativeHeight: RelativeSize, LargestSize: 0.5, LongestStem: 2.0)
                #else
                let CityShape = SCNSphere(radius: CitySize)
                let CityNode = SCNNode(geometry: CityShape)
                CityNode.geometry?.firstMaterial?.diffuse.contents = City.CityColor
                CityNode.geometry?.firstMaterial?.emission.contents = UIImage(named: "CitySphereTexture")
                CityNode.castsShadow = true
                let (X, Y, Z) = ToECEF(City.Latitude, City.Longitude, Radius: Double(10 - (CitySize / 2)))
                CityNode.position = SCNVector3(X, Y, Z)
                On.addChildNode(CityNode)
                #endif
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
