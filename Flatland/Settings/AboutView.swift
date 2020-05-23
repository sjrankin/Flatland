//
//  AboutView.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class AboutView: UIViewController, UIPopoverPresentationControllerDelegate
{
    public weak var ClosedDelegate: ChildClosed? = nil
    
    var ShowSphericalEarth = true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        DrawAboutGlobe()
    }
    
    @IBAction func HandleEarthTypeChanged(_ sender: Any)
    {
        
        if ShowSphericalEarth
        {
            EarthTypeButton.setImage(UIImage(systemName: "globe"), for: .normal)
        }
        else
        {
            EarthTypeButton.setImage(UIImage(systemName: "cube"), for: .normal)
        }
        ShowSphericalEarth = !ShowSphericalEarth
        DrawWorld()
    }
    
    @IBAction func HandleCloseButtonPressed(_ sender: Any)
    {
        ClosedDelegate?.ChildWindowClosed(false)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleDetailsPressed(_ sender: Any)
    {
        let Storyboard = UIStoryboard(name: "Menus", bundle: nil)
        if let Controller = Storyboard.instantiateViewController(identifier: "VersioningMenu") as? VersioningMenu
        {
            Controller.modalPresentationStyle = .popover
            if let PresentingController = Controller.presentationController
            {
                PresentingController.delegate = self
            }
            self.present(Controller, animated: true, completion: nil)
            if let PopView = Controller.popoverPresentationController
            {
                PopView.sourceView = DetailsButton
                PopView.sourceRect = DetailsButton.bounds
            }
        }
    }
    
    /// Tells the view controller how to display the context menus.
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle
    {
        return UIModalPresentationStyle.none
    }
    
    /// Initialize the 3D view and show the appropriate Earth.
    func DrawAboutGlobe()
    {
        AboutWorld.allowsCameraControl = true
        AboutWorld.autoenablesDefaultLighting = false
        AboutWorld.scene = SCNScene()
        AboutWorld.backgroundColor = UIColor.clear
        
        let Camera = SCNCamera()
        Camera.fieldOfView = 90.0
        Camera.usesOrthographicProjection = true
        Camera.orthographicScale = 14
        Camera.zFar = 500
        Camera.zNear = 0.1
        CameraNode = SCNNode()
        CameraNode.camera = Camera
        //The camera's position is higher up in the scene to help show the shadows.
        CameraNode.position = SCNVector3(0.0, 10.0, 16.0)
        
        let Light = SCNLight()
        Light.type = .directional
        Light.intensity = 800
        Light.castsShadow = true
        Light.shadowColor = UIColor.black.withAlphaComponent(0.80)
        Light.shadowMode = .forward
        Light.shadowRadius = 10.0
        Light.color = UIColor.white
        LightNode = SCNNode()
        LightNode.light = Light
        LightNode.position = SCNVector3(0.0, 0.0, 80.0)
        
        let MoonLight = SCNLight()
        MoonLight.type = .directional
        MoonLight.intensity = 300
        MoonLight.castsShadow = true
        MoonLight.shadowColor = UIColor.black.withAlphaComponent(0.80)
        MoonLight.shadowMode = .forward
        MoonLight.shadowRadius = 10.0
        MoonLight.color = UIColor.cyan
        MoonNode = SCNNode()
        MoonNode.light = MoonLight
        MoonNode.position = SCNVector3(0.0, 0.0, -100.0)
        MoonNode.eulerAngles = SCNVector3(180.0 * CGFloat.pi / 180.0, 0.0, 0.0)
        
        AboutWorld.scene?.rootNode.addChildNode(CameraNode)
        AboutWorld.scene?.rootNode.addChildNode(LightNode)
        AboutWorld.scene?.rootNode.addChildNode(MoonNode)
        
        DrawWorld()
        StartEarthClock()
        //Make sure the camera is pointed to the Earth.
        CameraNode.look(at: SCNVector3(0.0, 0.0, 0.0))
    }
    
    var CameraNode = SCNNode()
    var LightNode = SCNNode()
    var MoonNode = SCNNode()
    
    func StartEarthClock()
    {
        let _ = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(UpdateAboutEarth),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc func UpdateAboutEarth()
    {
        let Now = Date()
        let TZ = TimeZone(abbreviation: "UTC")
        var Cal = Calendar(identifier: .gregorian)
        Cal.timeZone = TZ!
        let Hour = Cal.component(.hour, from: Now)
        let Minute = Cal.component(.minute, from: Now)
        let Second = Cal.component(.second, from: Now)
        let ElapsedSeconds = Second + (Minute * 60) + (Hour * 60 * 60)
        let Percent = Double(ElapsedSeconds) / Double(Date.SecondsIn(.Day))
        let PrettyPercent = Double(Int(Percent * 1000.0)) / 1000.0
        UpdateEarth(With: PrettyPercent)
    }
    
    func UpdateEarth(With Percent: Double)
    {
        let Degrees = 180.0 - (360.0) * Percent
        let Radians = Degrees.Radians
        let Rotate = SCNAction.rotateTo(x: 0.0, y: CGFloat(-Radians), z: 0.0, duration: 1.0)
        EarthNode?.runAction(Rotate)
    }
    
    /// Draw the world. Depending on the user, draw a spherical or cubical world.
    func DrawWorld()
    {
        if ShowSphericalEarth
        {
            DrawGlobeWorld()
        }
        else
        {
            DrawAboutCube()
        }
    }
    
    /// Draw a spherical world.
    func DrawGlobeWorld()
    {
        EarthNode?.removeAllActions()
        EarthNode?.removeFromParentNode()
        EarthNode = nil
        SystemNode?.removeAllActions()
        SystemNode?.removeFromParentNode()
        SystemNode = nil
        
        let Surface = SCNSphere(radius: 10.0)
        Surface.segmentCount = 100
        let BaseMap = UIImage(named: "AboutMap")
        if BaseMap == nil
        {
            fatalError("Error retrieving base map in About.")
        }
        EarthNode = SCNNode(geometry: Surface)
        EarthNode?.position = SCNVector3(0.0, 0.0, 0.0)
        EarthNode?.geometry?.firstMaterial?.diffuse.contents = BaseMap!
        SystemNode = SCNNode()
        AboutWorld.prepare([EarthNode!], completionHandler:
            {
                success in
                if success
                {
                    self.SystemNode!.addChildNode(self.EarthNode!)
                    self.AboutWorld.scene?.rootNode.addChildNode(self.SystemNode!)
                }
        })
        
        let Declination = Sun.Declination(For: Date())
        SystemNode!.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
        AddAboutText()
    }
    
    /// Draws a cubical Earth for no other reason than being silly.
    func DrawAboutCube()
    {
        EarthNode?.removeAllActions()
        EarthNode?.removeFromParentNode()
        SystemNode?.removeAllActions()
        SystemNode?.removeFromParentNode()
        
        let EarthCube = SCNBox(width: 10.0, height: 10.0, length: 10.0, chamferRadius: 0.5)
        EarthNode = SCNNode(geometry: EarthCube)
        
        EarthNode?.position = SCNVector3(0.0, 0.0, 0.0)
        EarthNode?.geometry?.materials.removeAll()
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.nx)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.pz)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.px)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.nz)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.ny, Rotated: 270.0)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.py, Rotated: 90.0)!)
        
        EarthNode?.geometry?.firstMaterial?.specular.contents = UIColor.clear
        EarthNode?.geometry?.firstMaterial?.lightingModel = .blinn
        
        let Declination = Sun.Declination(For: Date())
        SystemNode = SCNNode()
        SystemNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
        
        AboutWorld.prepare([EarthNode!], completionHandler:
            {
                success in
                if success
                {
                    self.SystemNode?.addChildNode(self.EarthNode!)
                    self.AboutWorld.scene?.rootNode.addChildNode(self.SystemNode!)
                }
        }
        )
    }
    
    /// Draw the version string that orbits the Earth.
    func AddAboutText()
    {
        var Words = [String]()
        Words.append("Build \(Versioning.Build) (\(Versioning.BuildDate))")
        Words.append(Versioning.MakeVersionString())
        Words.append(Versioning.ApplicationName)
        HourNode = MakeSentence(Radius: 11.1, Words: Words)
        AboutWorld.scene?.rootNode.addChildNode(HourNode!)
        let Rotation = SCNAction.rotateBy(x: 0.0, y: -CGFloat.pi / 180.0, z: 0.0, duration: 0.06)
        let Forever = SCNAction.repeatForever(Rotation)
        HourNode?.runAction(Forever)
    }
    
    var EarthNode: SCNNode? = nil
    var SystemNode: SCNNode? = nil
    var HourNode: SCNNode? = nil
    
    /// Given an array of words, place a set of words in the hour ring over the Earth.
    /// - Note: Pay attention to the word order - it must be reversed in `Words` in order for
    ///         words to appear correctly as people would expect.
    /// - Parameter Radius: The radius of the word.
    /// - Parameter Words: Array of words (if order is significant, the first word in the order
    ///                    must be the last entry in the array) to display as expected.
    /// - Returns: Node for words in the hour ring.
    func MakeSentence(Radius: Double, Words: [String]) -> SCNNode
    {
        let NodeShape = SCNSphere(radius: CGFloat(Radius))
        let Node = SCNNode(geometry: NodeShape)
        Node.position = SCNVector3(0.0, 0.0, 0.0)
        Node.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        Node.geometry?.firstMaterial?.specular.contents = UIColor.clear
        Node.name = "Hour Node"
        
        let StartAngle = -100
        var Angle = StartAngle
        for Word in Words
        {
            var WorkingAngle: CGFloat = CGFloat(Angle)
            var PreviousEnding: CGFloat = 0.0
            for (_, Letter) in Word.enumerated()
            {
                let Radians = WorkingAngle.Radians
                let HourText = SCNText(string: String(Letter), extrusionDepth: 5.0)
                var LetterColor = UIColor.systemYellow
                var SpecularColor = UIColor.white
                var VerticalOffset: CGFloat = 0.8
                if Word == Versioning.ApplicationName
                {
                    HourText.font = UIFont(name: "Avenir-Black", size: 28.0)
                    LetterColor = UIColor.systemRed
                    SpecularColor = UIColor.systemOrange
                }
                else
                {
                    HourText.font = UIFont(name: "Avenir-Heavy", size: 24.0)
                    VerticalOffset = 0.6
                }
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
                if Letter == "V"
                {
                    PreviousEnding = CGFloat(12.0)
                }
                if Letter == "l"
                {
                    PreviousEnding = CGFloat(6.0)
                }
                if ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains(Letter)
                {
                    PreviousEnding = CGFloat(10.0)
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
                Node.addChildNode(HourTextNode)
            }
            Angle = Angle + 65
        }
        
        return Node
    }
    
    @IBOutlet weak var EarthTypeButton: UIButton!
    @IBOutlet weak var DetailsButton: UIButton!
    @IBOutlet weak var AboutWorld: SCNView!
}
