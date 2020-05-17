//
//  CityColorCell.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/17/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class CityColorCell: UITableViewCell
{
    static let Height: CGFloat = 45.0
    
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
        ColorName = UILabel(frame: CGRect(x: 5, y: 5, width: 200, height: 35))
        self.contentView.addSubview(ColorName)
        ColorSwatch = UIView(frame: CGRect(x: 210, y: 5, width: 50, height: 35))
        ColorSwatch.layer.borderColor = UIColor.black.cgColor
        ColorSwatch.layer.borderWidth = 0.5
        ColorSwatch.layer.cornerRadius = 5.0
        self.contentView.addSubview(ColorSwatch)
    }
    
    var ColorName = UILabel()
    var ColorSwatch = UIView()
    
    func SetColor(Name: String, Color: UIColor)
    {
        ColorName.text = Name
        ColorSwatch.backgroundColor = Color
    }
}
