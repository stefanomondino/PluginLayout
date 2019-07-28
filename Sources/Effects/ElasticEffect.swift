//
//  ElasticEffect.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 26/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit


public class ElasticEffect: PluginEffect {
    
    /**
     How much space must be left from previous item inside span at maximum distance value
     
     
    */
    public let spacing: CGFloat
    
    /**
     Total space available for the effect to take place.
     
     A span value of 200 in a vertical scrolling layout means that the appearing item has 200 points from collection view's bottom to counter-move back of `spacing` points to snap back to its original position.
     */
    public let span: CGFloat
    
    public init(spacing: CGFloat = 90, span: CGFloat = 200) {
        self.spacing = spacing
        self.span = span
    }
    
    public func apply(to originalAttribute: PluginLayoutAttributes, layout: PluginLayout, plugin: PluginType, sectionAttributes attributes: [PluginLayoutAttributes]) -> PluginLayoutAttributes {
        guard originalAttribute.representedElementKind == nil,
            let attribute = originalAttribute.copy() as? PluginLayoutAttributes else { return originalAttribute }
        let percentage = self.percentage(from: attribute, layout: layout, span: span)
        var frame = attribute.frame
        
        //Pow is for some naive easeout effect, to smooth out the acceleration as each item reaches final position.
        //To keep distances coherent with external spacing parameter, we have to root the spacing
        let power: CGFloat = 4
        let spacing: CGFloat = pow(self.spacing, 1/power)
        switch layout.scrollDirection {
        case .horizontal: frame.origin.x += pow(max(0, min((1 - percentage.x) * spacing, spacing)), power)
        case .vertical: frame.origin.y += pow(max(0, min((1 - percentage.y) * spacing, spacing)), power)
        @unknown default: break
        }
        attribute.frame = frame
        attribute.percentage = percentage
        return attribute
    }
}

