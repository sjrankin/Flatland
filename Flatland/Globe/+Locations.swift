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
        
        HomeNode = SCNNode()
        HomeNode?.name = "HomeNode"
        HomeNode?.addChildNode(ConeNode)
        
        if IsCurrentLocation
        {
            let Cylinder = SCNCylinder(radius: 0.04, height: 0.5)
            let CylinderNode = SCNNode(geometry: Cylinder)
            CylinderNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)
            CylinderNode.geometry?.firstMaterial?.specular.contents = UIColor.white
            CylinderNode.castsShadow = true
            CylinderNode.position = SCNVector3(0.0, -0.3, 0.0)
            HomeNode?.addChildNode(CylinderNode)
        }
        
        HomeNode?.position = SCNVector3(X, Y, Z)
        
        let YRotation = Latitude + 90.0
        let XRotation = Longitude + 180.0
        HomeNode?.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)
        
        ToSurface.addChildNode(HomeNode!)
    }
    
    /// Plot the home location as a pulsating sphere.
    /// - Parameter Latitude: The latitude of the arrow.
    /// - Parameter Longitude: The longitude of the arrow.
    /// - Parameter Radius: The radius of the Earth. (The arrow is plotted above the radius by a
    ///                     constant to ensure the entire arrow is visible.)
    /// - Parameter ToSurface: The surface node where the arrow will be added.
    /// - Parameter WithColor: The color of the sphere.
    func PlotPulsatingHome(Latitude: Double, Longitude: Double, Radius: Double, ToSurface: SCNNode,
                           WithColor: UIColor = UIColor.magenta)
    {
        let (X, Y, Z) = ToECEF(Latitude, Longitude, Radius: Radius + 0.1)
        
        let Sphere = SCNSphere(radius: 0.4)
        
        HomeNode = SCNNode(geometry: Sphere)
        HomeNode?.geometry?.firstMaterial?.diffuse.contents = WithColor
        HomeNode?.geometry?.firstMaterial?.specular.contents = UIColor.white
        HomeNode?.castsShadow = true
        HomeNode?.position = SCNVector3(X, Y, Z)
        
        let PulseOut = SCNAction.scale(to: 0.75, duration: 1.0)
        let PulseIn = SCNAction.scale(to: 0.4, duration: 1.0)
        let PulseSequence = SCNAction.sequence([PulseOut, PulseIn])
        let Forever = SCNAction.repeatForever(PulseSequence)
        HomeNode?.runAction(Forever)
        
        ToSurface.addChildNode(HomeNode!)
        
        let SphereHalo = SCNSphere(radius: 0.40)
        HomeNodeHalo = SCNNode(geometry: SphereHalo)
        HomeNodeHalo?.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.2)
        HomeNodeHalo?.geometry?.firstMaterial?.emission.contents = UIColor.yellow.withAlphaComponent(0.2)
        HomeNodeHalo?.position = SCNVector3(X, Y, Z)
        HomeNodeHalo?.castsShadow = false
        
        ToSurface.addChildNode(HomeNodeHalo!)
    }
    
    /// Plot user locations as inverted cones.
    /// - Parameter Latitude: The latitude of the arrow.
    /// - Parameter Longitude: The longitude of the arrow.
    /// - Parameter Radius: The radius of the Earth. (The arrow is plotted above the radius by a
    ///                     constant to ensure the entire arrow is visible.)
    /// - Parameter ToSurface: The surface node where the arrow will be added.
    /// - Parameter WithColor: Ignored if `IsCurrentLocation` is true. Otherwise, this is the color of
    ///                        the arrow head shape.
    func PlotUserLocation1(Latitude: Double, Longitude: Double, Radius: Double, ToSurface: SCNNode,
                           WithColor: UIColor = UIColor.magenta)
    {
        let (X, Y, Z) = ToECEF(Latitude, Longitude, Radius: Radius + 0.1)
        let Cone = SCNCone(topRadius: 0.15, bottomRadius: 0.0, height: 0.45)
        let ConeNode = SCNNode(geometry: Cone)
        ConeNode.geometry?.firstMaterial?.diffuse.contents = WithColor
        ConeNode.geometry?.firstMaterial?.specular.contents = UIColor.white
        ConeNode.geometry?.firstMaterial?.emission.contents = WithColor
        ConeNode.castsShadow = true
        ConeNode.position = SCNVector3(X, Y, Z)
        let YRotation = Latitude + 90.0
        let XRotation = Longitude + 180.0
        ConeNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)
        ToSurface.addChildNode(ConeNode)
        PlottedCities.append(ConeNode)
    }
    
    func PlotUserLocation2(Latitude: Double, Longitude: Double, Radius: Double, ToSurface: SCNNode,
                           WithColor: UIColor = UIColor.magenta)
    {
        let (X, Y, Z) = ToECEF(Latitude, Longitude, Radius: Radius + 0.1)
        
        let Sphere = SCNSphere(radius: 0.2)
        let SphereNode = SCNNode(geometry: Sphere)
        SphereNode.geometry?.firstMaterial?.diffuse.contents = WithColor
        SphereNode.geometry?.firstMaterial?.specular.contents = UIColor.white
        
        let Cone = SCNCone(topRadius: 0.0, bottomRadius: 0.2, height: 0.5)
        let ConeNode = SCNNode(geometry: Cone)
        ConeNode.geometry?.firstMaterial?.diffuse.contents = WithColor
        ConeNode.geometry?.firstMaterial?.specular.contents = UIColor.white
        
        let UserNode = SCNNode()
        UserNode.castsShadow = true
        UserNode.position = SCNVector3(X, Y, Z)
        UserNode.addChildNode(SphereNode)
        UserNode.addChildNode(ConeNode)
        let YRotation = Latitude + 90.0
        let XRotation = Longitude + 180.0
        UserNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)
        ToSurface.addChildNode(UserNode)
        PlottedCities.append(UserNode)
    }
    
    /// Plot a location using a home flag.
    /// - Note: The "background" to the home icon has an emissive color so it will glow even
    ///         at night time to show the location.
    /// - Parameter Latitude: The latitude of the arrow.
    /// - Parameter Longitude: The longitude of the arrow.
    /// - Parameter Radius: The radius of the Earth. (The arrow is plotted above the radius by a
    ///                     constant to ensure the entire arrow is visible.)
    /// - Parameter ToSurface: The surface node where the arrow will be added.
    /// - Parameter EmissiveColor: The color the home icon will glow.
    func PlotHomeFlag(Latitude: Double, Longitude: Double, Radius: Double, ToSurface: SCNNode,
                      EmissiveColor: UIColor = UIColor.white)
    {
        let Pole = SCNCylinder(radius: 0.04, height: 4.5)
        let PoleNode = SCNNode(geometry: Pole)
        PoleNode.geometry?.firstMaterial?.diffuse.contents = UIColor.brown
        
        let FlagX = 0.6
        let FlagY = -2.0
        
        let FlagInterior = SCNBox(width: 0.038, height: 0.58, length: 1.18, chamferRadius: 0.0)
        let FlagInteriorNode = SCNNode(geometry: FlagInterior)
        FlagInteriorNode.geometry?.firstMaterial?.diffuse.contents = EmissiveColor
        FlagInteriorNode.geometry?.firstMaterial?.specular.contents = UIColor.white
        FlagInteriorNode.geometry?.firstMaterial?.emission.contents = EmissiveColor
        FlagInteriorNode.position = SCNVector3(FlagX, FlagY, 0.0)
        FlagInteriorNode.eulerAngles = SCNVector3(0.0, 90.0.Radians, 0.0)
        
        let FlagFace = SCNBox(width: 0.04, height: 0.6, length: 1.2, chamferRadius: 0.0)
        let FlagFaceNode = SCNNode(geometry: FlagFace)
        FlagFaceNode.position = SCNVector3(FlagX, FlagY, 0.0)
        let FlagName = "GreenHomeFlag"
        let FlagImage = UIImage(named: FlagName)
        FlagFaceNode.geometry?.firstMaterial?.diffuse.contents = FlagImage
        FlagFaceNode.geometry?.firstMaterial?.specular.contents = UIColor.white
        FlagFaceNode.geometry?.firstMaterial?.lightingModel = .lambert
        FlagFaceNode.eulerAngles = SCNVector3(180.0.Radians, 90.0.Radians, 0.0)
        
        HomeNode = SCNNode()
        HomeNode?.castsShadow = true
        HomeNode?.addChildNode(PoleNode)
        HomeNode?.addChildNode(FlagFaceNode)
        HomeNode?.addChildNode(FlagInteriorNode)
        
        let (X, Y, Z) = ToECEF(Latitude, Longitude, Radius: Radius)
        HomeNode?.position = SCNVector3(X, Y, Z)
        
        let YRotation = Latitude + 90.0
        let XRotation = Longitude + 180.0
        HomeNode?.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)
        HomeNode?.name = "HomeNode"
        ToSurface.addChildNode(HomeNode!)
    }
    
    /// Plot a city on the 3D sphere. A sphere is set on the surface of the Earth.
    /// - Parameter Latitude: The latitude of the city.
    /// - Parameter Longitude: The longitude of the city.
    /// - Parameter ToSurface: The surface that defines the globe.
    /// - Parameter WithColor: The color of the city shape.
    /// - Parameter RelativeSize: The relative size of the city.
    /// - Parameter LargestSize: The largest permitted.
    func PlotCity1(Latitude: Double, Longitude: Double, Radius: Double, ToSurface: SCNNode,
                   WithColor: UIColor = UIColor.red, RelativeSize: Double = 1.0, LargestSize: Double = 1.0)
    {
        var CitySize = CGFloat(RelativeSize * LargestSize)
        if CitySize < 0.15
        {
            CitySize = 0.15
        }
        let CityShape = SCNSphere(radius: CitySize)
        let CityNode = SCNNode(geometry: CityShape)
        CityNode.geometry?.firstMaterial?.diffuse.contents = WithColor
        //        CityNode.geometry?.firstMaterial?.emission.contents = UIImage(named: "CitySphereTexture")
        CityNode.castsShadow = true
        SunLight.intensity = 800
        let (X, Y, Z) = ToECEF(Latitude, Longitude, Radius: Double(10 - (CitySize / 2)))
        CityNode.position = SCNVector3(X, Y, Z)
        CityNode.name = "CityNode"
        ToSurface.addChildNode(CityNode)
        PlottedCities.append(CityNode)
    }
    
    /// Plot a city on the 3D sphere. The city display is a float ball whose radius is relative to
    /// the overall size of selected cities and altitude over the Earth is also relative to the population.
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
        CylinderNode.geometry?.firstMaterial?.diffuse.contents = UIColor.magenta
        CylinderNode.geometry?.firstMaterial?.specular.contents = UIColor.white
        CylinderNode.castsShadow = true
        SunLight.intensity = 800
        CylinderNode.position = SCNVector3(0.0, 0.0, 0.0)
        SphereNode.position = SCNVector3(0.0, -(CylinderLength - CitySize), 0.0)
        
        let FinalNode = SCNNode()
        FinalNode.addChildNode(SphereNode)
        FinalNode.addChildNode(CylinderNode)
        
        FinalNode.position = SCNVector3(X, Y, Z)
        
        let YRotation = Latitude + 90.0
        let XRotation = Longitude + 180.0
        FinalNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)
        FinalNode.name = "CityNode"
        
        ToSurface.addChildNode(FinalNode)
        PlottedCities.append(FinalNode)
    }
    
    /// Plot a city on the 3D sphere. A box is placed on the surface of the Earth.
    /// - Parameter Latitude: The latitude of the city.
    /// - Parameter Longitude: The longitude of the city.
    /// - Parameter ToSurface: The surface that defines the globe.
    /// - Parameter WithColor: The color of the city shape.
    /// - Parameter RelativeSize: The relative size of the city.
    /// - Parameter LargestSize: The largest permitted.
    /// - Parameter IsBox: If true, the shape of the city is based on `SCNBox`. If false, the shape
    ///                    is based on `SCNCylinder`.
    func PlotCity3(Latitude: Double, Longitude: Double, Radius: Double, ToSurface: SCNNode,
                   WithColor: UIColor = UIColor.red, RelativeSize: Double = 1.0,
                   LargestSize: Double = 1.0, IsBox: Bool = true)
    {
        var CitySize = CGFloat(RelativeSize * LargestSize)
        if CitySize < 0.33
        {
            CitySize = 0.33
        }
        var HDim = CitySize * 0.1
        if HDim < 0.25
        {
            HDim = 0.25
        }
        var CityNode = SCNNode()
        if IsBox
        {
        let CityShape = SCNBox(width: HDim, height: CitySize, length: HDim, chamferRadius: 0.02)
         CityNode = SCNNode(geometry: CityShape)
        }
        else
        {
            let CityShape = SCNCylinder(radius: HDim / 2.0, height: CitySize)
            CityNode = SCNNode(geometry: CityShape)
        }
        CityNode.geometry?.firstMaterial?.diffuse.contents = WithColor
        CityNode.geometry?.firstMaterial?.specular.contents = UIColor.white
        CityNode.geometry?.firstMaterial?.lightingModel = .physicallyBased
        CityNode.castsShadow = true
        CityNode.geometry?.firstMaterial?.roughness.contents = NSNumber(value: 0.7)
        CityNode.geometry?.firstMaterial?.metalness.contents = NSNumber(value: 1.0)
        SunLight.intensity = 1200
        let (X, Y, Z) = ToECEF(Latitude, Longitude, Radius: Radius + Double(CitySize / 2.0))
        CityNode.position = SCNVector3(X, Y, Z)
        CityNode.name = "CityNode"
        let YRotation = Latitude + 90.0
        let XRotation = Longitude + 180.0
        CityNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)
        ToSurface.addChildNode(CityNode)
        PlottedCities.append(CityNode)
    }
    
    /// Plot cities and locations on the Earth.
    /// - Parameter On: The main sphere node upon which to plot cities.
    /// - Parameter WithRadius: The radius of there Earth sphere node.
    func PlotLocations(On: SCNNode, WithRadius: CGFloat)
    {
        PlotPolarShape()
        PlotHomeLocation()
        PlotCities()
        PlotWorldHeritageSites()
    }
    
    /// Plot cities on the globe.
    func PlotCities()
    {
        PlotCities(On: EarthNode!, Radius: 10.0)
    }
    
    /// Plot cities on the globe. User locations are also plotted here.
    /// - Parameter On: The node on which to plot cities.
    /// - Parameter Radius: The radius of the node on which to plot cities.
    func PlotCities(On Surface: SCNNode, Radius: Double)
    {
        for AlreadyPlotted in PlottedCities
        {
            AlreadyPlotted!.removeFromParentNode()
        }
        PlottedCities.removeAll()
        
        let CityList = Cities()
        var CitiesToPlot = CityList.TopNCities(N: 50, UseMetroPopulation: true)
        
        if Settings.ShowUserLocations()
        {
            let UserLocations = Settings.GetLocations()
            for (_, Location, Name, Color) in UserLocations
            {
                let UserCity = City(Continent: "NoName", Country: "No Name", Name: Name, Population: nil,
                                    MetroPopulation: nil, Latitude: Location.Latitude, Longitude: Location.Longitude)
                UserCity.CityColor = Color
                UserCity.IsUserCity = true
                CitiesToPlot.append(UserCity)
            }
        }
        
        let (Max, Min) = Cities.GetPopulationsIn(CityList: CitiesToPlot,
                                                 UseMetroPopulation: Settings.UseMetropolitanPopulation())
        for City in CitiesToPlot
        {
            if City.IsUserCity
            {
                PlotUserLocation1(Latitude: City.Latitude, Longitude: City.Longitude, Radius: Radius, ToSurface: Surface,
                                  WithColor: City.CityColor)
            }
            else
            {
                var RelativeSize: Double = 1.0
                if let ThePopulation = GetCityPopulation2(From: City)
                {
                    RelativeSize = Double(ThePopulation) / Double(Max)
                }
                else
                {
                    RelativeSize = Double(Min) / Double(Max)
                }
                let CityColor = Cities.ColorForCity(City)
                switch Settings.CityDisplayType()
                {
                    case .UniformEmbedded:
                        PlotCity1(Latitude: City.Latitude, Longitude: City.Longitude, Radius: Radius,
                                  ToSurface: Surface, WithColor: CityColor, RelativeSize: 1.0,
                                  LargestSize: 0.15)
                    
                    case .RelativeEmbedded:
                        PlotCity1(Latitude: City.Latitude, Longitude: City.Longitude, Radius: Radius,
                                  ToSurface: Surface, WithColor: CityColor, RelativeSize: RelativeSize,
                                  LargestSize: 0.35)
                    
                    case .RelativeFloating:
                        PlotCity2(Latitude: City.Latitude, Longitude: City.Longitude, Radius: Radius,
                                  ToSurface: Surface, WithColor: CityColor, RelativeSize: RelativeSize,
                                  RelativeHeight: RelativeSize, LargestSize: 0.5, LongestStem: 2.0)
                    
                    case .RelativeHeight:
                        PlotCity3(Latitude: City.Latitude, Longitude: City.Longitude, Radius: Radius,
                                  ToSurface: Surface, WithColor: CityColor, RelativeSize: RelativeSize,
                                  LargestSize: 2.0, IsBox: true)
                }
            }
        }
    }
    
    /// Plot the home location. Intended for use by external callers.
    func PlotHomeLocation()
    {
        PlotHomeLocation(On: EarthNode!, Radius: 10.0)
    }
    
    /// Plot the home location. In order for a location to be plotted, it must be defined and the
    /// style setting needs to be set to non-`.Hide`.
    /// - Parameter On: The node to which the home location will be attached.
    /// - Parameter Radius: The radius of the attachment node.
    func PlotHomeLocation(On Surface: SCNNode, Radius: Double)
    {
        HomeNode?.removeFromParentNode()
        HomeNode = nil
        HomeNodeHalo?.removeFromParentNode()
        HomeNodeHalo = nil
        
        if let LocalLongitude = Settings.GetLocalLongitude()
        {
            if let LocalLatitude = Settings.GetLocalLatitude()
            {
                switch Settings.ShowHomeLocation()
                {
                    case .Hide:
                        break
                    
                    case .ShowAsArrow:
                        PlotArrow(Latitude: LocalLatitude, Longitude: LocalLongitude, Radius: Radius,
                                  ToSurface: Surface, IsCurrentLocation: true)
                    
                    case .ShowAsFlag:
                        PlotHomeFlag(Latitude: LocalLatitude, Longitude: LocalLongitude, Radius: Radius,
                                     ToSurface: Surface, EmissiveColor: UIColor.orange)
                    
                    case .Pulsate:
                        PlotPulsatingHome(Latitude: LocalLatitude, Longitude: LocalLongitude, Radius: Radius,
                                          ToSurface: Surface, WithColor: UIColor.systemBlue)
                }
            }
        }
    }
    
    /// Plot polar flags. Intended to be used by callers outside of `GlobeView`.
    func PlotPolarShape()
    {
        NorthPoleFlag?.removeFromParentNode()
        NorthPoleFlag = nil
        SouthPoleFlag?.removeFromParentNode()
        SouthPoleFlag = nil
        NorthPolePole?.removeFromParentNode()
        NorthPolePole = nil
        SouthPolePole?.removeFromParentNode()
        SouthPolePole = nil
        switch Settings.GetPolarShape()
        {
            case .Pole:
                PlotPolarPoles(On: EarthNode!, With: 10.0)
            
            case .Flag:
                PlotPolarFlags(On: EarthNode!, With: 10.0)
            
            case .None:
                return
        }
    }
    
    /// Plot flags on the north and south poles.
    /// - Parameter On: The parent surface where the flags will be plotted.
    /// - Parameter With: The radius of the surface.
    func PlotPolarFlags(On Surface: SCNNode, With Radius: CGFloat)
    {
        let (NorthX, NorthY, NorthZ) = ToECEF(90.0, 0.0, Radius: Double(Radius))
        let (SouthX, SouthY, SouthZ) = ToECEF(-90.0, 0.0, Radius: Double(Radius))
        NorthPoleFlag = MakeFlag(NorthPole: true)
        SouthPoleFlag = MakeFlag(NorthPole: false)
        NorthPoleFlag?.position = SCNVector3(NorthX, NorthY, NorthZ)
        SouthPoleFlag?.position = SCNVector3(SouthX, SouthY, SouthZ)
        Surface.addChildNode(NorthPoleFlag!)
        Surface.addChildNode(SouthPoleFlag!)
    }
    
    /// Plot festive poles on the north and south poles.
    /// - Parameter On: The parent surface where the flags will be plotted.
    /// - Parameter With: The radius of the surface.
    func PlotPolarPoles(On Surface: SCNNode, With Radius: CGFloat)
    {
        let (NorthX, NorthY, NorthZ) = ToECEF(90.0, 0.0, Radius: Double(Radius))
        let (SouthX, SouthY, SouthZ) = ToECEF(-90.0, 0.0, Radius: Double(Radius))
        NorthPolePole = MakePole(NorthPole: true)
        SouthPolePole = MakePole(NorthPole: false)
        NorthPolePole?.position = SCNVector3(NorthX, NorthY, NorthZ)
        SouthPolePole?.position = SCNVector3(SouthX, SouthY, SouthZ)
        Surface.addChildNode(NorthPolePole!)
        Surface.addChildNode(SouthPolePole!)
    }
    
    /// Create a pole shape for the north or south pole.
    /// - Parameter NorthPole: Determines if the pole is for the North or South Pole.
    /// - Returns: Node with the pole shape.
    func MakePole(NorthPole: Bool) -> SCNNode
    {
        let Pole = SCNCylinder(radius: 0.25, height: 2.5)
        let PoleNode = SCNNode(geometry: Pole)
        PoleNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "PolarTexture")
        let PoleYOffset = NorthPole ? 0.5 : -0.5
        PoleNode.position = SCNVector3(0.0, PoleYOffset, 0.0)
        
        let Sphere = SCNSphere(radius: 0.5)
        let SphereNode = SCNNode(geometry: Sphere)
        let YOffset = NorthPole ? 2.1 : -2.1
        SphereNode.position = SCNVector3(0.0, YOffset, 0.0)
        SphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor(HexString: "#ffd700")
        SphereNode.geometry?.firstMaterial?.lightingModel = .physicallyBased
        SphereNode.geometry?.firstMaterial?.metalness.contents = 1.0
        SphereNode.geometry?.firstMaterial?.roughness.contents = 0.6
        
        let FinalNode = SCNNode()
        FinalNode.addChildNode(SphereNode)
        FinalNode.addChildNode(PoleNode)
        FinalNode.castsShadow = true
        return FinalNode
    }
    
    /// Create a flag shape for either the north or south pole.
    /// - Parameter NorthPole: If true, the North Pole flag is created. If false, the South Pole
    ///                        flat is created.
    /// - Returns: `SCNNode` with the proper shapes and textures and oriented correctly for the globe.
    func MakeFlag(NorthPole: Bool) -> SCNNode
    {
        let Pole = SCNCylinder(radius: 0.04, height: 2.5)
        let PoleNode = SCNNode(geometry: Pole)
        PoleNode.geometry?.firstMaterial?.diffuse.contents = UIColor.brown
        
        let FlagFace = SCNBox(width: 0.04, height: 0.6, length: 1.2, chamferRadius: 0.0)
        let FlagFaceNode = SCNNode(geometry: FlagFace)
        let XOffset = NorthPole ? 0.6 : -0.6
        let YOffset = NorthPole ? 1.0 : -1.0
        FlagFaceNode.position = SCNVector3(XOffset, YOffset, 0.0)
        var FlagName = ""
        if Settings.GetDisplayLanguage() == .English
        {
            FlagName = NorthPole ? "NorthPoleFlag" : "SouthPoleFlag"
        }
        else
        {
            FlagName = NorthPole ? "NorthPoleFlagJP" : "SouthPoleFlagJP"
        }
        let FlagImage = UIImage(named: FlagName)
        FlagFaceNode.geometry?.firstMaterial?.diffuse.contents = FlagImage
        FlagFaceNode.geometry?.firstMaterial?.specular.contents = UIColor.white
        FlagFaceNode.geometry?.firstMaterial?.lightingModel = .lambert
        FlagFaceNode.eulerAngles = SCNVector3(0.0, 90.0.Radians, 0.0)
        
        let FlagNode = SCNNode()
        FlagNode.castsShadow = true
        FlagNode.addChildNode(PoleNode)
        FlagNode.addChildNode(FlagFaceNode)
        return FlagNode
    }
    
    /// Plot World Heritage Sites. Which sites (and whether they are plotted or not) are determined
    /// by user settings.
    /// - Note: There are a lot of World Heritage Sites so plotting all of them can adversely affect
    ///         performance.
    func PlotWorldHeritageSites()
    {
        for Node in WHSNodeList
        {
            Node?.removeFromParentNode()
        }
        WHSNodeList.removeAll()
        if Settings.ShowWorldHeritageSites()
        {
            let TypeFilter = Settings.GetWorldHeritageSiteTypeFilter()
            MainView.InitializeWorldHeritageSites()
            let Sites = MainView.GetAllSites()
            var FinalList = [WorldHeritageSite]()
            for Site in Sites
            {
                switch TypeFilter
                {
                    case .Either:
                        FinalList.append(Site)
                    
                    case .Both:
                        if Site.Category == "Mixed"
                        {
                            FinalList.append(Site)
                        }
                    
                    case .Natural:
                        if Site.Category == "Natural"
                        {
                            FinalList.append(Site)
                    }
                    
                    case .Cultural:
                        if Site.Category == "Cultural"
                        {
                            FinalList.append(Site)
                    }
                }
            }
            for Site in FinalList
            {
                let (X, Y, Z) = ToECEF(Site.Latitude, Site.Longitude, Radius: 10.0)
                let StarShape = SCNStar.Geometry(VertexCount: 7, Height: 0.2, Base: 0.1, ZHeight: 0.1)
                let StarNode = SCNNode(geometry: StarShape)
                StarNode.scale = SCNVector3(0.55, 0.55, 0.55)
                WHSNodeList.append(StarNode)
                var NodeColor = UIColor.black
                switch Site.Category
                {
                    case "Mixed":
                        NodeColor = UIColor.magenta
                    
                    case "Natural":
                        NodeColor = UIColor.green
                    
                    case "Cultural":
                        NodeColor = UIColor.red
                    
                    default:
                        NodeColor = UIColor.white
                }
                StarNode.geometry?.firstMaterial?.diffuse.contents = NodeColor
                StarNode.geometry?.firstMaterial?.specular.contents = UIColor.white
                StarNode.castsShadow = true
                StarNode.position = SCNVector3(X, Y, Z)
                let YRotation = Site.Latitude
                let XRotation = Site.Longitude + 180.0
                StarNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)
                EarthNode!.addChildNode(StarNode)
            }
        }
    }
    
    /// Returns the largest of the city population or the metropolitan population from the passed city.
    /// - Parameter City: The city whose population is returned.
    /// - Returns: The largest of the city or the metropolitan populations. Nil if no populations
    ///            are available.
    func GetCityPopulation(From: City) -> Int?
    {
        if let Metro = From.MetropolitanPopulation
        {
            return Metro
        }
        if let Local = From.Population
        {
            return Local
        }
        return nil
    }
    
    func GetCityPopulation2(From: City) -> Int?
    {
        if Settings.UseMetropolitanPopulation()
        {
            if let Metro = From.MetropolitanPopulation
            {
                return Metro
            }
            if let CityPop = From.Population
            {
                return CityPop
            }
            return nil
        }
        if let CityPop = From.Population
        {
            return CityPop
        }
        if let Metro = From.MetropolitanPopulation
        {
            return Metro
        }
        return nil
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

/// Ways to display cities.
enum CityDisplayTypes: String, CaseIterable
{
    /// Each city is a uniform size and embedded in the parent surface.
    case UniformEmbedded = "Flush spheres, uniform size"
    /// Each city is sized relative to its population and is embedded in the parent surface.
    case RelativeEmbedded = "Flush spheres, relative size"
    /// Each city floats above the parent surface and is sized relative to its population.
    case RelativeFloating = "Floating spheres, relative size"
    /// Each city is a box with height determined by relative population.
    case RelativeHeight = "Box, relative height"
}
