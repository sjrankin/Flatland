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
                RemoveNodeFrom(Parent: SystemNode!, Named: "Hour Node")
                RemoveNodeFrom(Parent: self.scene!.rootNode, Named: "Hour Node")
            
            case .Solar:
                RemoveNodeFrom(Parent: SystemNode!, Named: "Hour Node")
                RemoveNodeFrom(Parent: self.scene!.rootNode, Named: "Hour Node")
                HourNode = DrawHourLabels(Radius: 11.1)
                let Declination = Sun.Declination(For: Date())
                HourNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
                self.scene?.rootNode.addChildNode(HourNode!)
            
            case .RelativeToNoon:
                RemoveNodeFrom(Parent: SystemNode!, Named: "Hour Node")
                RemoveNodeFrom(Parent: self.scene!.rootNode, Named: "Hour Node")
                HourNode = DrawHourLabels(Radius: 11.1)
                let Declination = Sun.Declination(For: Date())
                HourNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
                self.scene?.rootNode.addChildNode(HourNode!)
            
            case .RelativeToLocation:
                RemoveNodeFrom(Parent: SystemNode!, Named: "Hour Node")
                RemoveNodeFrom(Parent: self.scene!.rootNode, Named: "Hour Node")
                HourNode = DrawHourLabels(Radius: 11.1)
                SystemNode?.addChildNode(HourNode!)
        }
        PreviousHourType = With
    }
    
    /// Create an hour node with labels.
    /// - Note: `.RelativeToLocation` is not available if the user has not entered his location.
    ///         If no local information is available, nil is returned.
    /// - Parameter Radius: Radial value for where to place hour labels.
    /// - Returns: The node with the hour labels. Nil if the user does not want to display hours or if
    ///            `.RelativeToLocation` is selected but no local information is available.
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
                if Settings.GetLocalLongitude() == nil || Settings.GetLocalLatitude() == nil
                {
                    return nil
                }
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
            HourText.firstMaterial?.diffuse.contents = UIColor(red: 239.0 / 255.0, green: 204.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
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
        
        var HourList = [0, -1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
        HourList = HourList.Shift(By: -6)
        let LocalLongitude = Settings.GetLocalLongitude()!
        let Long = Int(LocalLongitude / 15.0)
        HourList = HourList.Shift(By: Long)
        for Hour in 0 ... 23
        {
            //Get the angle for the text. The +2.0 is because SCNText geometries start at the X position
            //and move to the right - to make the text line up closely (but not perfectly) with the noon
            //sun, adding a small amount adjusts the X position.
            let Hour = (Hour + 7) % 24
            let Angle = ((CGFloat(Hour) / 24.0) * 360.0) + 2.0
            let Radians = (Angle).Radians
            //Calculate the display hour.
            var Prefix = ""
            let DisplayHour = HourList[Hour]
            if DisplayHour > 0
            {
                Prefix = "+"
            }
            
            let HourText = SCNText(string: "\(Prefix)\(DisplayHour)", extrusionDepth: 5.0)
            HourText.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.bold)
            HourText.firstMaterial?.diffuse.contents = UIColor(red: 227.0 / 255.0, green: 1.0, blue: 0.0, alpha: 1.0)
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
