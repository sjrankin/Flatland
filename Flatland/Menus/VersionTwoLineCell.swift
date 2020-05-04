//
//  VersionTwoLineCell.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
//
//  VersionTitleCell.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class VersionTwoLineCell: UITableViewCell
{
    static let Height: CGFloat = 80.0
    
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
        TitleField = UILabel(frame: CGRect(x: 10, y: 5, width: 100, height: 39))
        TitleField?.font = UIFont.systemFont(ofSize: 20)
        self.contentView.addSubview(TitleField!)
        TextField = UILabel(frame: CGRect(x: 10, y: 52, width: 100, height: 26))
        TextField?.font = UIFont.systemFont(ofSize: 12.0)
        self.contentView.addSubview(TextField!)
    }
    
    var TitleField: UILabel? = nil
    var TextField: UILabel? = nil
    
    func LoadData(Title: String, Text: String, TableWidth: CGFloat, TextFontSize: CGFloat? = nil)
    {
        self.bounds = CGRect(x: self.frame.origin.x,
                             y: self.frame.origin.y,
                             width: TableWidth,
                             height: VersionTwoLineCell.Height)
        let FinalTRect = CGRect(x: TitleField!.frame.origin.x,
                                y: TitleField!.frame.origin.y,
                                width: TableWidth - ((TitleField?.frame.origin.x)! - 10),
                                height: (TitleField?.frame.size.height)!)
        TitleField?.frame = FinalTRect
        TitleField?.text = Title
        let FinalXRect = CGRect(x: TextField!.frame.origin.x,
                               y: TextField!.frame.origin.y,
                               width: TableWidth - ((TextField?.frame.origin.x)! - 10),
                               height: (TextField?.frame.size.height)!)
        TextField?.frame = FinalXRect
        TextField?.text = Text
        if let FontSize = TextFontSize
        {
            TextField?.font = UIFont.systemFont(ofSize: FontSize)
        }
        self.selectionStyle = .none
    }
}
