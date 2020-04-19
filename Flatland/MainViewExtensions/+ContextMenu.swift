//
//  +ContextMenu.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension MainView: UIContextMenuInteractionDelegate
{
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration?
    {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil)
        {
            suggestedActions in
            return self.MakeGeneralContextMenu()
        }
    }
    
    func MakePhysicalSubMenu() -> UIMenu
    {
        var SubMenu = [UIMenuElement]()
        let Menu1 = UIAction(title: "Blue Marble", image: nil)
        {
            action in
            self.SetTexture(.BlueMarble)
        }
        SubMenu.append(Menu1)
        let Menu2 = UIAction(title: "Black Marble", image: nil)
        {
            action in
            self.SetTexture(.DarkBlueMarble)
        }
        SubMenu.append(Menu2)
        let CancelAction = UIAction(title: "Cancel", image: UIImage(systemName: "xmark.circle"))
        {
            action in
        }
        let CancelMenu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [CancelAction])
        SubMenu.append(CancelMenu)
        let Final = UIMenu(title: "Physical Maps",
                           image: UIImage(systemName: "arrowtriangle.right"),
                           children: SubMenu)
        return Final
    }
    
    func MakeStandardSubMenu() -> UIMenu
    {
        var SubMenu = [UIMenuElement]()
        let Menu1 = UIAction(title: "Standard Map", image: nil)
        {
            action in
            self.SetTexture(.Standard)
        }
        SubMenu.append(Menu1)
        let Menu2 = UIAction(title: "Simple Map", image: nil)
        {
            action in
            self.SetTexture(.Simple)
        }
        SubMenu.append(Menu2)
        let Menu3 = UIAction(title: "Simple Map with Borders 1", image: nil)
        {
            action in
            self.SetTexture(.SimpleBorders1)
        }
        SubMenu.append(Menu3)
        let Menu4 = UIAction(title: "Simple Map with Borders 2", image: nil)
        {
            action in
            self.SetTexture(.SimpleBorders2)
        }
        SubMenu.append(Menu4)
        let Menu5 = UIAction(title: "Simple Map with Continents", image: nil)
        {
            action in
            self.SetTexture(.Continents)
        }
        SubMenu.append(Menu5)
        let CancelAction = UIAction(title: "Cancel", image: UIImage(systemName: "xmark.circle"))
        {
            action in
        }
        let CancelMenu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [CancelAction])
        SubMenu.append(CancelMenu)
        let Final = UIMenu(title: "Standard Maps",
                           image: UIImage(systemName: "arrowtriangle.right"),
                           children: SubMenu)
        return Final
    }
    
    func MakeStylizedDitheredMenu() -> UIMenu
    {        var SubMenu = [UIMenuElement]()
        let Menu4 = UIAction(title: "Halftone Line Map", image: nil)
        {
            action in
            self.SetTexture(.HalftoneLine)
        }
        SubMenu.append(Menu4)
        let Menu5 = UIAction(title: "Halftone Vertical Line Map", image: nil)
        {
            action in
            self.SetTexture(.HalftoneVerticalLine)
        }
        SubMenu.append(Menu5)
        let Menu6 = UIAction(title: "Halftone Dot Map", image: nil)
        {
            action in
            self.SetTexture(.HalftoneDot)
        }
        SubMenu.append(Menu6)
        let Menu7 = UIAction(title: "Dithered Map", image: nil)
        {
            action in
            self.SetTexture(.Dithered)
        }
        SubMenu.append(Menu7)
        let CancelAction = UIAction(title: "Cancel", image: UIImage(systemName: "xmark.circle"))
        {
            action in
        }
        let CancelMenu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [CancelAction])
        SubMenu.append(CancelMenu)
        let Final = UIMenu(title: "Dithered/Halftone Maps",
                           image: UIImage(systemName: "arrowtriangle.right"),
                           children: SubMenu)
        return Final
    }
    
    func MakeStylizedArtisticMenu() -> UIMenu
    {
                var SubMenu = [UIMenuElement]()
        let Menu1 = UIAction(title: "Oil Painting Map", image: nil)
        {
            action in
            self.SetTexture(.OilPainting1)
        }
        SubMenu.append(Menu1)
        let Menu12 = UIAction(title: "Watercolor Map", image: nil)
        {
            action in
            self.SetTexture(.WaterColor1)
        }
        SubMenu.append(Menu12)
        let Menu13 = UIAction(title: "Dark Watercolor Map", image: nil)
        {
            action in
            self.SetTexture(.WaterColor2)
        }
        SubMenu.append(Menu13)
        let Menu8 = UIAction(title: "Cartoon Map", image: nil)
        {
            action in
            self.SetTexture(.Cartoon)
        }
        SubMenu.append(Menu8)
        
        let Menu10 = UIAction(title: "Swirly Lined Map", image: nil)
        {
            action in
            self.SetTexture(.SwirlyLines)
        }
        SubMenu.append(Menu10)
        let Menu11 = UIAction(title: "Splotchy Map", image: nil)
        {
            action in
            self.SetTexture(.RoundSplotches)
        }
        SubMenu.append(Menu11)

        let CancelAction = UIAction(title: "Cancel", image: UIImage(systemName: "xmark.circle"))
        {
            action in
        }
        let CancelMenu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [CancelAction])
        SubMenu.append(CancelMenu)
        let Final = UIMenu(title: "Artistic Maps",
                           image: UIImage(systemName: "arrowtriangle.right"),
                           children: SubMenu)
        return Final
    }
    
    func MakeStylizedColorfulMenu() -> UIMenu
    {
                var SubMenu = [UIMenuElement]()
        let Menu9 = UIAction(title: "Glossy Pink Map", image: nil)
        {
            action in
            self.SetTexture(.Pink)
        }
        SubMenu.append(Menu9)
        let Menu10 = UIAction(title: "Bronze Map", image: nil)
        {
            action in
            self.SetTexture(.Bronze)
        }
        SubMenu.append(Menu10)
        let CancelAction = UIAction(title: "Cancel", image: UIImage(systemName: "xmark.circle"))
        {
            action in
        }
        let CancelMenu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [CancelAction])
        SubMenu.append(CancelMenu)
        let Final = UIMenu(title: "Colorful Maps",
                           image: UIImage(systemName: "arrowtriangle.right"),
                           children: SubMenu)
        return Final
    }
    
    func MakeStylizedAbstractMenu() -> UIMenu
    {
        var SubMenu = [UIMenuElement]()
        let Menu1 = UIAction(title: "Dotted Map", image: nil)
        {
            action in
            self.SetTexture(.Dots)
        }
        SubMenu.append(Menu1)
        let Menu2 = UIAction(title: "Crosshatched Map", image: nil)
        {
            action in
            self.SetTexture(.Crosshatched)
        }
        SubMenu.append(Menu2)
        let Menu3 = UIAction(title: "Textured Paper Map", image: nil)
        {
            action in
            self.SetTexture(.Textured)
        }
        SubMenu.append(Menu3)
        let Menu13 = UIAction(title: "Abstract Map 1", image: nil)
        {
            action in
            self.SetTexture(.Abstract1)
        }
        SubMenu.append(Menu13)
        let Menu14 = UIAction(title: "Abstract Map 2", image: nil)
        {
            action in
            self.SetTexture(.Abstract2)
        }
        SubMenu.append(Menu14)
        let Menu4 = UIAction(title: "Abstract Map 3", image: nil)
        {
            action in
            self.SetTexture(.Abstract3)
        }
        SubMenu.append(Menu4)
        let Menu15 = UIAction(title: "Surreal Map", image: nil)
        {
            action in
            self.SetTexture(.Surreal1)
        }
        SubMenu.append(Menu15)
        let Menu12 = UIAction(title: "Extruded Map", image: nil)
        {
            action in
            self.SetTexture(.Extruded)
        }
        SubMenu.append(Menu12)
        
        let CancelAction = UIAction(title: "Cancel", image: UIImage(systemName: "xmark.circle"))
        {
            action in
        }
        let CancelMenu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [CancelAction])
        SubMenu.append(CancelMenu)
        let Final = UIMenu(title: "Abstract Maps",
                           image: UIImage(systemName: "arrowtriangle.right"),
                           children: SubMenu)
        return Final
    }
    
    func MakeStylizedSubMenu() -> UIMenu
    {
        var SubMenu = [UIMenuElement]()

        SubMenu.append(MakeStylizedArtisticMenu())
        SubMenu.append(MakeStylizedColorfulMenu())
        SubMenu.append(MakeStylizedAbstractMenu())
        SubMenu.append(MakeStylizedDitheredMenu())

        let CancelAction = UIAction(title: "Cancel", image: UIImage(systemName: "xmark.circle"))
        {
            action in
        }
        let CancelMenu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [CancelAction])
        SubMenu.append(CancelMenu)
        let Final = UIMenu(title: "Stylized Maps",
                           image: UIImage(systemName: "arrowtriangle.right"),
                           children: SubMenu)
        return Final
    }
    
    func MakeGeneralContextMenu() -> UIMenu
    {
        let PhysicalMenu = MakePhysicalSubMenu()
        let StandardMenu = MakeStandardSubMenu()
        let StylizedMenu = MakeStylizedSubMenu()
        let CancelAction = UIAction(title: "Cancel", image: UIImage(systemName: "xmark.circle"))
        {
            action in
        }
        let CancelMenu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [CancelAction])
        let Menu = UIMenu(title: "Map Menu",
                          children: [StandardMenu, PhysicalMenu, StylizedMenu, CancelMenu])
        return Menu
    }
}
