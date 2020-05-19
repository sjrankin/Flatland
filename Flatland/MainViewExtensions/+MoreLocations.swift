//
//  +MoreLocations.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SQLite3

extension MainView
{
    /// Initialize the world heritage site database.
    /// - Warning: A fatal error is generated on error.
    func InitializeWorldHeritageSites()
    {
        FileIO.InstallDatabase()
        if let UnescoURL = FileIO.GetDatabaseURL()
        {
            if sqlite3_open_v2(UnescoURL.path, &UnescoHandle,
                               SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_CREATE, nil) != SQLITE_OK
            {
                fatalError("Error opening \(UnescoURL.path), \(String(cString: sqlite3_errmsg(UnescoHandle!)))")
            }
        }
        else
        {
            fatalError("Error getting URL for Unesco database.")
        }
    }
    
    /// Return the number of Unesco world heritage sites in the database.
    /// - Returns: Number of world heritage sites in the database.
    func SiteCount() -> Int
    {
        let GetCount = "SELECT COUNT(*) FROM Sites"
        var CountQuery: OpaquePointer? = nil
        if sqlite3_prepare(UnescoHandle, GetCount, -1, &CountQuery, nil) == SQLITE_OK
        {
            while sqlite3_step(CountQuery) == SQLITE_ROW
            {
                let Count = sqlite3_column_int(CountQuery, 0)
                return Int(Count)
            }
        }
        print("Error returned when preparing \"\(GetCount)\"")
        return 0
    }
    
    /// Return all Unesco world heritage site information.
    /// - Returns: Array of world heritage sites.
    func GetAllSites() -> [WorldHeritageSite]
    {
        var Results = [WorldHeritageSite]()
        let GetQuery = "SELECT * FROM Sites"
        let QueryHandle = SetupQuery(DB: UnescoHandle, Query: GetQuery)
        while (sqlite3_step(QueryHandle) == SQLITE_ROW)
        {
            let UID = Int(sqlite3_column_int(QueryHandle, 0))
            let ID = Int(sqlite3_column_int(QueryHandle, 1))
            let Name = String(cString: sqlite3_column_text(QueryHandle, 2))
            let Year = Int(sqlite3_column_int(QueryHandle, 3))
            let Longitude = Double(sqlite3_column_double(QueryHandle, 4))
            let Latitude = Double(sqlite3_column_double(QueryHandle, 5))
            let Hectares = Double(sqlite3_column_double(QueryHandle, 6))
            let Category = String(cString: sqlite3_column_text(QueryHandle, 7))
            let ShortCategory = String(cString: sqlite3_column_text(QueryHandle, 8))
            let Countries = String(cString: sqlite3_column_text(QueryHandle, 9))
            let Site = WorldHeritageSite(UID, ID, Name, Year, Latitude, Longitude, Hectares,
                                         Category, ShortCategory, Countries)
            Results.append(Site)
        }
        return Results
    }
    
    /// Set up a query in to the database.
    /// - Parameter DB: The handle of the database for the query.
    /// - Parameter Query: The query string.
    /// - Returns: Handle for the query. Valid only for the same database the query was generated for.
    private func SetupQuery(DB: OpaquePointer?, Query: String) -> OpaquePointer?
    {
        if DB == nil
        {
            return nil
        }
        if Query.isEmpty
        {
            return nil
        }
        var QueryHandle: OpaquePointer? = nil
        if sqlite3_prepare(DB, Query, -1, &QueryHandle, nil) != SQLITE_OK
        {
            let LastSQLErrorMessage = String(cString: sqlite3_errmsg(DB))
            print("Error preparing query \"\(Query)\": \(LastSQLErrorMessage)")
            return nil
        }
        return QueryHandle
    }
}
