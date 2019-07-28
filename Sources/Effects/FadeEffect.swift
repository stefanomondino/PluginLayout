//
//  FadeEffect.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 25/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit
/**
 Fades in attributes from min to 1 when attribute's position is between bottom-most/right-most collection view bounds and span.
*/
public class FadeEffect: PluginEffect {
    
    public let span: CGFloat
    
    public init(span: CGFloat = 200.0) {
        self.span = span
    }
    
    public func apply(to originalAttribute: PluginLayoutAttributes, layout: PluginLayout, plugin: PluginType, sectionAttributes attributes: [PluginLayoutAttributes]) -> PluginLayoutAttributes {
        guard originalAttribute.representedElementKind == nil else { return originalAttribute }
        guard
            let collectionView = layout.collectionView,
            let attribute = originalAttribute.copy() as? PluginLayoutAttributes else { return originalAttribute }
        let offset: CGFloat = collectionView.contentOffset.y
        
        let height = collectionView.bounds.height
        let percentage = (offset - attribute.frame.origin.y + height ) / span

        attribute.alpha = percentage
        return attribute
    }
}
