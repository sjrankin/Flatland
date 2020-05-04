//
//  VersioningMenu.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class VersioningMenu: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        VersionTable.layer.borderColor = UIColor.black.cgColor
        VersionTable.reloadData()
        VList.append(Versioning.ApplicationName)
        VList.append(Versioning.MakeVersionString(IncludeVersionSuffix: true))
        VList.append(Versioning.MakeBuildString())
        VList.append("Build ID\n" + Versioning.BuildID.lowercased())
        VList.append(Versioning.CopyrightText())
        VList.append("Program ID\n" + Versioning.ProgramID.lowercased())
        VList.append(Versioning.Tag)
    }
    
    var VList = [String]()
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        switch indexPath.row
        {
            case 0:
                return VersionTitleCell.Height
            
            case 1, 6:
                return VersionTableCell.Height
            
            default:
                return VersionTwoLineCell.Height
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Width = tableView.bounds.size.width
        switch Int(indexPath.row)
        {
            case 0:
                let Cell = VersionTitleCell(style: .default, reuseIdentifier: "Title")
                Cell.LoadData(Title: Versioning.ApplicationName, TableWidth: Width)
                return Cell
            
            case 1:
                let Cell = VersionTableCell(style: .default, reuseIdentifier: "SomeCell")
                Cell.LoadData(Title: Versioning.MakeVersionString(IncludeVersionSuffix: true), TableWidth: Width)
                return Cell
            
            case 2:
                let Cell = VersionTwoLineCell(style: .default, reuseIdentifier: "TwoItems")
                let BuildData = "\(Versioning.Build), \(Versioning.BuildDate) \(Versioning.BuildTime)"
                Cell.LoadData(Title: "Build", Text: BuildData, TableWidth: Width, TextFontSize: 16.0)
                return Cell
            
            case 3:
                let Cell = VersionTwoLineCell(style: .default, reuseIdentifier: "TwoItems")
                Cell.LoadData(Title: "Build ID", Text: Versioning.BuildID.lowercased(), TableWidth: Width)
                return Cell
            
            case 4:
                let Cell = VersionTwoLineCell(style: .default, reuseIdentifier: "TwoItems")
                let CopyYears = Versioning.FormattedCopyrightYears()
                let CopyHolder = Versioning.CopyrightHolder
                Cell.LoadData(Title: "Copyright ©", Text: "\(CopyYears) \(CopyHolder)", TableWidth: Width,
                              TextFontSize: 16.0)
                return Cell
            
            case 5:
                let Cell = VersionTwoLineCell(style: .default, reuseIdentifier: "TwoItems")
                Cell.LoadData(Title: "Program ID", Text: Versioning.ProgramID.lowercased(), TableWidth: Width)
                return Cell
            
            case 6:
                let Cell = VersionTableCell(style: .default, reuseIdentifier: "SomeCell")
                Cell.LoadData(Title: Versioning.Tag, TableWidth: Width)
                return Cell
            
            default:
                return UITableViewCell()
        }
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var VersionTable: UITableView!
}
