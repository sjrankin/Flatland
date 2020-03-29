//
//  Cities.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/28/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SQLite3

/// Holds and manages the list of cities.
class Cities
{
    /// Default initializer.
    init()
    {
        _AllCities = CitiesData.RawCityList
    }
    
    /// Search for a city with the passed name.
    /// - Parameter Name: The name of the city. Case insensitive.
    /// - Returns: The city's record if found, nil if not.
    public func FindCity(Name: String) -> City?
    {
        return FindCity(In: _AllCities, WithName: Name)
    }
    
    /// Search for a city with the passed name.
    /// - Parameter In: The list of cities to search.
    /// - Parameter WithName: The name of the city. Case insensitive.
    /// - Returns: The city's record if found, nil if not.
    public func FindCity(In SourceList: [City], WithName: String) -> City?
    {
        for SomeCity in SourceList
        {
            if SomeCity.Name.lowercased() == WithName.lowercased()
            {
                return SomeCity
            }
        }
        return nil
    }
    
    /// Returns all capital cities.
    /// - Parameter DoSort: If true, cities are returned in name-sorted order.
    /// - Returns: All cities marked as a capital city.
    public func AllCapitalCities(DoSort: Bool = false) -> [City]
    {
        return AllCapitalCities(In: _AllCities, DoSort: DoSort)
    }
    
    /// Returns all capital cities in the passed city list.
    /// - Parameter In: The list of cities to search for capital cities.
    /// - Parameter DoSort: If true, cities are returned in name-sorted order.
    /// - Returns: All cities marked as a capital city.
    public func AllCapitalCities(In SourceList: [City], DoSort: Bool = false) -> [City]
    {
        var CapitalCities = [City]()
        for SomeCity in SourceList
        {
            if SomeCity.IsCapital
            {
                CapitalCities.append(SomeCity)
            }
        }
        if DoSort
        {
            CapitalCities.sort(by: {$0.Name < $1.Name})
        }
        return CapitalCities
    }
    
    /// Return a list of all cities with a metropolitan population.
    /// - Parameter DoSort: If true, the returned list will be sorted in metropolitan population order.
    /// - Returns: List of all cities with a metropolitan population.
    public func AllMetroAreas(DoSort: Bool = false) -> [City]
    {
        return AllMetroAreas(In: _AllCities, DoSort: DoSort)
    }
    
    /// Return a list of all cities with a metropolitan population.
    /// - Parameter In: The list of cities to search.
    /// - Parameter DoSort: If true, the returned list will be sorted in metropolitan population order.
    /// - Returns: List of all cities with a metropolitan population.
    public func AllMetroAreas(In SourceList: [City], DoSort: Bool = false) -> [City]
    {
        var MetroAreas = [City]()
        for SomeCity in SourceList
        {
            if SomeCity.MetropolitanPopulation != nil
            {
                MetroAreas.append(SomeCity)
            }
        }
        if DoSort
        {
            MetroAreas.sort(by: {$0.MetropolitanPopulation! < $1.MetropolitanPopulation!})
        }
        return MetroAreas
    }
    
    /// Returns a list of all cities in the supplied continent.
    /// - Parameter Continent: The continent whose cities will be returned.
    /// - Parameter DoSort: If true, the returned list will be sorted in city names.
    /// - Returns: List of cities in the specified continent.
    public func CitiesIn(_ Continent: Continents, DoSort: Bool = false) -> [City]
    {
        return CitiesIn(In: _AllCities, Continent: Continent, DoSort: DoSort)
    }
    
    /// Returns a list of all cities in the supplied continent.
    /// - Parameter In: List of cities to search.
    /// - Parameter Continent: The continent whose cities will be returned.
    /// - Parameter DoSort: If true, the returned list will be sorted in city names.
    /// - Returns: List of cities in the specified continent.
    public func CitiesIn(In SourceList: [City], Continent: Continents, DoSort: Bool = false) -> [City]
    {
        var ContinentalCities = [City]()
        for SomeCity in SourceList
        {
            if SomeCity.Continent == Continent
            {
                ContinentalCities.append(SomeCity)
            }
        }
        if DoSort
        {
            ContinentalCities.sort(by: {$0.Name < $1.Name})
        }
        return ContinentalCities
    }
    
    /// Returns a list of all cities in the supplied country.
    /// - Parameter Country: The continent whose cities will be returned. Country names are
    ///                      case insensitive
    /// - Parameter DoSort: If true, the returned list will be sorted in city names.
    /// - Returns: List of cities in the specified country.
    public func CitiesIn(Country: String, DoSort: Bool = false) -> [City]
    {
        return CitiesIn(In: _AllCities, Country: Country, DoSort: DoSort)
    }
    
    /// Returns a list of all cities in the supplied country.
    /// - Parameter In: The list of cities to search.
    /// - Parameter Country: The continent whose cities will be returned. Country names are
    ///                      case insensitive
    /// - Parameter DoSort: If true, the returned list will be sorted in city names.
    /// - Returns: List of cities in the specified country.
    public func CitiesIn(In SourceList: [City], Country: String, DoSort: Bool = false) -> [City]
    {
        var CountryCities = [City]()
        for SomeCity in SourceList
        {
            if SomeCity.Country.lowercased() == Country.lowercased()
            {
                CountryCities.append(SomeCity)
            }
        }
        if DoSort
        {
            CountryCities.sort(by: {$0.Name < $1.Name})
        }
        return CountryCities
    }
    
    /// Return a list of cities whose population is greater than or equal to the passed value.
    /// - Parameter GreaterThan: The minimum value the population of the city must be to be included in the returned list.
    /// - Parameter UseMetroPopulation: If true, the metropolitan population is used. Otherwise, the city population
    ///                                 is used. In either case, if the population value is nil, it will not be
    ///                                 included in the returned list.
    /// - Parameter DoSort: If true, the returned list is sorted in name order.
    /// - Returns: List of cities whose population is greater than or equal to `GreaterThan`.
    public func CitiesByPopulation(GreaterThan: Int, UseMetroPopulation: Bool, DoSort: Bool = false) -> [City]
    {
        return CitiesByPopulation(In: _AllCities, GreaterThan: GreaterThan, UseMetroPopulation: UseMetroPopulation, DoSort: DoSort)
    }
    
    /// Return a list of cities whose population is greater than or equal to the passed value.
    /// - Parameter In: List of cities to search.
    /// - Parameter GreaterThan: The minimum value the population of the city must be to be included in the returned list.
    /// - Parameter UseMetroPopulation: If true, the metropolitan population is used. Otherwise, the city population
    ///                                 is used. In either case, if the population value is nil, it will not be
    ///                                 included in the returned list.
    /// - Parameter DoSort: If true, the returned list is sorted in name order.
    /// - Returns: List of cities whose population is greater than or equal to `GreaterThan`.
    public func CitiesByPopulation(In SourceList: [City], GreaterThan: Int, UseMetroPopulation: Bool, DoSort: Bool = false) -> [City]
    {
        var CityList = [City]()
        for SomeCity in SourceList
        {
            if UseMetroPopulation
            {
                if let Population = SomeCity.MetropolitanPopulation
                {
                    if Population >= GreaterThan
                    {
                        CityList.append(SomeCity)
                    }
                }
            }
            else
            {
                if let Population = SomeCity.Population
                {
                    if Population >= GreaterThan
                    {
                        CityList.append(SomeCity)
                    }
                }
            }
        }
        if DoSort
        {
            CityList.sort(by: {$0.Name < $1.Name})
        }
        return CityList
    }
    
    /// Return a list of cities whose population is less than the passed value.
    /// - Parameter LessThan: The maximum value the population of the city must be to be included in the returned list.
    /// - Parameter UseMetroPopulation: If true, the metropolitan population is used. Otherwise, the city population
    ///                                 is used. In either case, if the population value is nil, it will not be
    ///                                 included in the returned list.
    /// - Parameter DoSort: If true, the returned list is sorted in name order.
    /// - Returns: List of cities whose population is less than `LessThan`.
    public func CitiesByPopulation(LessThan: Int, UseMetroPopulation: Bool, DoSort: Bool = false) -> [City]
    {
        return CitiesByPopulation(In: _AllCities, LessThan: LessThan, UseMetroPopulation: UseMetroPopulation, DoSort: DoSort)
    }
    
    /// Return a list of cities whose population is less than the passed value.
    /// - Parameter In: The list of cities to search.
    /// - Parameter LessThan: The maximum value the population of the city must be to be included in the returned list.
    /// - Parameter UseMetroPopulation: If true, the metropolitan population is used. Otherwise, the city population
    ///                                 is used. In either case, if the population value is nil, it will not be
    ///                                 included in the returned list.
    /// - Parameter DoSort: If true, the returned list is sorted in name order.
    /// - Returns: List of cities whose population is less than `LessThan`.
    public func CitiesByPopulation(In SourceList: [City], LessThan: Int, UseMetroPopulation: Bool, DoSort: Bool = false) -> [City]
    {
        var CityList = [City]()
        for SomeCity in SourceList
        {
            if UseMetroPopulation
            {
                if let Population = SomeCity.MetropolitanPopulation
                {
                    if Population < LessThan
                    {
                        CityList.append(SomeCity)
                    }
                }
            }
            else
            {
                if let Population = SomeCity.Population
                {
                    if Population < LessThan
                    {
                        CityList.append(SomeCity)
                    }
                }
            }
        }
        if DoSort
        {
            CityList.sort(by: {$0.Name < $1.Name})
        }
        return CityList
    }
    
    public func CitiesWithMetroPopulation() -> [City]
    {
        return CitiesWithMetroPopulation(In: _AllCities)
    }
    
    public func CitiesWithMetroPopulation(In SourceList: [City]) -> [City]
    {
        var Final = [City]()
        for SomeCity in SourceList
        {
            if SomeCity.MetropolitanPopulation != nil
            {
                Final.append(SomeCity)
            }
        }
        return Final
    }
    
    public func CitiesWithPopulation() -> [City]
    {
        return CitiesWithPopulation(In: _AllCities)
    }
    
    public func CitiesWithPopulation(In SourceList: [City]) -> [City]
    {
        var Final = [City]()
        for SomeCity in SourceList
        {
            if SomeCity.Population != nil
            {
                Final.append(SomeCity)
            }
        }
        return Final
    }
    
    public func TopNCities(N: Int, UseMetroPopulation: Bool = true) -> [City]
    {
        return TopNCities(In: _AllCities, N: N, UseMetroPopulation: UseMetroPopulation)
    }
    
    public func TopNCities(In SourceList: [City], N: Int, UseMetroPopulation: Bool = true) -> [City]
    {
        var Sorted = [City]()
        if UseMetroPopulation
        {
            Sorted = CitiesWithMetroPopulation(In: SourceList).sorted(by: {$0.MetropolitanPopulation! > $1.MetropolitanPopulation!})
        }
        else
        {
            Sorted = CitiesWithPopulation(In: SourceList).sorted(by: {$0.Population! > $1.Population!})
        }
        let FinalCount = Sorted.count - N
        return Sorted.dropLast(FinalCount)
    }
    
    /// Returns a list of all cities read from the database.
    /// - Returns: List of all cities.
    public func GetAllCities() -> [City]
    {
        return _AllCities
    }
    
    /// Holds all of the cities.
    private var _AllCities = [City]()
}
