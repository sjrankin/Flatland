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
    /// - Note: If `InVersionDisplayMode` is true, a special case is executed and control returned
    ///         before any other cases are executed. Also, the current declination is ignored if
    ///         `InVersionDisplayMode` is true.
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
        var HourLabelList = [String]()
        
        for Hour in 0 ... 23
        {
            //Calculate the display hour.
            let DisplayHour = 24 - (Hour + 5) % 24 - 1
            HourLabelList.append("\(DisplayHour)")
        }
        return PlotHourLabels(Radius: Radius, Labels: HourLabelList, LetterColor: UIColor.yellow, RadialOffset: 6.0)
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
        var HourLabelList = [String]()
        
        for Hour in 0 ... 23
        {
            //Calculate the display hour.
            var DisplayHour = 24 - (Hour + 5) % 24 - 1
            DisplayHour = DisplayHour - 12
            var Prefix = ""
            if DisplayHour > 0
            {
                Prefix = "+"
            }
            HourLabelList.append("\(Prefix)\(DisplayHour)")
        }
        let LetterColor = UIColor(red: 239.0 / 255.0, green: 204.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
        return PlotHourLabels(Radius: Radius, Labels: HourLabelList, LetterColor: LetterColor, RadialOffset: 6.0)
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
        var HourLabelList = [String]()
        for Hour in 0 ... 23
        {
            let Hour = Hour % 24
            var Prefix = ""
            let DisplayHour = HourList[Hour]
            if DisplayHour > 0
            {
                Prefix = "+"
            }
            HourLabelList.append("\(Prefix)\(DisplayHour)")
        }
        let LetterColor = UIColor(red: 227.0 / 255.0, green: 1.0, blue: 0.0, alpha: 1.0)
        return PlotHourLabels(Radius: Radius, Labels: HourLabelList, LetterColor: LetterColor)
    }
    
    /// Convert a number in the range 0 to 24 from an integer to the proper string in the current
    /// display language.
    /// - Parameter Number: The number to convert.
    /// - Returns: String with the proper number in the display language.
    func ConvertToLanguage(_ Number: Int) -> String
    {
        if Number < 0 || Number > 24
        {
            fatalError("Invalid number for conversion (\(Number)) - out of range [0...24].")
        }
        switch Settings.GetDisplayLanguage()
        {
            case .English:
            return "\(Number)"
            
            case .Japanese:
            return JapaneseHours[Number]
        }
    }
    
    /// Given an array of words, place a set of words in the hour ring over the Earth.
    /// - Note: Pay attention to the word order - it must be reversed in `Words` in order for
    ///         words to appear correctly as people would expect.
    /// - Parameter Radius: The radius of the word.
    /// - Parameter Labels: Array of hour values (if order is significant, the first word in the order
    ///                    must be the last entry in the array) to display as expected.
    /// - Parameter LetterColor: The color to use for the diffuse surface.
    /// - Parameter RadialOffset: Offset value for adjusting the final location of the letter in orbit.
    /// - Returns: Node for words in the hour ring.
    func PlotHourLabels(Radius: Double, Labels: [String], LetterColor: UIColor = UIColor.systemYellow,
                        RadialOffset: CGFloat = 0.0) -> SCNNode
    {
        let NodeShape = SCNSphere(radius: CGFloat(Radius))
        let Node = SCNNode(geometry: NodeShape)
        Node.position = SCNVector3(0.0, 0.0, 0.0)
        Node.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        Node.geometry?.firstMaterial?.specular.contents = UIColor.clear
        Node.name = "Hour Node"
        
        let StartAngle = 0
        var Angle = StartAngle
        for Label in Labels
        {
            var WorkingAngle: CGFloat = CGFloat(Angle) + RadialOffset
            var PreviousEnding: CGFloat = 0.0
            var TotalLabelWidth: CGFloat = 0.0
            for (_, Letter) in Label.enumerated()
            {
                let Radians = WorkingAngle.Radians
                let HourText = SCNText(string: String(Letter), extrusionDepth: 5.0)
                let SpecularColor = UIColor.white
                let VerticalOffset: CGFloat = 0.8
                HourText.font = UIFont(name: "Avenir-Heavy", size: 20.0)
                var CharWidth: Float = 0
                if Letter == " "
                {
                    CharWidth = 3.5
                }
                else
                {
                    CharWidth = abs(HourText.boundingBox.max.x - HourText.boundingBox.min.x)
                }
                PreviousEnding = CGFloat(CharWidth)
                if ["0", "2", "3", "4", "5", "6", "7", "8", "9"].contains(Letter)
                {
                    PreviousEnding = CGFloat(10.0)
                }
                if Letter == "1"
                {
                    PreviousEnding = CGFloat(6.0)
                }
                WorkingAngle = WorkingAngle - (PreviousEnding * 0.5)
                HourText.firstMaterial?.diffuse.contents = LetterColor
                HourText.firstMaterial?.specular.contents = SpecularColor
                HourText.flatness = 0.1
                let X = CGFloat(Radius) * cos(Radians)
                let Z = CGFloat(Radius) * sin(Radians)
                let HourTextNode = SCNNode(geometry: HourText)
                HourTextNode.scale = SCNVector3(0.07, 0.07, 0.07)
                HourTextNode.position = SCNVector3(X, -VerticalOffset, Z)
                let HourRotation = (90.0 - Double(WorkingAngle) + 00.0).Radians
                HourTextNode.eulerAngles = SCNVector3(0.0, HourRotation, 0.0)
                
                HourTextNode.geometry?.firstMaterial?.metalness.contents = NSNumber(value: 1.0)
                HourTextNode.geometry?.firstMaterial?.roughness.contents = NSNumber(value: 0.6)
                HourTextNode.geometry?.firstMaterial?.lightingModel = .physicallyBased
                
                Node.addChildNode(HourTextNode)
                TotalLabelWidth = TotalLabelWidth + (CGFloat(CharWidth) + PreviousEnding)
            }
            print("Width of \(Label) is \(TotalLabelWidth)")
            //Adjust the angle by one hour.
            Angle = Angle + 15
        }
        
        return Node
    }
}
