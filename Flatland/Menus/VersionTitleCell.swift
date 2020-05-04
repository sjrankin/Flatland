//
//  VersionTitleCell.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class VersionTitleCell: UITableViewCell
{
    static let Height: CGFloat = 44.0
    
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
        TextField = UILabel(frame: CGRect(x: 10, y: 5, width: 100, height: 39))
        TextField?.font = UIFont.boldSystemFont(ofSize: 24)
        self.contentView.addSubview(TextField!)
    }
    
    var TextField: UILabel? = nil
    
    public func LoadData(Title: String, TableWidth: CGFloat)
    {
        self.frame = CGRect(x: self.frame.origin.x,
                             y: self.frame.origin.y,
                             width: TableWidth,
                             height: VersionTitleCell.Height)
        let FinalRect = CGRect(x: TextField!.frame.origin.x,
                               y: TextField!.frame.origin.y,
                               width: TableWidth - ((TextField?.bounds.origin.x)! - 10),
                               height: (TextField?.frame.size.height)!)
        TextField?.frame = FinalRect
        TextField?.text = Title
        self.selectionStyle = .none
    }
}
