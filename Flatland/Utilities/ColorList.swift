//
//  ColorList.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/17/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Manages color lists.
class ColorList
{
    /// Basic color list.
    public static var Colors: [MetaColor] =
    [
        MetaColor("Red", UIColor.red),
        MetaColor("Green", UIColor.green),
        MetaColor("Blue", UIColor.blue),
        MetaColor("Cyan", UIColor.cyan),
        MetaColor("Magenta", UIColor.magenta),
        MetaColor("Yellow", UIColor.yellow),
        MetaColor("Orange", UIColor.orange),
        MetaColor("Brown", UIColor.brown),
        MetaColor("Black", UIColor.black),
        MetaColor("White", UIColor.white),
        MetaColor("Gray", UIColor.gray),
        MetaColor("Gold", UIColor(HexString: "#ffd700")!),
        MetaColor("Maroon", UIColor(HexString: "#800000")!),
        MetaColor("Light Sky Blue", UIColor(HexString: "#87cefa")!),
        MetaColor("Prussian Blue", UIColor(HexString: "#003171")!),
        MetaColor("Pistachio", UIColor(HexString: "#93c572")!),
        MetaColor("Lime", UIColor(HexString: "#bfff00")!),
        MetaColor("Midori", UIColor(HexString: "#2a603b")!),
        MetaColor("Bōtan", UIColor(HexString: "#a4345d")!),
        MetaColor("Shironeri", UIColor(HexString: "ffddca")!),
        MetaColor("Ajiiro", UIColor(HexString: "#ebf6f7")!),
    ]
    
    public static func SimpleColorList() -> [(Name: String, Color: UIColor)]
    {
        var Results = [(Name: String, Color: UIColor)]()
        for SomeColor in Colors
        {
            Results.append((SomeColor.Name, SomeColor.Color))
        }
        return Results
    }
    
    public static func MetaColorFrom(_ Raw: String) -> MetaColor?
    {
        guard let RawColor = UIColor(HexString: Raw) else
        {
            return nil
        }
        return MetaColorFrom(RawColor)
    }
    
    public static func MetaColorFrom(_ Color: UIColor) -> MetaColor?
    {
        for SomeColor in Colors
        {
            if SomeColor.Color == Color
            {
                return SomeColor
            }
        }
        return nil
    }
}

/// Contains a single color.
class MetaColor
{
    /// Initializer.
    /// - Note: Alpha is set to `1.0`.
    /// - Parameter Name: The name of the color.
    /// - Parameter R: The red channel value - **must be normalized**.
        /// - Parameter G: The green channel value - **must be normalized**.
        /// - Parameter B: The blue channel value - **must be normalized**.
    init(_ Name: String, _ R: Double, _ G: Double, _ B: Double)
    {
        self.Name = Name
        Color = UIColor(red: CGFloat(R), green: CGFloat(G), blue: CGFloat(B), alpha: 1.0)
    }
    
    /// Initializer.
    /// - Parameter Name: The name of the color.
    /// - Parameter R: The red channel value - **must be normalized**.
    /// - Parameter G: The green channel value - **must be normalized**.
    /// - Parameter B: The blue channel value - **must be normalized**.
    /// - Parameter A: The alpha channel value - **must be normalized**.
    init(_ Name: String, _ R: Double, _ G: Double, _ B: Double, _ A: Double)
    {
        self.Name = Name
        Color = UIColor(red: CGFloat(R), green: CGFloat(G), blue: CGFloat(B), alpha: CGFloat(A))
    }
    
    /// Initializer.
    /// - Parameter Name: The name of the color.
    /// - Parameter Value: The UIColor from which to create a color.
    init(_ Name: String, _ Value: UIColor)
    {
        self.Name = Name
        Color = Value
    }
    
    /// Initializer.
    /// - Parameter Name: The name of the color.
    /// - Parameter Value: Hex string used to create a color. Invalid strings will cause
    ///                    fatal errors.
    init(_ Name: String, _ Value: String)
    {
        self.Name = Name
        Color = UIColor(HexString: Value)!
    }
    
    /// The color.
    var Color: UIColor = UIColor.clear
    
    /// The name of the color.
    var Name: String = ""
}
