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
            .House: ("HouseUpCenter", "HouseDownCenter"),
            .Tigger: ("TiggerWorldR0", "TiggerWorldroundR1"),
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
    
    private static func GlobeMapImage(MapType: MapTypes) -> UIImage?
    {
        if IsExternalMap(MapType)
        {
            if let (GlobeImage, _, _) = ExternalMapNames[MapType]
            {
                let Image = FileIO.ImageFromFile(WithName: GlobeImage)
                return Image
            }
            else
            {
                return nil
            }
        }
        var ImageName = ""
        switch MapType
        {
            case .Standard:
                ImageName = "LandMask2"
            
            case .StandardSea:
                ImageName = "SeaMask2"
            
            case .BlueMarble:
                ImageName = "BlueMarble"
            
            case .DarkBlueMarble:
                ImageName = "BlackMarble2"
            
            case .Simple:
                ImageName = "SimpleMap1"
            
            case .SimpleBorders1:
                ImageName = "SimpleMapWithBorders1"
            
            case .SimpleBorders2:
                ImageName = "SimpleMapBorders"
            
            case .Continents:
                ImageName = "SimpleMapContinents"
            
            case .Dots:
                ImageName = "DotMap"
            
            case .Crosshatched:
                ImageName = "Style1"
            
            case .Textured:
                ImageName = "Style2"
            
            case .HalftoneLine:
                ImageName = "Style3"
            
            case .HalftoneVerticalLine:
                ImageName = "HalftoneVerticalLines"
            
            case .HalftoneDot:
                ImageName = "Style4"
            
            case .Extruded:
                ImageName = "Style5"
            
            case .Pink:
                ImageName = "PinkMap"
            
            case .Cartoon:
                ImageName = "CartoonMap"
            
            case .Dithered:
                ImageName = "DitheredMap"
            
            case .SwirlyLines:
                ImageName = "ArtMap1"
            
            case .RoundSplotches:
                ImageName = "ArtMap2"
            
            case .Bronze:
                ImageName = "BronzeMap"
            
            case .Abstract2:
                ImageName = "Abstract2"
            
            case .Abstract1:
                ImageName = "AbstractShapes1"
            
            case .Dots2:
                ImageName = "DotWorld"
            
            case .Dots3:
                ImageName = "DotWorld3"
            
            case .Surreal1:
                ImageName = "Surreal1"
            
            case .WaterColor1:
                ImageName = "WaterColor2"
            
            case .WaterColor2:
                ImageName = "WaterColorPlanet"
            
            case .OilPainting1:
                ImageName = "ArtMap4"
            
            case .Abstract3:
                ImageName = "SegmentedMap"
            
            case .StaticAerosol:
                ImageName = "aerosol"
            
            case .Topographical1:
                ImageName = "Topographical1"
            
            case .Topographical2:
                ImageName = "EarthTopo"
            
            case .PoliticalSubDivisions:
                ImageName = "PoliticalSubDivisions3600"
            
            case .MarsMariner9:
                ImageName = "MarsM9GeoMap"
            
            case .MarsViking:
                ImageName = "MarsViking"
            
            case .MOLAVerticalRoughness:
                ImageName = "MarsVerticalRoughness"
            
            case .LROMap:
                ImageName = "LROMoon"
            
            case .LunarGeoMap:
                ImageName = "LunarGeoMap"
            
            case .House:
                ImageName = "House"
            
            case .Tigger:
                ImageName = "TiggerWorld"
            
            default:
                return nil
        }
        return UIImage(named: ImageName)
    }
    
    public static func GetFlatMapImage(MapType: MapTypes, ImageCenter: ImageCenters) -> UIImage?
    {
        if IsExternalMap(MapType)
        {
            if let (_, North, South) = ExternalMapNames[MapType]
            {
                let MapToReturn = ImageCenter == .NorthPole ? North : South
                return FileIO.ImageFromFile(WithName: MapToReturn)
            }
        }
        else
        {
            if let (North, South) = FlatMaps[MapType]
            {
                switch ImageCenter
                {
                    case .NorthPole:
                        return UIImage(named: North)
                    
                    case .SouthPole:
                        return UIImage(named: South)
                }
            }
        }
        return nil
    }
    
    /// Return an image for the specified map and map type.
    /// - Parameter MapType: The general map type. See `MapTypes` for more information.
    /// - Parameter ViewType: The type of view for the map (flat or 3D).
    /// - Parameter ImageCenter: Valid only if `ViewType` is `.FlatMap`. Determines the pole at the
    ///                          center of the map.
    /// - Returns: Image of the specified map on success, nil on error.
    public static func ImageFor(MapType: MapTypes, ViewType: ViewTypes, ImageCenter: ImageCenters = .NorthPole) -> UIImage?
    {
        switch ViewType
        {
            case .FlatMap:
                return GetFlatMapImage(MapType: MapType, ImageCenter: ImageCenter)
            
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
    
    public static func IsExternalMap(_ MapType: MapTypes) -> Bool
    {
        return ExternalMapNames[MapType] != nil
    }
    
    public static let ExternalMapNames: [MapTypes: (String, String, String)] =
        [
            .Normalized: ("WorldNormalizedTiles.png", "WorldNormalizedTilesNorthCenter.png", "WorldNormalizedTilesSouthCenter.png"),
            .Blueprint: ("WorldBluePrint.png", "WorldBluePrintNorthCenter.png", "WorldBluePrintSouthCenter.png"),
            .Skeleton: ("WorldSkeleton.png", "WorldSkeletonNorthCenter.png", "WorldSkeletonSouthCenter.png"),
            .Polygons: ("WorldPolygonize.png", "WorldPolygonizeNorthCenter.png", "WorldPolygonizeSouthCenter.png"),
            .ColorInk: ("WorldInkColor.png", "WorldInkColorNorthCenter.png", "WorldInkColorSouthCenter.png"),
            .Warhol: ("WorldWarhol.png", "WorldWarholNorthCenter.png", "WorldWarholSouthCenter.png"),
            .Voronoi: ("WorldVoronoi.png", "WorldVoronoiNorthCenter.png", "WorldVoronoiSouthCenter.png"),
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
    case House = "Kitahiroshima House"
    case Tigger = "Tigger"
    case Normalized = "Normalized Blocks"
    case Blueprint = "Blueprint-style Map"
    case Skeleton = "Skeleton Map"
    case Polygons = "Polygonized Map"
    case ColorInk = "Color Ink Map"
    case Warhol = "Worhol Style Map"
    case Voronoi = "Voronoi Style Map"
}
