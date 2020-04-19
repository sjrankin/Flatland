//
//  NotDone.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/28/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Implements single task control.
class SingleTask
{
    /// Determines if a task whose ID is passed to us has been completed or not.
    /// - Parameter ID: If nil, a new task ID will be created and returned. If not nil, if the task
    ///                 ID exists in the `WasCompleted` list, false is returned. Otherwise the ID
    ///                 is added and true is returned.
    /// - Returns: True if the task can be executed, false if not.
    static func NotCompleted(_ ID: inout UUID?) -> Bool
    {
        if ID == nil
        {
            ID = UUID()
            WasCompleted.append(ID!)
            return true
        }
        if WasCompleted.contains(ID!)
        {
            return false
        }
        WasCompleted.append(ID!)
        return true
    }
    
    /// Holds the list of completed tasks.
    private static var WasCompleted = [UUID]()
}
