//
//  AnimatedGradient.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/10/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Handles animated gradient creation.
class AnimatedGradient
{
    /// Default initializer.
    init()
    {
    }
    
    /// Initializer.
    /// - Parameter With: Delegate to receive animation messages.
    init(With Delegate: AnimationProtocol)
    {
        self.Delegate = Delegate
    }
    
    /// Delegate to receive animation messages. If this is not set, animation will still occur but
    /// no one will know about it.
    public weak var Delegate: AnimationProtocol? = nil
    
    /// Returns a static animated gradient image.
    /// - Parameter Size: The size of the returned image.
    /// - Parameter Colors: List of colors and associated locations that define the gradient.
    /// - Returns: Image of the specified gradient. Nil on error.
    public func MakeGradientImage(Size: CGSize, Colors: [(CGColor, Double)]) -> UIImage?
    {
        UIGraphicsBeginImageContextWithOptions(Size, false, UIScreen.main.scale)
        defer{UIGraphicsEndImageContext()}
        guard let Context = UIGraphicsGetCurrentContext() else
        {
            return nil
        }
        let GradientLayer = MakeGradient(Size: Size, Colors: Colors)
        GradientLayer.render(in: Context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Given a layer, return an image of the layer.
    /// - Parameter Layer: The layer whose image will be returned.
    /// - Parameter Size: The size of the layer and image.
    /// - Returns: Image of the layer on success, nil on error.
    public func MakeImageFromLayer(_ Layer: CAGradientLayer, Size: CGSize) -> UIImage?
    {
        UIGraphicsBeginImageContextWithOptions(Size, false, UIScreen.main.scale)
        defer{UIGraphicsEndImageContext()}
        guard let Context = UIGraphicsGetCurrentContext() else
        {
            return nil
        }
        Layer.render(in: Context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Returns a gradient layer defined by the size and colors.
    /// - Parameter Size: The size of the returned layer.
    /// - Parameter Colors: List of colors and associated locations that define the gradient.
    /// - Returns: Gradient layer defined by the parameters.
    public func MakeGradient(Size: CGSize, Colors: [(CGColor, Double)]) -> CAGradientLayer
    {
        let Layer = CAGradientLayer()
        Layer.frame = CGRect(origin: CGPoint.zero, size: Size)
        let ColorList = Colors.map{$0.0}
        Layer.colors = ColorList
        let PositionList = Colors.map{NSNumber(value: $0.1)}
        Layer.locations = PositionList
        return Layer
    }
    
    /// Start an animated gradient process.
    /// - Note: Updated gradients are returned via the `AnimationProtocol` `NewAnimatedGradient` function.
    /// - Parameter Size: The size of the image to return as part of animating a gradient.
    /// - Parameter StartColors: List of colors and respective gradient positions for the start.
    /// - Parameter EndColors: List of colors and respective gradient positions for the end.
    /// - Parameter StepTime: How often to update the colors.
    public func StartAnimatedGradient(Size: CGSize, StartColors: [(CGColor, Double)],
                                      EndColors: [(CGColor, Double)],
                                      StepTime: Double)
    {
        let Layer = CAGradientLayer()
        Layer.frame = CGRect(origin: CGPoint.zero, size: Size)
        let ColorList = StartColors.map{$0.0}
        Layer.colors = ColorList
        let PositionList = StartColors.map{NSNumber(value: $0.1)}
        Layer.locations = PositionList
        if let LayerImage = MakeImageFromLayer(Layer, Size: Size)
        {
            Delegate?.NewAnimatedGradient(NewGradient: LayerImage)
        }
        
        
    }
}
