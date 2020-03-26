//
//  ViewController.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/26/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

class MainView: UIViewController, CAAnimationDelegate, SettingsProtocol
{
    /// Original orientation of the image with Greenwich, England as the baseline. Since this program
    /// treats midnight as the base and the image has Greenwich at the top, we need an offset value
    /// to make sure the image is rotated correctly.
    let OriginalOrientation: Double = 180.0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Settings.Initialize()
        WorldViewer.image = UIImage(named: PreviousImage)
        InitializeGrid()
        UpdateSunLocations()
        TopView.backgroundColor = UIColor.black
        StartTimeLabel()
    }
    
    override func viewDidLayoutSubviews()
    {
        OriginalTimeFrame = MainTimeLabel.frame
        OriginalSunFrame = SunView.frame
    }
    
    var OriginalTimeFrame: CGRect = CGRect.zero
    var OriginalSunFrame: CGRect = CGRect.zero
    
    func SettingsDone()
    {
        for Layer in GridOverlay.layer.sublayers!
        {
            if Layer.name == "ViewGrid"
            {
                Layer.removeFromSuperlayer()
            }
        }
        if Settings.ShowGrid()
        {
            InitializeGrid()
        }
        UpdateSunLocations()
        var ProvisionalImage = ""
        switch Settings.GetImageCenter()
        {
            case .NorthPole:
                ProvisionalImage = "WorldNorth"
            
            case .SouthPole:
                ProvisionalImage = "WorldSouth"
        }
        if ProvisionalImage != PreviousImage
        {
            PreviousImage = ProvisionalImage
            WorldViewer.image = UIImage(named: PreviousImage)
        }
        if Settings.GetTimeLabel() == .None
        {
            MainTimeLabel.isHidden = true
        }
        else
        {
            MainTimeLabel.isHidden = false
        }
        PreviousPercent = -1.0
    }
    
    func UpdateSunLocations()
    {
        switch Settings.GetSunLocation()
        {
            case .Hidden:
                SunView.isHidden = true
            
            case .Top:
                SunView.isHidden = false
                if Settings.GetTimeLabel() != .None
                {
                    MainTimeLabel.frame = OriginalTimeFrame
                }
                SunView.frame = OriginalTimeFrame
            
            case .Bottom:
                SunView.isHidden = false
                if Settings.GetTimeLabel() != .None
                {
                    MainTimeLabel.frame = CGRect(x: OriginalTimeFrame.origin.x,
                                                 y: OriginalSunFrame.origin.y,
                                                 width: OriginalTimeFrame.size.width,
                                                 height: OriginalTimeFrame.size.height)
                }
                SunView.frame = CGRect(x: SunView.frame.origin.x,
                                       y: OriginalTimeFrame.origin.y,
                                       width: SunView.frame.size.width,
                                       height: SunView.frame.size.height)
        }
    }
    
    func InitializeGrid()
    {
        GridOverlay.backgroundColor = UIColor.clear
        let Grid = CAShapeLayer()
        Grid.name = "ViewGrid"
        Grid.bounds = GridOverlay.frame
        Grid.frame = GridOverlay.frame
        let Lines = UIBezierPath()
        let CenterH = Grid.bounds.size.width / 2.0
        let CenterV = Grid.bounds.size.height / 2.0
        if Settings.ShowNoonMeridians()
        {
            Lines.move(to: CGPoint(x: CenterH, y: 0))
            Lines.addLine(to: CGPoint(x: CenterH, y: Grid.frame.size.height))
            Lines.move(to: CGPoint(x: 0, y: CenterV))
            Lines.addLine(to: CGPoint(x: Grid.frame.size.width, y: CenterV))
        }
        if Settings.ShowEquator()
        {
            let Equator = UIBezierPath(ovalIn: CGRect(x: CenterH / 2,
                                                      y: CenterV / 2,
                                                      width: CenterH,
                                                      height: CenterV))
            Lines.append(Equator)
        }
        if Settings.ShowTropics()
        {
            let TropicDistance: CGFloat = 23.43666
            let TropicPercent = Grid.bounds.size.width * (TropicDistance / 180.0)
            let CancerWidth = CenterH - TropicPercent
            let Cancer = UIBezierPath(ovalIn: CGRect(x: CenterH - (CancerWidth / 2.0),
                                                     y: CenterV - (CancerWidth / 2.0),
                                                     width: CancerWidth,
                                                     height: CancerWidth))
            let CapricornWidth = CenterH + TropicPercent
            let Capricorn = UIBezierPath(ovalIn: CGRect(x: CenterH - (CapricornWidth / 2.0),
                                                        y: CenterV - (CapricornWidth / 2.0),
                                                        width: CapricornWidth,
                                                        height: CapricornWidth))
            Lines.append(Cancer)
            Lines.append(Capricorn)
        }
        Grid.strokeColor = UIColor.systemYellow.withAlphaComponent(0.5).cgColor
        Grid.lineWidth = 1.0
        Grid.fillColor = UIColor.clear.cgColor
        Grid.path = Lines.cgPath
        GridOverlay.layer.addSublayer(Grid)
    }
    
    func StartTimeLabel()
    {
        TimeTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target: self,
                                         selector: #selector(TimeUpdater),
                                         userInfo: nil,
                                         repeats: true)
        TimeUpdater()
    }
    
    @objc func TimeUpdater()
    {
        let Now = GetUTC()
        let Formatter = DateFormatter()
        Formatter.dateFormat = "HH:mm:ss"
        let TZ = TimeZone(abbreviation: "UTC")
        Formatter.timeZone = TZ
        let Final = Formatter.string(from: Now)
        MainTimeLabel.text = Final + " UTC"
        var Cal = Calendar(identifier: .gregorian)
        Cal.timeZone = TZ!
        let Hour = Cal.component(.hour, from: Now)
        let Minute = Cal.component(.minute, from: Now)
        let Second = Cal.component(.second, from: Now)
        let ElapsedSeconds = Second + (Minute * 60) + (Hour * 60 * 60)
        let Percent = Double(ElapsedSeconds) / Double(SecondsInDay)
        let PrettyPercent = Double(Int(Percent * 1000.0)) / 1000.0
        RotateImageTo(PrettyPercent)
    }
    
    let SecondsInDay: Int = 60 * 60 * 24
    
    func GetUTC() -> Date
    {
        return Date()
    }
    
    var TimeTimer: Timer! = nil
    
    func RotateImageTo(_ Percent: Double)
    {
        if PreviousPercent == Percent
        {
            return
        }
        PreviousPercent = Percent
        let FinalOffset = Settings.GetSunLocation() == .Bottom ? 0.0 : OriginalOrientation
        let Degrees = 360.0 * Percent - FinalOffset
        let Radians = Degrees * Double.pi / 180.0
        let Rotation = CATransform3DMakeRotation(CGFloat(-Radians), 0.0, 0.0, 1.0)
        WorldViewer.layer.transform = Rotation
    }
    
    var PreviousImage: String = "WorldNorth"
    var PreviousPercent: Double = -1.0
    
    @IBSegueAction func InstantiateSettingsNavigator(_ coder: NSCoder) -> SettingsNavigationViewer?
    {
        let Controller = SettingsNavigationViewer(coder: coder)
        Controller?.Delegate = self
        return Controller
    }
    
    @IBOutlet weak var SettingsButton: UIButton!
    @IBOutlet weak var GridOverlay: UIView!
    @IBOutlet weak var SunView: UIImageView!
    @IBOutlet weak var MainTimeLabel: UILabel!
    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var WorldViewer: UIImageView!
}

