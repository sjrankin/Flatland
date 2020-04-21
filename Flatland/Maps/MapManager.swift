//
//  MapManager.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/19/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class MapManager
{
    private static let FlatMaps: [MapTypes: (String, String)] =
        [
            .Standard: ("WorldNorth", "WorldSouth"),
            .StandardSea: ("WordNorth", "WorldSouth"),
            .BlueMarble: ("BlueMarbleNorthCenter", "BlueMarbleSouthCenter"),
            .DarkBlueMarble: ("BlackMarbleNorthCenter2", "BlackMarbleSouthCenter2"),
            .Continents: ("SimpleMapContinentsNorthCenter", "SimpleMapContinentsSouthCenter"),
            .Dots: ("DotMapNorthCenter", "DotMapSouthCenter"),
            .Simple: ("SimpleNorthCenter", "SimpleSouthCenter"),
            .SimpleBorders1: ("SimpleMapWithBordersNorthCenter1", "SimpleMapWithBordersSouthCenter1"),
            .SimpleBorders2: ("SimpleMapWithBordersNorthCenter1", "SimpleMapWithBordersSouthCenter1"),
            .Extruded: ("ExtrudedNorthCenter", "ExtrudedSouthCenter"),
            .HalftoneDot: ("HalftoneDotNorthCenter", "HalftoneDotSouthCenter"),
            .HalftoneLine: ("HalftoneLineNorthCenter", "HalftoneLineSouthCenter"),
            .HalftoneVerticalLine: ("HalftoneVerticalLinesNorthCenter", "HalftoneVerticalLinesSouthCenter"),
            .Crosshatched: ("HatchedNorthCenter", "HatchedSouthCenter"),
            .Pink: ("PinkMapNorthCenter", "PinkMapSouthCenter"),
            .Cartoon: ("CartoonMapNorthCenter", "CartoonMapSouthCenter"),
            .Dithered: ("DitheredMapNorthCenter", "DitheredMapSouthCenter"),
            .SwirlyLines: ("ArtMap1NorthCenter", "ArtMap1SouthCenter"),
            .RoundSplotches: ("ArtMap2NorthCenter", "ArtMap2SouthCenter"),
            .Textured: ("TexturedEarthNorthCenter", "TexturedEarthSouthCenter"),
            .Bronze: ("BronzeMapNorthCenter", "BronzeMapSouthCenter"),
            .Abstract1: ("AbstractShapes1NorthCenter", "AbstractShapes1SouthCenter"),
            .Abstract2: ("Abstract2NorthCenter", "Abstract2SouthCenter"),
            .Dots2: ("DotWorldNorthCenter", "DotWorldSouthCenter"),
            .Dots3: ("DotWorld3NorthCenter", "DotWorld3SouthCenter"),
            .Surreal1: ("Surreal1NorthCenter", "Surreal1SouthCenter"),
            .WaterColor1: ("WaterColor2NorthCenter", "WaterColor2SouthCenter"),
            .WaterColor2: ("WaterColorPlanetNorthCenter", "WaterColorPlanetSouthCenter"),
            .OilPainting1: ("ArtMap4NorthCenter", "ArtMap4SouthCenter"),
            .Abstract3: ("SegmentedMapNorthCenter", "SegmentedMapSouthCenter"),
            .StaticAerosol: ("AerosolNorthCenter", "AerosolSouthCenter"),
            .Topographical1: ("Topographical1NorthCenter", "Topographical1SouthCenter"),
            .Topographical2: ("EarthTopoNorthCenter", "EarthTopoSouthCenter"),
            .PoliticalSubDivisions: ("PoliticalSubDivisionsNorthCenter", "PoliticalSubDivisionsSouthCenter"),
            .MarsViking: ("MarsVikingNorthCenter", "MarsVikingsouthCenter"),
            .MOLAVerticalRoughness: ("MarsVerticalRoughnessNorthCenter", "MarsVerticalRoughnessSouthCenter"),
            .MarsMariner9: ("MarsM9GeoMapNorthCenter", "MarsM9GeoMapSouthCenter"),
            .LROMap: ("LRONorthCenter", "LROSouthCenter"),
            .LunarGeoMap: ("LunarGeoMapNorthCenter", "LunarGeoMapSouthCenter"),
    ]
    
    private static func FlatMapImage(MapType: MapTypes, ImageCenter: ImageCenters) -> String?
    {
        if let (NorthImage, SouthImage) = FlatMaps[MapType]
        {
            if ImageCenter == .NorthPole
            {
                return NorthImage
            }
            else
            {
                return SouthImage
            }
        }
        return nil
    }
    
    private static func GlobeMapImage(MapType: MapTypes) -> String?
    {
        switch MapType
        {
            case .Standard:
                return "LandMask2"
            
            case .StandardSea:
                return "SeaMask2"
            
            case .BlueMarble:
                return "BlueMarble"
            
            case .DarkBlueMarble:
                return "BlackMarble2"
            
            case .Simple:
                return "SimpleMap1"
            
            case .SimpleBorders1:
                return "SimpleMapWithBorders1"
            
            case .SimpleBorders2:
                return "SimpleMapBorders"
            
            case .Continents:
                return "SimpleMapContinents"
            
            case .Dots:
                return "DotMap"
            
            case .Crosshatched:
                return "Style1"
            
            case .Textured:
                return "Style2"
            
            case .HalftoneLine:
                return "Style3"
            
            case .HalftoneVerticalLine:
                return "HalftoneVerticalLines"
            
            case .HalftoneDot:
                return "Style4"
            
            case .Extruded:
                return "Style5"
            
            case .Pink:
                return "PinkMap"
            
            case .Cartoon:
                return "CartoonMap"
            
            case .Dithered:
                return "DitheredMap"
            
            case .SwirlyLines:
                return "ArtMap1"
            
            case .RoundSplotches:
                return "ArtMap2"
            
            case .Bronze:
                return "BronzeMap"
            
            case .Abstract2:
                return "Abstract2"
            
            case .Abstract1:
                return "AbstractShapes1"
            
            case .Dots2:
                return "DotWorld"
            
            case .Dots3:
                return "DotWorld3"
            
            case .Surreal1:
                return "Surreal1"
            
            case .WaterColor1:
                return "WaterColor2"
            
            case .WaterColor2:
                return "WaterColorPlanet"
            
            case .OilPainting1:
                return "ArtMap4"
            
            case .Abstract3:
                return "SegmentedMap"
            
            case .StaticAerosol:
                return "aerosol"
            
            case .Topographical1:
                return "Topographical1"
            
            case .Topographical2:
                return "EarthTopo"
            
            case .PoliticalSubDivisions:
                return "PoliticalSubDivisions3600"
            
            case .MarsMariner9:
                return "MarsM9GeoMap"
            
            case .MarsViking:
                return "MarsViking"
            
            case .MOLAVerticalRoughness:
                return "MarsVerticalRoughness"
            
            case .LROMap:
                return "LROMoon"
            
            case .LunarGeoMap:
                return "LunarGeoMap"
        }
    }
    
    /// Returns the name of the image file for the specified map.
    /// - Parameter MapType: The map type to return. Some map types may not be supported in a given
    ///                      view - when that happens, a default value is returned.
    /// - Parameter ViewType: The type of view (globe or flat).
    /// - Parameter ImageCenter: The center of the image for flat maps types. Ignored for globe maps.
    /// - Returns: The name of the image. Nil on error.
    public static func ImageNameFor(MapType: MapTypes, ViewType: ViewTypes, ImageCenter: ImageCenters = .NorthPole) -> String?
    {
        switch ViewType
        {
            case .FlatMap:
                return FlatMapImage(MapType: MapType, ImageCenter: ImageCenter)
            
            case .Globe3D:
                return GlobeMapImage(MapType: MapType)
        }
    }
    
    public static let GlobeMapList: [MapTypes] =
        [
            .Standard,
            .Simple,
            .BlueMarble,
            .DarkBlueMarble,
            .Continents,
            .SimpleBorders1,
            .SimpleBorders2,
            .Dots
    ]
    
    public static let FlatMapList: [MapTypes] =
        [
            .Standard,
            .Simple,
            .BlueMarble,
            .DarkBlueMarble,
            .Continents,
            .SimpleBorders1,
            .Dots
    ]
}

/// Determines whether the north pole or the south pole is at the center of the world image.
enum ImageCenters: String, CaseIterable
{
    /// North pole is in the center.
    case NorthPole = "NorthPole"
    /// South pole is in the center.
    case SouthPole = "SouthPole"
}

enum MapTypes: String, CaseIterable
{
    case Standard = "Standard"
    case StandardSea = "StandardSea"
    case BlueMarble = "Blue Marble"
    case DarkBlueMarble = "Dark Blue Marble"
    case Simple = "Simple"
    case SimpleBorders1 = "Simple with Borders 1"
    case SimpleBorders2 = "Simple with Borders 2"
    case Continents = "Continents"
    case Dots = "Dotted Continents"
    case Dots2 = "Shadowed Dots Map"
    case Dots3 = "Ishihara Dots Map"
    case Crosshatched = "Crosshatched"
    case Textured = "Textured Paper"
    case HalftoneLine = "Halftone Lined"
    case HalftoneVerticalLine = "Halftone Vertical Lined"
    case HalftoneDot = "Halftone Dot"
    case Extruded = "Extruded"
    case Pink = "Glossy Pink"
    case Cartoon = "Cartoon Map"
    case Dithered = "Dithered"
    case SwirlyLines = "Swirly Lines"
    case RoundSplotches = "Round Splotches"
    case Bronze = "Bronze Map"
    case Abstract1 = "Abstract Map 1"
    case Abstract2 = "Abstract Map 2"
    case Abstract3 = "Abstract Map 3"
    case Surreal1 = "Surreal Map"
    case WaterColor1 = "Watercolor Map"
    case WaterColor2 = "Dark Watercolor Map"
    case OilPainting1 = "Oil Painting Map"
    case StaticAerosol = "Static Aerosol"
    case Topographical1 = "Topographic 1"
    case Topographical2 = "Topographic 2"
    case PoliticalSubDivisions = "Political Sub-Divisions"
    case MarsMariner9 = "Martian Mariner 9 Geologic Map"
    case MarsViking = "Martian Viking Map"
    case MOLAVerticalRoughness = "Mars Vertical Roughness Map"
    case LROMap = "Lunar Reconnaissance Orbiter Moon Map"
    case LunarGeoMap = "Lunar Geologic Map"
}
