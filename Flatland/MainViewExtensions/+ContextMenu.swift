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
    
    //MARK: - Physical sub-menu.
    
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
        let Menu4 = UIAction(title: "Topographical Map 1", image: nil)
        {
            action in
            self.SetTexture(.Topographical1)
        }
        SubMenu.append(Menu4)
        let Menu5 = UIAction(title: "Topographical Map 2", image: nil)
        {
            action in
            self.SetTexture(.Topographical2)
        }
        SubMenu.append(Menu5)
        let Menu7 = UIAction(title: "Surreal Topographical Map", image: nil)
        {
            action in
            self.SetTexture(.SurrealTopographic)
        }
        SubMenu.append(Menu7)
        let Menu8 = UIAction(title: "Tectonic Plate Map", image: nil)
        {
            action in
            self.SetTexture(.OnlyTectonic)
        }
        SubMenu.append(Menu8)
        let Menu9 = UIAction(title: "Tectonic Overlay", image: nil)
        {
            action in
            self.SetTexture(.TectonicOverlay)
        }
        SubMenu.append(Menu9)
        let Menu3 = UIAction(title: "Static Aerosol Map", image: nil)
        {
            action in
            self.SetTexture(.StaticAerosol)
        }
        SubMenu.append(Menu3)
        let Menu6 = UIAction(title: "Normalized Tile Map", image: nil)
        {
            action in
            self.SetTexture(.Normalized)
        }
        SubMenu.append(Menu6)
        
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
    
    //MARK: - Standard sub-menu.
    
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
    
    // MARK: - Stylized dithered sub-menu.
    
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
    
    // MARK: - Stylized artistic sub-menu.
    
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
        let Menu15 = UIAction(title: "Color Ink Map", image: nil)
        {
            action in
            self.SetTexture(.ColorInk)
        }
        SubMenu.append(Menu15)
        let Menu14 = UIAction(title: "Andy Warhol Map", image: nil)
        {
            action in
            self.SetTexture(.Warhol)
        }
        SubMenu.append(Menu14)
        let Menu20 = UIAction(title: "Ukiyoe Map 1", image: nil)
        {
            action in
            self.SetTexture(.Ukiyoe1)
        }
        SubMenu.append(Menu20)
        let Menu32 = UIAction(title: "ASCII Art Map", image: nil)
        {
            action in
            self.SetTexture(.ASCIIArt1)
        }
        SubMenu.append(Menu32)

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
    
    // MARK: - Stylized color sub-menu.
    
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
        let Menu11 = UIAction(title: "Blueprint Map", image: nil)
        {
            action in
            self.SetTexture(.Blueprint)
        }
                SubMenu.append(Menu11)
        let Menu13 = UIAction(title: "Black and White Map", image: nil)
        {
            action in
            self.SetTexture(.BlackWhite)
        }
        SubMenu.append(Menu13)
        let Menu15 = UIAction(title: "Black and White Map (shiny)", image: nil)
        {
            action in
            self.SetTexture(.BlackWhiteShiny)
        }
        SubMenu.append(Menu15)
        let Menu14 = UIAction(title: "White and Black Map", image: nil)
        {
            action in
            self.SetTexture(.WhiteBlack)
        }
        SubMenu.append(Menu14)
        let Menu12 = UIAction(title: "Red Spot Color Map", image: nil)
        {
            action in
            self.SetTexture(.SpotColor)
        }
        SubMenu.append(Menu12)
        let Menu19 = UIAction(title: "Color Levels World", image: nil)
        {
            action in
            self.SetTexture(.LevelWorld)
        }
        SubMenu.append(Menu19)
        
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
    
    // MARK: - Stylized abstract sub-menu.
    
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
        let Menu30 = UIAction(title: "Paper Map", image: nil)
        {
            action in
            self.SetTexture(.PaperWorld)
        }
        SubMenu.append(Menu30)
        let Menu31 = UIAction(title: "Map with Squares", image: nil)
        {
            action in
            self.SetTexture(.SquareWorld)
        }
        SubMenu.append(Menu31)
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
        let Menu16 = UIAction(title: "Skeleton Map", image: nil)
        {
            action in
            self.SetTexture(.Skeleton)
        }
        SubMenu.append(Menu16)
        let Menu22 = UIAction(title: "Glowing Coasts", image: nil)
        {
            action in
            self.SetTexture(.GlowingCoasts)
        }
        SubMenu.append(Menu22)
        let Menu17 = UIAction(title: "Voronoi Map", image: nil)
        {
            action in
            self.SetTexture(.Voronoi)
        }
        SubMenu.append(Menu17)
        let Menu18 = UIAction(title: "Polygonized Map", image: nil)
        {
            action in
            self.SetTexture(.Polygons)
        }
        SubMenu.append(Menu18)
        let Menu12 = UIAction(title: "Extruded Map", image: nil)
        {
            action in
            self.SetTexture(.Extruded)
        }
        SubMenu.append(Menu12)
        let Menu19 = UIAction(title: "Bubble Map", image: nil)
        {
            action in
            self.SetTexture(.BubbleWorld)
        }
        SubMenu.append(Menu19)
        let Menu20 = UIAction(title: "Glowing Coasts", image: nil)
        {
            action in
            self.SetTexture(.GlowingCoasts)
        }
        SubMenu.append(Menu20)
        let Menu21 = UIAction(title: "Stained Glass Map", image: nil)
        {
            action in
            self.SetTexture(.StainedGlass)
        }
        SubMenu.append(Menu21)
        
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
    
    // MARK: - Stylized sub-menu.
    
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
    
    // MARK: - Political sub-menu.
    
    func MakePoliticalSubMenu() -> UIMenu
    {
        var SubMenu = [UIMenuElement]()
        let Menu1 = UIAction(title: "Political Sub-Divisions", image: nil)
        {
            action in
            self.SetTexture(.PoliticalSubDivisions)
        }
        SubMenu.append(Menu1)
        
        let CancelAction = UIAction(title: "Cancel", image: UIImage(systemName: "xmark.circle"))
        {
            action in
        }
        let CancelMenu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [CancelAction])
        SubMenu.append(CancelMenu)
        let Final = UIMenu(title: "Political Maps",
                           image: UIImage(systemName: "arrowtriangle.right"),
                           children: SubMenu)
        return Final
    }
    
    // MARK: - Extraterrestrial sub-menu.
    
    func MakeExtraterrestrialMenu() -> UIMenu
    {
        var SubMenu = [UIMenuElement]()
        let Menu1 = UIAction(title: "Viking Mars Map", image: nil)
        {
            action in
            self.SetTexture(.MarsViking)
        }
        SubMenu.append(Menu1)
        let Menu2 = UIAction(title: "Mariner 9 Mars Geologic Map", image: nil)
        {
            action in
            self.SetTexture(.MarsMariner9)
        }
        SubMenu.append(Menu2)
        let Menu3 = UIAction(title: "MOLA Martian Vertical Roughness Map", image: nil)
        {
            action in
            self.SetTexture(.MOLAVerticalRoughness)
        }
        SubMenu.append(Menu3)
        let Menu4 = UIAction(title: "Lunar Reconnaissance Orbiter Map", image: nil)
        {
            action in
            self.SetTexture(.LROMap)
        }
        SubMenu.append(Menu4)
        let Menu5 = UIAction(title: "Lunar Geologic Map", image: nil)
        {
            action in
            self.SetTexture(.LunarGeoMap)
        }
        SubMenu.append(Menu5)
        let Menu9 = UIAction(title: "Jupiter", image: nil)
        {
            action in
            self.SetTexture(.Jupiter)
        }
        SubMenu.append(Menu9)
        let Menu6 = UIAction(title: "Gaia Sky Map", image: nil)
        {
            action in
            self.SetTexture(.GaiaSky)
        }
        SubMenu.append(Menu6)
        let Menu7 = UIAction(title: "Tycho Sky Map", image: nil)
        {
            action in
            self.SetTexture(.TychoSky)
        }
        SubMenu.append(Menu7)
        let Menu8 = UIAction(title: "Inverted Sky Map", image: nil)
        {
            action in
            self.SetTexture(.NASAStarsInverted)
        }
        SubMenu.append(Menu8)
        
        let CancelAction = UIAction(title: "Cancel", image: UIImage(systemName: "xmark.circle"))
        {
            action in
        }
        let CancelMenu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [CancelAction])
        SubMenu.append(CancelMenu)
        let Final = UIMenu(title: "Extraterrestial Maps",
                           image: UIImage(systemName: "arrowtriangle.right"),
                           children: SubMenu)
        return Final
    }
    
    // MARK: - Silly sub-menu.
    
    func MakeSillySubMenu() -> UIMenu
    {
        var SubMenu = [UIMenuElement]()
        let Menu1 = UIAction(title: "House", image: nil)
        {
            action in
            self.SetTexture(.House)
        }
        SubMenu.append(Menu1)
        let Menu2 = UIAction(title: "Tigger", image: nil)
        {
            action in
            self.SetTexture(.Tigger)
        }
        SubMenu.append(Menu2)
        
        let CancelAction = UIAction(title: "Cancel", image: UIImage(systemName: "xmark.circle"))
        {
            action in
        }
        let CancelMenu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [CancelAction])
        SubMenu.append(CancelMenu)
        let Final = UIMenu(title: "Silly \"Maps\"",
                           image: UIImage(systemName: "arrowtriangle.right"),
                           children: SubMenu)
        return Final
    }
    
    // MARK: - Main context menu.
    
    func MakeGeneralContextMenu() -> UIMenu
    {
        let PhysicalMenu = MakePhysicalSubMenu()
        let StandardMenu = MakeStandardSubMenu()
        let PoliticalMenu = MakePoliticalSubMenu()
        let StylizedMenu = MakeStylizedSubMenu()
        let AstronomyMenu = MakeExtraterrestrialMenu()
        let SillyMenu = MakeSillySubMenu()
        let CancelAction = UIAction(title: "Cancel", image: UIImage(systemName: "xmark.circle"))
        {
            action in
        }
        let CancelMenu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [CancelAction])
        let Menu = UIMenu(title: "Map Menu",
                          children: [StandardMenu, PhysicalMenu, PoliticalMenu, StylizedMenu, AstronomyMenu, SillyMenu, CancelMenu])
        return Menu
    }
}
