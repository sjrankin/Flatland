//
//  LocationCell2.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class LocationCell2: UITableViewCell
{
    public static let CellHeight: CGFloat = 80.0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        InitializeUI()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        InitializeUI()
    }
    
    func InitializeUI()
    {
        Name = UILabel(frame: CGRect(x: 10, y: 2, width: 220, height: 30))
        Name?.font = UIFont.boldSystemFont(ofSize: 20.0)
        self.contentView.addSubview(Name!)
        Where = UILabel(frame: CGRect(x: 10, y: 42, width: 300, height: 30))
        Where?.font = UIFont.monospacedSystemFont(ofSize: 16.0,
                                                  weight: UIFont.Weight.medium)
        self.contentView.addSubview(Where!)
        ColorSwatch = UIView(frame: CGRect(x: 240, y: 5, width: 60, height: 30))
        ColorSwatch?.layer.borderColor = UIColor.black.cgColor
        ColorSwatch?.layer.borderWidth = 0.5
        ColorSwatch?.layer.cornerRadius = 5.0
        self.contentView.addSubview(ColorSwatch!)
    }
    
    var ColorSwatch: UIView? = nil
    var Name: UILabel? = nil
    var Where: UILabel? = nil
    
    func SetData(Name: String, Location: GeoPoint2, Color: UIColor, TableWidth: CGFloat)
    {
        self.Name?.text = Name
        let EW = Location.Longitude < 0.0 ? "W" : "E"
        let NS = Location.Latitude < 0.0 ? "S" : "N"
        self.Where?.text = "\(Location.Latitude.RoundedTo(4))° \(NS), \(Location.Longitude.RoundedTo(4))° \(EW)"
        ColorSwatch?.backgroundColor = Color
    }
}
