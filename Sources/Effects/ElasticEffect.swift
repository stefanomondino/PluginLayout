//
//  ElasticEffect.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 26/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

public class ElasticEffect: PluginEffect {
    public let spacing: CGFloat
    public let span: CGFloat
    public init(spacing: CGFloat = 90, span: CGFloat = 200) {
        self.spacing = spacing
        self.span = span
    }
    public func apply(to originalAttribute: UICollectionViewLayoutAttributes, layout: PluginLayout) -> UICollectionViewLayoutAttributes {
        guard originalAttribute.representedElementKind == nil,
            let attribute = originalAttribute.copy() as? UICollectionViewLayoutAttributes else { return originalAttribute }
        let percentage = self.percentage(from: attribute, layout: layout, span: span)
        var frame = attribute.frame
        
        //Pow is for some naive easeout effect, to smooth out the acceleration as the item reaches final position.
        //To keep distances coherent with external spacing parameter, we have to root the spacing
        let power: CGFloat = 4
        let spacing: CGFloat = pow(self.spacing, 1/power)
        switch layout.scrollDirection {
        case .horizontal: frame.origin.x += pow(max(0, min((1 - percentage.x) * spacing, spacing)), power)
        case .vertical: frame.origin.y += pow(max(0, min((1 - percentage.y) * spacing, spacing)), power)
        @unknown default: break
        }
        attribute.frame = frame
        return attribute
    }
}

