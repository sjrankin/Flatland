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

class GlobeView: SCNView
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
        self.autoenablesDefaultLighting = false
        self.scene = SCNScene()
        self.backgroundColor = UIColor.clear//UIColor.black
        
        let Camera = SCNCamera()
        Camera.fieldOfView = 90.0
        Camera.usesOrthographicProjection = true
        Camera.orthographicScale = 14
        Camera.zFar = 500
        Camera.zNear = 0
        CameraNode = SCNNode()
        CameraNode.camera = Camera
        CameraNode.position = SCNVector3(0.0, 0.0, 16.0)
        
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
        MoonLight.type = .omni
        MoonLight.intensity = 200
        MoonLight.color = UIColor.gray
        MoonNode = SCNNode()
        MoonNode.light = MoonLight
        MoonNode.position = SCNVector3(0.0, 0.0, -100.0)
        
        self.scene?.rootNode.addChildNode(CameraNode)
        self.scene?.rootNode.addChildNode(LightNode)
        self.scene?.rootNode.addChildNode(MoonNode)
        
        AddEarth()
        StartClock()
        UpdateEarthView()
    }
    
    var CameraNode = SCNNode()
    var LightNode = SCNNode()
    var MoonNode = SCNNode()
    
    func SetClockMultiplier(_ Multiplier: Double)
    {
        //        ClockMultiplier = Multiplier
        AddEarth(FastAnimate: true)
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
        //print("Percent(\(Percent))=\(Degrees.RoundedTo(4))°")
        let Radians = Degrees.Radians
        let Rotate = SCNAction.rotateTo(x: 0.0, y: CGFloat(-Radians), z: 0.0, duration: 1.0)
        EarthNode?.runAction(Rotate)
        SeaNode?.runAction(Rotate)
        LineNode?.runAction(Rotate)
    }
    
    var IgnoreClock = false
    
    /// Draws a cubical Earth for not other reason than being silly.
    func ShowCubicEarth()
    {
        EarthNode?.removeAllActions()
        EarthNode?.removeFromParentNode()
        SeaNode?.removeAllActions()
        SeaNode?.removeFromParentNode()
        LineNode?.removeAllActions()
        LineNode?.removeFromParentNode()
        SystemNode?.removeAllActions()
        SystemNode?.removeFromParentNode()
        HourNode?.removeAllActions()
        HourNode?.removeFromParentNode()
        
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
        
        UpdateHourLabels()
        
        let Declination = Sun.Declination(For: Date())
        SystemNode = SCNNode()
        SystemNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
        HourNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
        
        self.prepare([EarthNode!], completionHandler:
            {
                success in
                if success
                {
                    self.SystemNode?.addChildNode(self.EarthNode!)
                    self.scene?.rootNode.addChildNode(self.SystemNode!)
                }
        }
        )
    }
    
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
        
        #if false
        let EarthSphere = SCNBox(width: 10, height: 10, length: 10, chamferRadius: 1)
        let SeaSphere = SCNBox(width: 10, height: 10, length: 10, chamferRadius: 1)
        let LineSphere = SCNBox(width: 10.2, height: 1.2, length: 10.2, chamferRadius: 1)
        #else
        let EarthSphere = SCNSphere(radius: 10.01)
        EarthSphere.segmentCount = 100
        let SeaSphere = SCNSphere(radius: 10)
        SeaSphere.segmentCount = 100
        let LineSphere = SCNSphere(radius: 10.2)
        LineSphere.segmentCount = 100
        #endif
        
        let MapType = Settings.GetGlobeMapType()
        var BaseMap = UIImage()
        var SecondaryMap = UIImage()
        BaseMap = MapManager.ImageFor(MapType: MapType, ViewType: .Globe3D)!
        if MapType == .Standard
        {
            SecondaryMap = MapManager.ImageFor(MapType: .StandardSea, ViewType: .Globe3D)!
        }
        
        EarthNode = SCNNode(geometry: EarthSphere)
        EarthNode?.position = SCNVector3(0.0, 0.0, 0.0)
        EarthNode?.geometry?.firstMaterial?.diffuse.contents = BaseMap
        EarthNode?.geometry?.firstMaterial?.specular.contents = UIColor.clear
        EarthNode?.geometry?.firstMaterial?.lightingModel = .blinn
        SeaNode?.geometry?.firstMaterial?.lightingModel = .blinn
        
        SeaNode = SCNNode()
        //Precondition the surfaces.
        switch MapType
        {
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
                //EarthNode?.geometry?.firstMaterial?.specular.contents = UIColor.white
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
                break
        }
        
        UpdateSurfaceTransparency()
        UpdateHourLabels()
        
        LineNode = SCNNode(geometry: LineSphere)
        LineNode?.position = SCNVector3(0.0, 0.0, 0.0)
        let GridLines = MakeGridLines(Width: 3600, Height: 1800, LineColor: UIColor.systemRed)
        LineNode?.geometry?.firstMaterial?.diffuse.contents = GridLines
        LineNode?.castsShadow = false
        
        let Declination = Sun.Declination(For: Date())
        SystemNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
        HourNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
        
        PlotCities(On: EarthNode!, WithRadius: 10)
        
        let SeaMapList: [MapTypes] = [.Standard, .Topographical1, .SimpleBorders2, .Pink, .Bronze]
        self.prepare([EarthNode!, SeaNode!, LineNode!], completionHandler:
            {
                success in
                if success
                {
                    self.SystemNode?.addChildNode(self.EarthNode!)
                    if SeaMapList.contains(MapType)
                    {
                        self.SystemNode?.addChildNode(self.SeaNode!)
                    }
                    self.SystemNode?.addChildNode(self.LineNode!)
                    self.scene?.rootNode.addChildNode(self.SystemNode!)
                }
        }
        )
        
        if FastAnimate
        {
            let EarthRotate = SCNAction.rotateBy(x: 0.0, y: 360.0 * CGFloat.pi / 180.0, z: 0.0, duration: 30.0)
            let RotateForever = SCNAction.repeatForever(EarthRotate)
            EarthNode?.runAction(RotateForever)
            SeaNode?.runAction(RotateForever)
            LineNode?.runAction(RotateForever)
        }
    }
    
    /// Create or update or hide hour labels.
    func UpdateHourLabels()
    {
        if Settings.GetShowHourLabels()
        {
            HourNode?.removeAllActions()
            HourNode?.removeFromParentNode()
            let HourSphere = SCNSphere(radius: 11)
            HourNode = SCNNode(geometry: HourSphere)
            HourNode?.position = SCNVector3(0.0, 0.0, 0.0)
            HourNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
            HourNode?.geometry?.firstMaterial?.specular.contents = UIColor.clear
            DrawHourLabels(On: HourNode!, Radius: 11)
            let Declination = Sun.Declination(For: Date())
            HourNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
            self.scene?.rootNode.addChildNode(HourNode!)
        }
        else
        {
            if HourNode != nil
            {
                HourNode?.removeAllActions()
                HourNode?.removeFromParentNode()
                HourNode = nil
            }
            HourNode = SCNNode()
        }
    }
    
    /// Draw hour labels floating over the Earth.
    /// - Parameter On: The parent node.
    /// - Parameter Radius: The radius of the parent node.
    func DrawHourLabels(On Node: SCNNode, Radius: Double)
    {
        let HourType = Settings.GetHourValueType()
        for Hour in 0 ... 23
        {
            //Get the angle for the text. The +2.0 is because SCNText geometries start at the X position
            //and move to the right - to make the text line up closely (but not perfectly) with the noon
            //sun, adding a small amount adjusts the X position.
            let Angle = ((CGFloat(Hour) / 24.0) * 360.0) + 2.0
            let Radians = Angle.Radians
            //Calculate the display hour.
            var DisplayHour = 24 - (Hour + 5) % 24 - 1
            var Prefix = ""
            switch HourType
            {
                case .Solar:
                    //Already done.
                break
                
                case .RelativeToLocation:
                    if let LocalLon = Settings.GetLocalLongitude()
                    {
                        let LonHour = LocalLon / 15.0
                        let ILonHour = Int(LonHour)
                        DisplayHour = ILonHour - DisplayHour
                        if DisplayHour > 0
                        {
                            Prefix = "+"
                        }
                    }
                
                case .RelativeToNoon:
                    DisplayHour = DisplayHour - 12
                    if DisplayHour > 0
                    {
                        Prefix = "+"
                }
            }
            let HourText = SCNText(string: "\(Prefix)\(DisplayHour)", extrusionDepth: 5.0)
            HourText.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.bold)
            HourText.firstMaterial?.diffuse.contents = UIColor.yellow
            HourText.firstMaterial?.specular.contents = UIColor.white
            HourText.flatness = 0.1
            let X = CGFloat(Radius) * cos(Radians)
            let Z = CGFloat(Radius) * sin(Radians)
            let HourNode = SCNNode(geometry: HourText)
            HourNode.scale = SCNVector3(0.07, 0.07, 0.07)
            HourNode.position = SCNVector3(X, -0.8, Z)
            let HourRotation = (90.0 - Angle).Radians
            HourNode.eulerAngles = SCNVector3(0.0, HourRotation, 0.0)
            Node.addChildNode(HourNode)
        }
    }
    
    /// Change the transparency of the land and sea nodes to what is in user settings.
    func UpdateSurfaceTransparency()
    {
        let Alpha = 1.0 - Settings.GetTransparencyLevel()
        EarthNode?.opacity = CGFloat(Alpha)
        SeaNode?.opacity = CGFloat(Alpha)
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
        
        let CitySize: CGFloat = 0.15
        for City in TestCities
        {
            if City.IsUserCity
            {
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
    
    var RotationAccumulator: CGFloat = 0.0
    
    var SystemNode: SCNNode? = nil
    var LineNode: SCNNode? = nil
    var EarthNode: SCNNode? = nil
    var SeaNode: SCNNode? = nil
    var HourNode: SCNNode? = nil
    
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
    
    /// Draw an image with grid lines on it that can be used as a texture on top of a global image.
    /// - Note: This function draws the minor grid lines. It calls another function to draw the
    ///         major grid lines on top of the minor grid lines.
    /// - Parameter Width: Width of the image to return.
    /// - Parameter Height: Height of the image to return.
    /// - Parameter LineColor: The major grid line color.
    /// - Parameter MinorLineColor: The minor grid line color.
    /// - Returns: Image of the specified size with the grid lines drawn as per user settings.
    func MakeGridLines(Width: CGFloat, Height: CGFloat,
                       LineColor: UIColor = UIColor.red,
                       MinorLineColor: UIColor = UIColor.yellow) -> UIImage
    {
        let Base = MakeImageBase(Width: Width, Height: Height, FillColor: UIColor.clear)
        UIGraphicsBeginImageContext(Base.size)
        
        Base.draw(at: .zero)
        
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setLineWidth(3.0)
        ctx?.setStrokeColor(MinorLineColor.withAlphaComponent(0.5).cgColor)
        
        if Settings.ShowMinorGridLines()
        {
            let Gap = Settings.GetMinorGridLineGap()
            if Gap >= 5.0
            {
                for Longitude in stride(from: 0.0, to: 359.0, by: Gap)
                {
                    let X = Width * CGFloat(Longitude / 360.0)
                    ctx?.move(to: CGPoint(x: X, y: 0))
                    ctx?.addLine(to: CGPoint(x: X, y: Height))
                    ctx?.strokePath()
                }
                for Latitude in stride(from: 0.0, to: 359.0, by: Gap)
                {
                    let Y = Height * CGFloat(Latitude / 360.0)
                    ctx?.move(to: CGPoint(x: 0, y: Y))
                    ctx?.addLine(to: CGPoint(x: Width, y: Y))
                    ctx?.strokePath()
                }
            }
        }
        
        var Final = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //Draw the major grid lines on top of the minor grid lines.
        let FinalWithMajorLines = DrawMajorGridLines(On: Final!, Width: Width, Height: Height,
                                                     LineColor: LineColor)
        Final = FinalWithMajorLines
        return Final!
    }
    
    func DrawMajorGridLines(On Image: UIImage, Width: CGFloat, Height: CGFloat,
                            LineColor: UIColor = UIColor.yellow) -> UIImage
    {
        UIGraphicsBeginImageContext(Image.size)
        
        Image.draw(at: .zero)
        
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
}
