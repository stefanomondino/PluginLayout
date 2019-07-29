//
//  PluginLayoutAttributes.swift
//  Example
//
//  Created by Stefano Mondino on 28/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

open class PluginLayoutAttributes: UICollectionViewLayoutAttributes {
    /**
     Anchor point is the relative position used to calculate the tilt transformation of the cell.
     
     `func apply(_ layoutAttributes: UICollectionViewLayoutAttributes)` method to pass the anchorPoint property
     to the cell layer.
     */
    public var anchorPoint = CGPoint(x: 0.5, y: 0.5)
    
    /**
        Percentage is the attribute position amount across collectionView's current visible rectangle.
     
        In a vertical scrolling layout, percentage.y value will be 0 when current attribute is at the top-most part of visible rectangle, and 1 at the bottom-most.
    */
    public var percentage: CGPoint = .zero
    
    /// Overridden for NSCopying compatibility
    override open func copy(with zone: NSZone? = nil) -> Any {
        guard let attribute = super.copy(with: zone) as? PluginLayoutAttributes else { return self }
        attribute.anchorPoint = self.anchorPoint
        attribute.percentage = self.percentage
        return attribute
        
    }
    
    /// Overridden for Equatable compatibility
    override open func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? PluginLayoutAttributes,
            object.anchorPoint == self.anchorPoint,
            object.percentage == self.percentage
            else {
                return false
        }
        return super.isEqual(object)
    }
}
