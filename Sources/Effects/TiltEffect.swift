//
//  TiltEffect.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 26/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

//Currently not working properly
public class TiltEffect: PluginEffect {
    
    public init() {}
    
    public func apply(to originalAttribute: PluginLayoutAttributes, layout: PluginLayout) -> PluginLayoutAttributes {
        guard originalAttribute.representedElementKind == nil else { return originalAttribute }
        guard let attribute = originalAttribute.copy() as? PluginLayoutAttributes else { return originalAttribute }
        let offset = layout.collectionView?.contentOffset.y ?? 0
        let height = (layout.collectionView?.bounds.height ?? 0)
        let percentage = 1 - (offset - attribute.frame.minY + height) / (height - attribute.frame.height)
        var transform = CATransform3DMakeRotation(-CGFloat.pi * max(0, min(1, percentage)) / 3.0, 1, 0, 0)
        transform.m34 = 1/2000
        attribute.transform3D = transform
        return attribute
    }
}
