//
//  GlobeView.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/17/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Provide the main 3D view for Flatland.
class GlobeView: SCNView, GlobeProtocol
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        InitializeView()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        InitializeView()
    }
    
    /// Hide the globe view.
    public func Hide()
    {
        if EarthClock != nil
        {
            EarthClock?.invalidate()
            EarthClock = nil
        }
        self.isHidden = true
        self.isUserInteractionEnabled = false
    }
    
    /// Show the globe view.
    public func Show()
    {
        StartClock()
        self.isHidden = false
        self.isUserInteractionEnabled = true
    }
    
    /// Initialize the globe view.
    func InitializeView()
    {
        //        self.debugOptions = [.showBoundingBoxes, .renderAsWireframe]
        self.allowsCameraControl = true
        self.autoenablesDefaultLighting = false
        self.scene = SCNScene()
        self.backgroundColor = UIColor.clear
        #if DEBUG
        self.showsStatistics = true
        #else
        self.showsStatistics = false
        #endif
        
        let Camera = SCNCamera()
        Camera.fieldOfView = 90.0
        Camera.usesOrthographicProjection = true
        Camera.orthographicScale = 14
        Camera.zFar = 500
        Camera.zNear = 0.1
        CameraNode = SCNNode()
        CameraNode.camera = Camera
        CameraNode.position = SCNVector3(0.0, 0.0, 16.0)
        
        SunLight = SCNLight()
        SunLight.type = .directional
        SunLight.intensity = 800
        SunLight.castsShadow = true
        SunLight.shadowColor = UIColor.black.withAlphaComponent(0.80)
        SunLight.shadowMode = .forward
        SunLight.shadowRadius = 10.0
        SunLight.color = UIColor.white
        LightNode = SCNNode()
        LightNode.light = SunLight
        LightNode.position = SCNVector3(0.0, 0.0, 80.0)
        
        self.scene?.rootNode.addChildNode(CameraNode)
        self.scene?.rootNode.addChildNode(LightNode)
        SetMoonlight(Show: Settings.GetShowMoonlight())
        
        AddEarth()
        StartClock()
        UpdateEarthView()
        SetHourResetTimer()
    }
    
    /// Set the hour reset timer.
    func SetHourResetTimer()
    {
        ResetTimer?.invalidate()
        ResetTimer = nil
        if Settings.ResetHoursPeriodically()
        {
            var Duration = Settings.GetHourResetDuration()
            if Duration == 0.0
            {
                Settings.SetHourResetDuration(60.0 * 60.0)
                Duration = 60.0 * 60.0
            }
            ResetTimer = Timer.scheduledTimer(timeInterval: Duration, target: self, selector: #selector(ResetHours),
                                              userInfo: nil, repeats: true)
        }
    }
    
    var ResetTimer: Timer? = nil
    
    /// Handle resetting the hour display.
    @objc func ResetHours()
    {
        UpdateHourLabels(With: Settings.GetHourValueType())
    }
    
    /// Show or hide the moonlight node.
    /// - Parameter Show: Determines if moonlight is shown or removed.
    func SetMoonlight(Show: Bool)
    {
        print("Set moonlight to \(Show)")
        if Show
        {
            let MoonLight = SCNLight()
            MoonLight.type = .directional
            MoonLight.intensity = 300
            MoonLight.castsShadow = true
            MoonLight.shadowColor = UIColor.black.withAlphaComponent(0.80)
            MoonLight.shadowMode = .forward
            MoonLight.shadowRadius = 2.0
            MoonLight.color = UIColor.cyan
            MoonNode = SCNNode()
            MoonNode?.light = MoonLight
            MoonNode?.position = SCNVector3(0.0, 0.0, -100.0)
            MoonNode?.eulerAngles = SCNVector3(180.0 * CGFloat.pi / 180.0, 0.0, 0.0)
            self.scene?.rootNode.addChildNode(MoonNode!)
        }
        else
        {
            MoonNode?.removeAllActions()
            MoonNode?.removeFromParentNode()
            MoonNode = nil
        }
    }
    
    var SunLight = SCNLight()
    var CameraNode = SCNNode()
    var LightNode = SCNNode()
    var MoonNode: SCNNode? = nil
    
    func SetDisplayLanguage()
    {
        
    }
    
    func SetClockMultiplier(_ Multiplier: Double)
    {
        //        ClockMultiplier = Multiplier
        //AddEarth(FastAnimate: true)
    }
    
    func StopClock()
    {
        EarthClock?.invalidate()
        EarthClock = nil
    }
    
    func StartClock()
    {
        EarthClock = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(UpdateEarthView),
                                          userInfo: nil, repeats: true)
    }
    
    var EarthClock: Timer? = nil
    
    /// Returns the local time zone abbreviation (a three-letter indicator, not a set of words).
    /// - Returns: The local time zone identifier if found, nil if not found.
    func GetLocalTimeZoneID() -> String?
    {
        let TZID = TimeZone.current.identifier
        for (Abbreviation, Wordy) in TimeZone.abbreviationDictionary
        {
            if Wordy == TZID
            {
                return Abbreviation
            }
        }
        return nil
    }
    
    var ClockMultiplier: Double = 1.0
    
    @objc func UpdateEarthView()
    {
        if IgnoreClock
        {
            return
        }
        #if false
        let Now = Date()
        let Formatter = DateFormatter()
        Formatter.dateFormat = "HH:mm:ss"
        var TimeZoneAbbreviation = ""
        if Settings.GetTimeLabel() == .UTC
        {
            TimeZoneAbbreviation = "UTC"
        }
        else
        {
            TimeZoneAbbreviation = GetLocalTimeZoneID() ?? "UTC"
        }
        let TZ = TimeZone(abbreviation: TimeZoneAbbreviation)
        Formatter.timeZone = TZ
        let Final = Formatter.string(from: Now)
        let FinalText = Final + " " + TimeZoneAbbreviation
        TimeLabel.text = FinalText
        #else
        let Now = Date()
        let TZ = TimeZone(abbreviation: "UTC")
        #endif
        
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
        #if false
        SystemNode?.runAction(Rotate)
        #else
        EarthNode?.runAction(Rotate)
        SeaNode?.runAction(Rotate)
        LineNode?.runAction(Rotate)
        if Settings.GetHourValueType() == .RelativeToLocation
        {
            HourNode?.runAction(Rotate)
        }
        #endif
    }
    
    var IgnoreClock = false
    
    /// Add an Earth view to the 3D view.
    /// - Parameter FastAnimated: Used for debugging.
    func AddEarth(FastAnimate: Bool = false)
    {
        if Settings.GetViewType() == .CubicWorld
        {
            ShowCubicEarth()
            return
        }
        IgnoreClock = FastAnimate
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
        if HourNode != nil
        {
            HourNode?.removeAllActions()
            HourNode?.removeFromParentNode()
            HourNode = nil
        }
        
        SystemNode = SCNNode()
        
        let EarthSphere = SCNSphere(radius: 10.01)
        EarthSphere.segmentCount = 100
        let SeaSphere = SCNSphere(radius: 10)
        SeaSphere.segmentCount = 100
        
        let MapType = Settings.GetGlobeMapType()
        var BaseMap: UIImage? = nil
        var SecondaryMap = UIImage()
        BaseMap = MapManager.ImageFor(MapType: MapType, ViewType: .Globe3D)
        if BaseMap == nil
        {
            fatalError("Error retrieving base map \(MapType).")
        }
        switch MapType
        {
            case .Standard:
                SecondaryMap = MapManager.ImageFor(MapType: .StandardSea, ViewType: .Globe3D)!
            
            case .TectonicOverlay:
                SecondaryMap = MapManager.ImageFor(MapType: .Dithered, ViewType: .Globe3D)!
            
            default:
                break
        }
        
        EarthNode = SCNNode(geometry: EarthSphere)
        EarthNode?.position = SCNVector3(0.0, 0.0, 0.0)
        EarthNode?.geometry?.firstMaterial?.diffuse.contents = BaseMap!
        EarthNode?.geometry?.firstMaterial?.lightingModel = .blinn
        
        //Precondition the surfaces.
        switch MapType
        {
            case .Debug2:
            SeaNode = SCNNode(geometry: SeaSphere)
            SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
            SeaNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.systemTeal
            SeaNode?.geometry?.firstMaterial?.specular.contents = UIColor.white
            EarthNode?.geometry?.firstMaterial?.specular.contents = UIColor.clear
            
            case .Debug5:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.systemYellow
                SeaNode?.geometry?.firstMaterial?.specular.contents = UIColor.white
                EarthNode?.geometry?.firstMaterial?.specular.contents = UIColor.clear
            
            case .TectonicOverlay:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = SecondaryMap
            
            case .ASCIIArt1:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.white
                SeaNode?.geometry?.firstMaterial?.specular.contents = UIColor.yellow
            
            case .BlackWhiteShiny:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.white
                SeaNode?.geometry?.firstMaterial?.specular.contents = UIColor.yellow
                SeaNode?.geometry?.firstMaterial?.lightingModel = .phong
            
            case .Standard:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = SecondaryMap
                SeaNode?.geometry?.firstMaterial?.specular.contents = UIColor.white
                SeaNode?.geometry?.firstMaterial?.lightingModel = .blinn
            
            case .SimpleBorders2:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.systemBlue
                SeaNode?.geometry?.firstMaterial?.specular.contents = UIColor.white
                SeaNode?.geometry?.firstMaterial?.lightingModel = .phong
            
            case .Topographical1:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.systemBlue
                SeaNode?.geometry?.firstMaterial?.specular.contents = UIColor.white
                SeaNode?.geometry?.firstMaterial?.lightingModel = .phong
            
            case .Pink:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
                SeaNode?.geometry?.firstMaterial?.specular.contents = UIColor.yellow
                EarthNode?.geometry?.firstMaterial?.lightingModel = .phong
            
            case .Bronze:
                EarthNode?.geometry?.firstMaterial?.specular.contents = UIColor.orange
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 1.0,
                                                                             green: 210.0 / 255.0,
                                                                             blue: 0.0,
                                                                             alpha: 1.0)
                SeaNode?.geometry?.firstMaterial?.specular.contents = UIColor.white
                SeaNode?.geometry?.firstMaterial?.lightingModel = .lambert
            
            default:
                //Create an empty sea node if one is not needed.
                SeaNode = SCNNode()
        }
        
        PlotLocations(On: EarthNode!, WithRadius: 10)
        
        let SeaMapList: [MapTypes] = [.Standard, .Topographical1, .SimpleBorders2, .Pink, .Bronze,
                                      .TectonicOverlay, .BlackWhiteShiny, .ASCIIArt1, .Debug2,
                                      .Debug5]
        self.prepare([EarthNode!, SeaNode!/*, LineNode!*/], completionHandler:
            {
                success in
                if success
                {
                    self.SystemNode?.addChildNode(self.EarthNode!)
                    if SeaMapList.contains(MapType)
                    {
                        self.SystemNode?.addChildNode(self.SeaNode!)
                    }
                    self.scene?.rootNode.addChildNode(self.SystemNode!)
                }
        }
        )
        
        SetLineLayer()
        
        UpdateHourLabels(With: Settings.GetHourValueType())
        
        let Declination = Sun.Declination(For: Date())
        SystemNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
        
        if FastAnimate
        {
            let EarthRotate = SCNAction.rotateBy(x: 0.0, y: 360.0 * CGFloat.pi / 180.0, z: 0.0, duration: 30.0)
            let RotateForever = SCNAction.repeatForever(EarthRotate)
            SystemNode?.runAction(RotateForever)
        }
    }
    
    var PreviousHourType: HourValueTypes = .None
    
    func SetLineLayer()
    {
        LineNode?.removeFromParentNode()
        LineNode = nil
        if !HasVisibleLines()
        {
            return
        }
        let LineSphere = SCNSphere(radius: 10.2)
        LineSphere.segmentCount = 100
        LineNode = SCNNode(geometry: LineSphere)
        LineNode?.position = SCNVector3(0.0, 0.0, 0.0)
        let Maroon = UIColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0)
        let GridLines = MakeGridLines(Width: 3600, Height: 1800, LineColor: Maroon)
        LineNode?.geometry?.firstMaterial?.diffuse.contents = GridLines
        LineNode?.geometry?.firstMaterial?.emission.contents = Maroon
        LineNode?.castsShadow = false
        SystemNode?.addChildNode(self.LineNode!)
    }
    
    func HasVisibleLines() -> Bool
    {
        if Settings.ShowEquator()
        {
            return true
        }
        if Settings.ShowTropics()
        {
            return true
        }
        if Settings.ShowPolarCircles()
        {
            return true
        }
        if Settings.ShowPrimeMeridians()
        {
            return true
        }
        if Settings.ShowNoonMeridians()
        {
            return true
        }
        if Settings.ShowMinorGridLines()
        {
            return true
        }
        return false
    }
    
    /// Finds and removes all sub-nodes in `Parent` with the specified name.
    /// - Parameter Parent: The parent node whose sub-nodes are checked for nodes to remove.
    /// - Parameter Named: Name of the sub-node to remove. All sub-nodes with this name will be removed.
    func RemoveNodeFrom(Parent Node: SCNNode, Named: String)
    {
        for Child in Node.childNodes
        {
            if Child.name == Named
            {
                Child.removeAllActions()
                Child.removeFromParentNode()
            }
        }
    }
    
    /// Change the transparency of the land and sea nodes to what is in user settings.
    func UpdateSurfaceTransparency()
    {
        let Alpha = 1.0 - Settings.GetTransparencyLevel()
        EarthNode?.opacity = CGFloat(Alpha)
        SeaNode?.opacity = CGFloat(Alpha)
        HourNode?.opacity = CGFloat(Alpha)
        LineNode?.opacity = CGFloat(Alpha)
    }
    
    var RotationAccumulator: CGFloat = 0.0
    var SystemNode: SCNNode? = nil
    var LineNode: SCNNode? = nil
    var EarthNode: SCNNode? = nil
    var SeaNode: SCNNode? = nil
    var HourNode: SCNNode? = nil
    
    // MARK: - GlobeProtocol functions
    
    func PlotSatellite(Satellite: Satellites, At: GeoPoint2)
    {
        let SatelliteAltitude = 10.01 * (At.Altitude / 6378.1)
        let (X, Y, Z) = ToECEF(At.Latitude, At.Longitude, Radius: SatelliteAltitude)
    }
    
    // MARK: - Variables for extensions.
    
    /// List of hours in Japanese Kanji.
    let JapaneseHours = ["〇", "一", "二", "三", "四", "五", "六", "七", "八", "九",
                         "十", "十一", "十二", "十三", "十四", "十五", "十六", "十七",
                         "十八", "十九", "二十", "二十一", "二十二", "二十三", "二十四"]
    
    var NorthPoleFlag: SCNNode? = nil
    var SouthPoleFlag: SCNNode? = nil
    var NorthPolePole: SCNNode? = nil
    var SouthPolePole: SCNNode? = nil
    var HomeNode: SCNNode? = nil
    var HomeNodeHalo: SCNNode? = nil
    var PlottedCities = [SCNNode?]()
    var WHSNodeList = [SCNNode?]()
}

