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

class MainView: UIViewController, CAAnimationDelegate
{
    let OriginalOrientation: Double = 180.0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitializeGrid()
        TopView.backgroundColor = UIColor.black
        StartTimeLabel()
    }
    
    func InitializeGrid()
    {
        GridOverlay.backgroundColor = UIColor.clear
        let Grid = CAShapeLayer()
        Grid.bounds = GridOverlay.frame//GridOverlay.bounds
        Grid.frame = GridOverlay.frame
        let Lines = UIBezierPath()
        let CenterH = Grid.bounds.size.width / 2.0
        let CenterV = Grid.bounds.size.height / 2.0
        Lines.move(to: CGPoint(x: CenterH, y: 0))
        Lines.addLine(to: CGPoint(x: CenterH, y: Grid.frame.size.height))
        Lines.move(to: CGPoint(x: 0, y: CenterV))
        Lines.addLine(to: CGPoint(x: Grid.frame.size.width, y: CenterV))
        let Equator = UIBezierPath(ovalIn: CGRect(x: CenterH / 2,
                                                  y: CenterV / 2,
                                                  width: CenterH,
        height: CenterV))
        Lines.append(Equator)
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
        print("Rotating image to \(Percent)%")
        PreviousPercent = Percent
        let Degrees = 360.0 * Percent - OriginalOrientation
        let Radians = Degrees * Double.pi / 180.0
        #if true
        let Rotation = CATransform3DMakeRotation(CGFloat(-Radians), 0.0, 0.0, 1.0)
        WorldViewer.layer.transform = Rotation
        #else
//        WorldViewer.transform = WorldViewer.transform.rotated(by: CGFloat(Radians))
//        WorldViewer.transform = CGAffineTransform(rotationAngle: CGFloat(Radians))
        
        let Rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        Rotation.delegate = self
        //Rotation.fromValue = NSNumber(floatLiteral: 0.0)
        Rotation.toValue = NSNumber(floatLiteral: -Radians)
        Rotation.duration = 0.75
        Rotation.repeatCount = 0
        Rotation.isAdditive = true
        WorldViewer.layer.add(Rotation, forKey: "RotateMe")
        #endif
    }
    
    var PreviousPercent: Double = -1.0

    @IBOutlet weak var GridOverlay: UIView!
    @IBOutlet weak var SunView: UIImageView!
    @IBOutlet weak var MainTimeLabel: UILabel!
    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var WorldViewer: UIImageView!
}

