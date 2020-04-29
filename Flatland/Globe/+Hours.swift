//
//  +Hours.swift
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
    /// Update the globe display with the specified hour types.
    /// - Parameter With: The hour type to display.
    func UpdateHourLabels(With: HourValueTypes)
    {
        switch With
        {
            case .None:
                if PreviousHourType == .None
                {
                    return
                }
                RemoveNodeFrom(Parent: SystemNode!, Named: "Hour Node")
                RemoveNodeFrom(Parent: self.scene!.rootNode, Named: "Hour Node")
            
            case .Solar:
                if PreviousHourType == .Solar
                {
                    return
                }
                RemoveNodeFrom(Parent: SystemNode!, Named: "Hour Node")
                RemoveNodeFrom(Parent: self.scene!.rootNode, Named: "Hour Node")
                HourNode = DrawHourLabels(Radius: 11.1)
                let Declination = Sun.Declination(For: Date())
                HourNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
                self.scene?.rootNode.addChildNode(HourNode!)
            
            case .RelativeToNoon:
                if PreviousHourType == .RelativeToNoon
                {
                    return
                }
                RemoveNodeFrom(Parent: SystemNode!, Named: "Hour Node")
                RemoveNodeFrom(Parent: self.scene!.rootNode, Named: "Hour Node")
                HourNode = DrawHourLabels(Radius: 11.1)
                let Declination = Sun.Declination(For: Date())
                HourNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
                self.scene?.rootNode.addChildNode(HourNode!)
            
            case .RelativeToLocation:
                if PreviousHourType == .RelativeToLocation
                {
                    return
                }
                RemoveNodeFrom(Parent: SystemNode!, Named: "Hour Node")
                RemoveNodeFrom(Parent: self.scene!.rootNode, Named: "Hour Node")
                HourNode = DrawHourLabels(Radius: 11.1)
                SystemNode?.addChildNode(HourNode!)
        }
        PreviousHourType = With
    }
    
    /// Create an hour node with labels.
    /// - Parameter Radius: Radial value for where to place hour labels.
    /// - Returns: The node with the hour labels. Nil if the user does not want to display hours.
    func DrawHourLabels(Radius: Double) -> SCNNode?
    {
        switch Settings.GetHourValueType()
        {
            case .None:
                return nil
            
            case .Solar:
                return MakeNoonHours(Radius: Radius)
            
            case .RelativeToNoon:
                return MakeNoonDeltaHours(Radius: Radius)
            
            case .RelativeToLocation:
                return MakeRelativeHours(Radius: Radius)
        }
    }
    
    /// Make the hour node such that `12` is always under the noon longitude and `0` under midnight.
    /// - Parameter Radius: The radius of the hour label.
    /// - Returns: Node with labels set up for noontime.
    func MakeNoonHours(Radius: Double) -> SCNNode
    {
        let NodeShape = SCNSphere(radius: CGFloat(Radius))
        let Node = SCNNode(geometry: NodeShape)
        Node.position = SCNVector3(0.0, 0.0, 0.0)
        Node.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        Node.geometry?.firstMaterial?.specular.contents = UIColor.clear
        Node.name = "Hour Node"
        
        for Hour in 0 ... 23
        {
            //Get the angle for the text. The +2.0 is because SCNText geometries start at the X position
            //and move to the right - to make the text line up closely (but not perfectly) with the noon
            //sun, adding a small amount adjusts the X position.
            let Angle = ((CGFloat(Hour) / 24.0) * 360.0) + 2.0
            let Radians = Angle.Radians
            //Calculate the display hour.
            let DisplayHour = 24 - (Hour + 5) % 24 - 1
            let HourText = SCNText(string: "\(DisplayHour)", extrusionDepth: 5.0)
            HourText.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.bold)
            HourText.firstMaterial?.diffuse.contents = UIColor.yellow
            HourText.firstMaterial?.specular.contents = UIColor.white
            HourText.flatness = 0.1
            let X = CGFloat(Radius) * cos(Radians)
            let Z = CGFloat(Radius) * sin(Radians)
            let HourTextNode = SCNNode(geometry: HourText)
            HourTextNode.scale = SCNVector3(0.07, 0.07, 0.07)
            HourTextNode.position = SCNVector3(X, -0.8, Z)
            let HourRotation = (90.0 - Angle).Radians
            HourTextNode.eulerAngles = SCNVector3(0.0, HourRotation, 0.0)
            Node.addChildNode(HourTextNode)
        }
        
        return Node
    }
    
    /// Make the hour node such that each label shows number of hours away from noon.
    /// - Parameter Radius: The radius of the hour label.
    /// - Returns: Node with labels set up for noon delta.
    func MakeNoonDeltaHours(Radius: Double) -> SCNNode
    {
        let NodeShape = SCNSphere(radius: CGFloat(Radius))
        let Node = SCNNode(geometry: NodeShape)
        Node.position = SCNVector3(0.0, 0.0, 0.0)
        Node.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        Node.geometry?.firstMaterial?.specular.contents = UIColor.clear
        Node.name = "Hour Node"
        
        for Hour in 0 ... 23
        {
            //Get the angle for the text. The +2.0 is because SCNText geometries start at the X position
            //and move to the right - to make the text line up closely (but not perfectly) with the noon
            //sun, adding a small amount adjusts the X position.
            let Angle = ((CGFloat(Hour) / 24.0) * 360.0) + 2.0
            let Radians = Angle.Radians
            //Calculate the display hour.
            var DisplayHour = 24 - (Hour + 5) % 24 - 1
            DisplayHour = DisplayHour - 12
            var Prefix = ""
            if DisplayHour > 0
            {
                Prefix = "+"
            }
            let HourText = SCNText(string: "\(Prefix)\(DisplayHour)", extrusionDepth: 5.0)
            HourText.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.bold)
            HourText.firstMaterial?.diffuse.contents = UIColor.systemYellow
            HourText.firstMaterial?.specular.contents = UIColor.white
            HourText.flatness = 0.1
            let X = CGFloat(Radius) * cos(Radians)
            let Z = CGFloat(Radius) * sin(Radians)
            let HourTextNode = SCNNode(geometry: HourText)
            HourTextNode.scale = SCNVector3(0.07, 0.07, 0.07)
            HourTextNode.position = SCNVector3(X, -0.8, Z)
            let HourRotation = (90.0 - Angle).Radians
            HourTextNode.eulerAngles = SCNVector3(0.0, HourRotation, 0.0)
            Node.addChildNode(HourTextNode)
        }
        
        return Node
    }
    
    /// Make the hour node such that `0` is always under the user's location (if set) with offsets
    /// for the other hour labels.
    /// - Parameter Radius: The radius of the hour label.
    /// - Returns: Node with labels set up for current location.
    func MakeRelativeHours(Radius: Double) -> SCNNode
    {
        let NodeShape = SCNSphere(radius: CGFloat(Radius))
        let Node = SCNNode(geometry: NodeShape)
        Node.position = SCNVector3(0.0, 0.0, 0.0)
        Node.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        Node.geometry?.firstMaterial?.specular.contents = UIColor.clear
        Node.name = "Hour Node"
        
        for Hour in 0 ... 23
        {
            //Get the angle for the text. The +2.0 is because SCNText geometries start at the X position
            //and move to the right - to make the text line up closely (but not perfectly) with the noon
            //sun, adding a small amount adjusts the X position.
            let Angle = ((CGFloat(Hour) / 24.0) * 360.0) + 2.0
            let Radians = Angle.Radians
            //Calculate the display hour.
            var Prefix = ""
            var DisplayHour = 24 - (Hour + 5) % 24 - 1
            if let LocalLongitude = Settings.GetLocalLongitude()
            {
                let Long = Int(LocalLongitude / 15.0)
                print("Hour longitude: \(Long), Local longitude: \(LocalLongitude)")
                DisplayHour = Hour - 12 - 1
                if DisplayHour < -12
                {
                    DisplayHour = 12 - (DisplayHour * -1) % 12
                }
                DisplayHour = DisplayHour * -1
                DisplayHour = DisplayHour - Long
                if DisplayHour >= 12
                {
                    DisplayHour = 12 - (DisplayHour % 12)
                    DisplayHour = DisplayHour * -1
                }
                if DisplayHour < -12
                {
                    DisplayHour = (12 + (DisplayHour % 12))
                }
                if DisplayHour > 0
                {
                    Prefix = "+"
                }
            }
            let HourText = SCNText(string: "\(Prefix)\(DisplayHour)", extrusionDepth: 5.0)
            HourText.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.bold)
            HourText.firstMaterial?.diffuse.contents = UIColor.orange
            HourText.firstMaterial?.specular.contents = UIColor.white
            HourText.flatness = 0.1
            let X = CGFloat(Radius) * cos(Radians)
            let Z = CGFloat(Radius) * sin(Radians)
            let HourTextNode = SCNNode(geometry: HourText)
            HourTextNode.scale = SCNVector3(0.07, 0.07, 0.07)
            HourTextNode.position = SCNVector3(X, -0.8, Z)
            let HourRotation = (90.0 - Angle).Radians
            HourTextNode.eulerAngles = SCNVector3(0.0, HourRotation, 0.0)
            Node.addChildNode(HourTextNode)
        }
        
        return Node
    }
}
