//
//  +MoreLocations.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension MainView
{
    func LoadWorldHeritageSites() -> WorldHeritageSites?
    {
        #if true
        if let FileURL = Bundle.main.url(forResource: "WorldHeritageSites2019", withExtension: "json")
        {
            print("\(FileURL.path)")
            do
            {
                let RawData = try Data(contentsOf: FileURL)
                let Decoder = JSONDecoder()
                let Sites = try Decoder.decode(WorldHeritageSites.self, from: RawData)
                return Sites
            }
            catch
            {
                fatalError("\(error.localizedDescription)")
            }
        }
        return nil
        #else
        if let FileURL = Bundle.main.url(forResource: "WorldHeritageSites2019", withExtension: "json")
        {
            do
            {
                let RawData = try Data(contentsOf: FileURL)
                let Decoder = JSONDecoder()
                let HeritageSites = try Decoder.decode(WorldHeritageSites.self, from: RawData)
                return HeritageSites
            }
            catch
            {
                fatalError("Error loading world heritage sites: \(error.localizedDescription)")
            }
        }
        print("Error finding WorldHeritageSites2019.json in bundle.")
        return nil
        #endif
    }
}

#if true
struct WorldHeritageSite: Codable {
    let uid, id: Int
    let name: String
    let dateInscribed: Int
    let longitude, latitude, hectares: Double
    let category, categoryShort, countries: String
    
    enum CodingKeys: String, CodingKey {
        case uid = "UID"
        case id = "ID"
        case name = "Name"
        case dateInscribed = "DateInscribed"
        case longitude = "Longitude"
        case latitude = "Latitude"
        case hectares = "Hectares"
        case category = "Category"
        case categoryShort = "CategoryShort"
        case countries = "Countries"
    }
}

typealias WorldHeritageSites = [WorldHeritageSite]
#else
struct WorldHeritageSites: Decodable
{
    var Sites: [WorldHeritageSite]
    
    enum CodingKeys: String, CodingKey
    {
        case Sites = "Sites"
    }
}

struct WorldHeritageSite: Decodable
{
    var UID: Int
    var ID: Int
    var Name: String
    var DateInscribed: Int
    var Longitude: Double
    var Latitude: Double
    var Hectares: Double
    var Category: String
    var CategoryShort: String
    var Countries: String
    
    enum CodingKeys: String, CodingKey
    {
        case UID = "UID"
        case ID = "ID"
        case Name = "Name"
        case DateInscribed = "DateInscribed"
        case Longitude = "Longitude"
        case Latitude = "Latitude"
        case Hectares = "Hectares"
        case Category = "Category"
        case CategoryShort = "CategoryShort"
        case Countries = "Countries"
    }
}
#endif
