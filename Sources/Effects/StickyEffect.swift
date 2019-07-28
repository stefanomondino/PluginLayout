//
//  StickyEffect.swift
//  Example
//
//  Created by Stefano Mondino on 27/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

public class StickyEffect: PluginEffect {
    public enum Position {
        case start
        case end
    }
    public let position: Position
    
    public convenience init? (kind: String) {
        let position: Position
        switch kind {
        case UICollectionView.elementKindSectionHeader: position = .start
        case UICollectionView.elementKindSectionFooter: position = .end
        default: return nil
        }
        self.init(position: position)
    }
    public init(position: Position) {
        self.position = position
    }
    
    public func apply(to originalAttribute: PluginLayoutAttributes, layout: PluginLayout, plugin: PluginType, sectionAttributes attributes: [PluginLayoutAttributes]) -> PluginLayoutAttributes {
        guard let collectionView = layout.collectionView,
        let attribute = originalAttribute.copy() as? PluginLayoutAttributes else { return originalAttribute }
        let section = originalAttribute.indexPath.section
        
        let insets = (collectionView.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: layout, insetForSectionAt: section) ?? .zero
        let sectionParameters = FlowSectionParameters(section: section, insets: insets, contentBounds: .zero)

        let safeArea: UIEdgeInsets
        if #available(iOS 11.0, *) {
            safeArea = collectionView.adjustedContentInset
        } else {
            safeArea = .zero
        }
        
        let itemsRect = attributes
            .filter { $0.representedElementKind == nil }
            .map { $0.frame }
            .reduce(nil) { a, i -> CGRect in
                a?.union(i) ?? i
            } ?? .zero
        switch position {
        case .start:
            
            var frame = attribute.frame
            
            switch layout.scrollDirection {
            case .horizontal: frame.origin.x = max(itemsRect.minX - frame.width - sectionParameters.insets.left, min(itemsRect.maxX - frame.width, collectionView.contentOffset.x + safeArea.left))
            default: frame.origin.y = max(itemsRect.minY - frame.height - sectionParameters.insets.top, min(itemsRect.maxY - frame.height, collectionView.contentOffset.y + safeArea.top))
            }
            
            attribute.zIndex = 900 + section + 1
            attribute.frame = frame
            return attribute
        case .end:
            
            var frame = attribute.frame
            switch layout.scrollDirection {
            case .horizontal: frame.origin.x = max(itemsRect.minX - sectionParameters.insets.left, min(itemsRect.maxX + sectionParameters.insets.right, collectionView.contentOffset.x + collectionView.bounds.width - frame.width - safeArea.right ))
            default: frame.origin.y = max(itemsRect.minY - sectionParameters.insets.top, min(itemsRect.maxY + sectionParameters.insets.bottom, collectionView.contentOffset.y + collectionView.bounds.height - frame.height - safeArea.bottom ))
            }
            
            attribute.zIndex = 900 + section
            attribute.frame = frame
            return attribute
        }
        return originalAttribute
    }
    
    
    
    
}
