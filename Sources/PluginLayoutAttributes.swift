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

extension Array where Element: PluginLayoutAttributes {
    func filter(in rect: CGRect, scrollDirection: UICollectionView.ScrollDirection) -> [PluginLayoutAttributes] {
        guard let lastIndex = self.indices.last,
            let firstMatchIndex = binarySearch(rect, start: 0, end: lastIndex, values: self, direction: scrollDirection)
            else {
                return []
        }
        var values: [PluginLayoutAttributes] = []
        for attributes in self[..<firstMatchIndex].reversed() {
            let condition: Bool
            switch scrollDirection {
            case .horizontal: condition = attributes.frame.maxX >= rect.minX
            case .vertical: condition =  attributes.frame.maxY >= rect.minY
            @unknown default: condition = false
            }
            guard condition else {
                break
            }
            values.append(attributes)
        }
        for attributes in self[firstMatchIndex...] {
            let condition: Bool
            switch scrollDirection {
            case .horizontal: condition = attributes.frame.minX <= rect.maxX
            case .vertical: condition =  attributes.frame.minY <= rect.maxY
            @unknown default: condition = false
            }
            guard condition else {
                break
            }
            
            values.append(attributes)
        }
        return values
    }
    
    private func binarySearch(_ rect: CGRect, start: Int, end: Int, values: [PluginLayoutAttributes], direction: UICollectionView.ScrollDirection) -> Int? {
        guard end >= start else {
            return nil
        }
        let mid = (start + end) / 2
        let attribute = values[mid]
        
        if attribute.frame.intersects(rect) {
            return mid
        } else {
            let condition: Bool
            switch direction {
            case .horizontal: condition = attribute.frame.maxX < rect.minX
            case .vertical: condition =  attribute.frame.maxY < rect.minY
            @unknown default: condition = false
            }
            if condition {
                return binarySearch(rect, start: (mid + 1), end: end, values: values, direction: direction)
            } else {
                return binarySearch(rect, start: start, end: (mid - 1), values: values, direction: direction)
            }
        }
    }
}
