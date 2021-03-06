//
//  MapListMapItem(.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/27/20MapItem(.
//  Copyright © 2020 Stuart RankinMapItem(. All rights reservedMapItem(.
//

import Foundation
import UIKit

/// Maintains a list of maps for the program.
class MapList
{
    /// Return a map item for the specified map type.
    /// - Parameter For: The map type whose map item will be returned.
    /// - Returns: A map item for the specified map type. Nil if not found.
    public static func Map(For: MapTypes) -> MapItem?
    {
        for SomeMap in Maps
        {
            if SomeMap.MapType == For
            {
                return SomeMap
            }
        }
        print("Did not find map item for \(For)")
        return nil
    }
    
    /// List of map items.
    public static let Maps: [MapItem] =
        [
            MapItem(.Standard, false, "LandMask2", "WorldNorth", "WorldSouth"),
            MapItem(.StandardSea, false, "SeaMask2", "WordNorth", "WorldSouth"),
            MapItem(.BlueMarble, false, "BlueMarble", "BlueMarbleNorthCenter", "BlueMarbleSouthCenter"),
            MapItem(.DarkBlueMarble, false, "BlackMarble2", "BlackMarbleNorthCenter2", "BlackMarbleSouthCenter2"),
            MapItem(.Continents, false, "SimpleMapContinents", "SimpleMapContinentsNorthCenter", "SimpleMapContinentsSouthCenter"),
            MapItem(.Dots, false, "DotMap", "DotMapNorthCenter", "DotMapSouthCenter"),
            MapItem(.Simple, false, "SimpleMap1", "SimpleNorthCenter", "SimpleSouthCenter"),
            MapItem(.SimpleBorders1, false, "SimpleMapWithBorders1", "SimpleMapWithBordersNorthCenter1", "SimpleMapWithBordersSouthCenter1"),
            MapItem(.SimpleBorders2, false, "SimpleMapBorders", "SimpleMapWithBordersNorthCenter1", "SimpleMapWithBordersSouthCenter1"),
            MapItem(.Extruded, false, "Style5", "ExtrudedNorthCenter", "ExtrudedSouthCenter"),
            MapItem(.HalftoneDot, false, "Style4", "HalftoneDotNorthCenter", "HalftoneDotSouthCenter"),
            MapItem(.HalftoneLine, false, "Style3", "HalftoneLineNorthCenter", "HalftoneLineSouthCenter"),
            MapItem(.HalftoneVerticalLine, false, "HalftoneVerticalLines", "HalftoneVerticalLinesNorthCenter", "HalftoneVerticalLinesSouthCenter"),
            MapItem(.Crosshatched, false, "Style1", "HatchedNorthCenter", "HatchedSouthCenter"),
            MapItem(.Pink, false, "PinkMap", "PinkMapNorthCenter", "PinkMapSouthCenter"),
            MapItem(.Cartoon, false, "CartoonMap", "CartoonMapNorthCenter", "CartoonMapSouthCenter"),
            MapItem(.Dithered, false, "DitheredMap", "DitheredMapNorthCenter", "DitheredMapSouthCenter"),
            MapItem(.SwirlyLines, false, "ArtMap1", "ArtMap1NorthCenter", "ArtMap1SouthCenter"),
            MapItem(.RoundSplotches, false, "ArtMap2", "ArtMap2NorthCenter", "ArtMap2SouthCenter"),
            MapItem(.Textured, false, "Style2", "TexturedEarthNorthCenter", "TexturedEarthSouthCenter"),
            MapItem(.Bronze, false, "BronzeMap", "BronzeMapNorthCenter", "BronzeMapSouthCenter"),
            MapItem(.Abstract1, false, "AbstractShapes1", "AbstractShapes1NorthCenter", "AbstractShapes1SouthCenter"),
            MapItem(.Abstract2, false, "Abstract2", "Abstract2NorthCenter", "Abstract2SouthCenter"),
            MapItem(.Dots2, false, "DotWorld", "DotWorldNorthCenter", "DotWorldSouthCenter"),
            MapItem(.Dots3, false, "DotWorld3", "DotWorld3NorthCenter", "DotWorld3SouthCenter"),
            MapItem(.Surreal1, false, "Surreal1", "Surreal1NorthCenter", "Surreal1SouthCenter"),
            MapItem(.WaterColor1, false, "WaterColor2", "WaterColor2NorthCenter", "WaterColor2SouthCenter"),
            MapItem(.WaterColor2, false, "WaterColorPlanet", "WaterColorPlanetNorthCenter", "WaterColorPlanetSouthCenter"),
            MapItem(.OilPainting1, false, "ArtMap4", "ArtMap4NorthCenter", "ArtMap4SouthCenter"),
            MapItem(.Abstract3, false, "SegmentedMap", "SegmentedMapNorthCenter", "SegmentedMapSouthCenter"),
            MapItem(.StaticAerosol, false, "aerosol", "AerosolNorthCenter", "AerosolSouthCenter"),
            MapItem(.Topographical1, false, "Topographical1", "Topographical1NorthCenter", "Topographical1SouthCenter"),
            MapItem(.Topographical2, false, "EarthTopo", "EarthTopoNorthCenter", "EarthTopoSouthCenter"),
            MapItem(.PoliticalSubDivisions, false, "PoliticalSubDivisions3600", "PoliticalSubDivisionsNorthCenter", "PoliticalSubDivisionsSouthCenter"),
            MapItem(.MarsViking, false, "MarsViking", "MarsVikingNorthCenter", "MarsVikingsouthCenter"),
            MapItem(.MOLAVerticalRoughness, false, "MarsVerticalRoughness", "MarsVerticalRoughnessNorthCenter", "MarsVerticalRoughnessSouthCenter"),
            MapItem(.MarsMariner9, false, "MarsM9GeoMap", "MarsM9GeoMapNorthCenter", "MarsM9GeoMapSouthCenter"),
            MapItem(.LROMap, false, "LROMoon", "LRONorthCenter", "LROSouthCenter"),
            MapItem(.LunarGeoMap, false, "LunarGeoMap", "LunarGeoMapNorthCenter", "LunarGeoMapSouthCenter"),
            MapItem(.House, false, "House", "HouseUpCenter", "HouseDownCenter"),
            MapItem(.Tigger, false, "TiggerWorld", "TiggerWorldR0", "TiggerWorldroundR1"),
            MapItem(.Normalized, true, "WorldNormalizedTiles.png", "WorldNormalizedTilesNorthCenter.png", "WorldNormalizedTilesSouthCenter.png"),
            MapItem(.Blueprint, true, "WorldBluePrint.png", "WorldBluePrintNorthCenter.png", "WorldBluePrintSouthCenter.png"),
            MapItem(.Skeleton, true, "WorldSkeleton.png", "WorldSkeletonNorthCenter.png", "WorldSkeletonSouthCenter.png"),
            MapItem(.Polygons, true, "WorldPolygonize.png", "WorldPolygonizeNorthCenter.png", "WorldPolygonizeSouthCenter.png"),
            MapItem(.ColorInk, true, "WorldInkColor.png", "WorldInkColorNorthCenter.png", "WorldInkColorSouthCenter.png"),
            MapItem(.Warhol, true, "WorldWarhol.png", "WorldWarholNorthCenter.png", "WorldWarholSouthCenter.png"),
            MapItem(.Voronoi, true, "WorldVoronoi.png", "WorldVoronoiNorthCenter.png", "WorldVoronoiSouthCenter.png"),
            MapItem(.SpotColor, true, "WorldSpotColor.png", "WorldSpotColorNorthCenter.png", "WorldSpotColorSouthCenter.png"),
            MapItem(.Ukiyoe1, true, "WorldUkiyoe1.png", "WorldUkiyoe1NorthCenter.png", "WorldUkiyoe1SouthCenter.png"),
            MapItem(.SurrealTopographic, true, "EarthTopoGlowingEdges1.png", "EarthTopoGlowingEdges1NorthCenter.png", "EarthTopoGlowingEdges1SouthCenter.png"),
            MapItem(.BubbleWorld, true, "BubbleWorld.png", "BubbleWorldNorthCenter.png", "BubbleWorldSouthCenter.png"),
            MapItem(.GaiaSky, true, "GaiaSky.png", "GaiaSkyNorthCenter.png", "GaiaSkySouthCenter.png"),
            MapItem(.TychoSky, true, "TychoSky.png", "TychoSkyNorthCenter.png", "TychoSkySouthCenter.png"),
            MapItem(.NASAStarsInverted, true, "NASAStarMapInverted.png", "NASAStarMapInvertedNorthCenter.png", "NASAStarMapInvertedSouthCenter.png"),
            MapItem(.OnlyTectonic, true, "OnlyPlates2.png", "OnlyPlates2NorthCenter.png", "OnlyPlates2SouthCenter.png"),
            MapItem(.TectonicOverlay, true, "ColorTectonicsOverlay.png", "ColorTectonicsNorthCenterOverlay.png", "ColorTectonicsSouthCenterOverlay.png"),
            MapItem(.BlackWhite, true, "BlackWhite.png", "BlackWhiteNorthCenter.png", "BlackWhiteSouthCenter.png"),
            MapItem(.BlackWhiteShiny, true, "BlackWhiteShiny.png", "BlackWhiteNorthCenter.png", "BlackWhiteSouthCenter.png"),
            MapItem(.WhiteBlack, true, "WhiteBlack.png", "WhiteBlackNorthCenter.png", "WhiteBlackSouthCenter.png"),
            MapItem(.Jupiter, true, "Jupiter.png", "JupiterNorthCenter.png", "JupiterSouthCenter.png"),
            MapItem(.SquareWorld, true, "WorldSquare.png", "WorldSquareNorthCenter.png", "WorldSquareSouthCenter.png"),
            MapItem(.LevelWorld, true, "WorldSquareLevels.png", "WorldSquareLevelsNorthCenter.png", "WorldSquareLevelsSouthCentered.png"),
            MapItem(.GlowingCoasts, true, "WorldGlowingCoasts.png", "WorldGlowingCoastsNorthCenter.png", "WorldGlowingCoastsSouthCenter.png"),
            MapItem(.StainedGlass, true, "WorldStainedGlass1.png", "WorldStainedGlass1NorthCenter.png", "WorldStainedGlass1SouthCenter.png"),
            MapItem(.PaperWorld, true, "PaperWorld.png", "PaperWorldNorthCenter.png", "PaperWorldSouthCenter.png"),
            MapItem(.ASCIIArt1, true, "WorldASCIIArt.png", "WorldASCIIArtNorthCenter.png", "WorldASCIIArtSouthCenter.png"),
            MapItem(.TychoConstellations, true, "TychoWithConstellations.png", "TychoConstellationsNorthCenter.png", "TychoConstellationsSouthCenter.png"),
            MapItem(.TimeZoneMap1, true, "TimeZoneMap.png", "TimeZoneMapNorthCenter.png", "TimeZoneMapSouthCenter.png"),
            MapItem(.SurrealTimeZone, true, "SurrealTimeZones.png", "SurrealTimeZoneNorthCenter.png", "SurrealTimeZoneSouthCenter.png"),
            MapItem(.HatchedTimeZones, true, "HatchedTimeZones.png", "HatchedTimeZonesNorthCenter.png", "HatchedTimeZoneSouthCenter.png"),
            MapItem(.PaperTimeZones, true, "PaperTimeZones.png", "PaperTimeZonesNorthCenter.png", "PaperTimeZonesSouthCenter.png"),
            MapItem(.ColorfulTimeZones, true, "TimeZoneMap3.png", "TimeZoneMap3NorthCenter.png", "TimeZoneMap3SouthCenter.png"),
            MapItem(.SimplePoliticalMap1, true, "SimplePoliticalWorldMap.png", "SimplePoliticalWorldMapNorthCenter.png", "SimplePoliticalWorldMapSouthCenter.png"),
            MapItem(.TransparentOcean, true, "TransparentOceanMap.png", "SimplePoliticalWorldMapNorthCenter.png", "SimplePoliticalWorldMapSouthCenter.png"),
            MapItem(.MODIS, true, "MODIS.png", "MODISNorthCenter.png", "MODISSouthCenter.png"),
            MapItem(.TimeZone4, true, "TimeZone4.png", "TimeZone4NorthCenter.png", "TimeZone4SouthCenter.png"),
            MapItem(.Debug1, true, "BlackWhiteHarlequin.png", "BlackWhiteHarlequinNorth.png", "BlackWhiteHarlequinSouth.png"),
            MapItem(.Debug2, true, "BWSimpleTimeZones.png", "BWSimpleRoundTimeZones.png", "BWSimpleRoundTimeZones.png"),
            MapItem(.Debug3, true, "HarlequinMap.png", "BlackWhiteHarlequinNorth.png", "BlackWhiteHarlequinSouth.png"),
            MapItem(.Debug4, true, "BWCheckerboard.png", "BWCheckerboardRound.png", "BWCheckerboardRound.png"),
            MapItem(.Debug5, true, "BlackClearCheckerboard.png", "BWCheckerboardRound.png", "BWCheckerboardRound.png"),
    ]
}

/// Types/styles of world maps supported.
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
    case SurrealTopographic = "Surreal Topographic"
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
    case SpotColor = "Spot Color Map"
    case Ukiyoe1 = "Ukiyoe Map 1"
    case BubbleWorld = "Bubble World"
    case NASAStarsInverted = "Inverted Star Map"
    case TychoSky = "Tycho Star Map"
    case TychoConstellations = "Tycho Star Map with Lines"
    case GaiaSky = "Gaia Star Map"
    case OnlyTectonic = "Tectonic Map"
    case TectonicOverlay = "Overlayed Tectonic"
    case BlackWhite = "Black and White Map"
    case BlackWhiteShiny = "Shiny Black and White Map"
    case WhiteBlack = "White and Black Map"
    case Jupiter = "Jupiter"
    case PaperWorld = "Paper World"
    case SquareWorld = "World of Squares"
    case LevelWorld = "World of Levels"
    case GlowingCoasts = "Glowing Coasts"
    case StainedGlass = "Stained Glass"
    case ASCIIArt1 = "ASCII Art Map 1"
    case TimeZoneMap1 = "CIA Time Zone Map"
    case SurrealTimeZone = "Surreal Time Zone Map"
    case ColorfulTimeZones = "Colorful Time Zone Map"
    case HatchedTimeZones = "Hatched Time Zone Map"
    case PaperTimeZones = "Paper Time Zone Map"
    case SimplePoliticalMap1 = "Simple Political Map 1"
    case TransparentOcean = "Transparent Ocean"
    case MODIS = "MODIS"
    case TimeZone4 = "Time Zone Map 4"
    case Debug1 = "Harlequin Black and White"
    case Debug3 = "Vertical Time Zones"
    case Debug2 = "Harlequin Black with Color"
    case Debug4 = "Black White Checkerboard"
    case Debug5 = "Black Color Checkerboard"
}
