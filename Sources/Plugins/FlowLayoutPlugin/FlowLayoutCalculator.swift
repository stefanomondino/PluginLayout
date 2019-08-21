//
//  FlowRenderer.swift
//  PluginLayout
//
//  Created by Andrea Altea on 25/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

protocol FlowLayoutCalculator {
    func calculateLayoutAttributes(offset: inout CGPoint, alignment: FlowLayoutAlignment) -> [PluginLayoutAttributes]
}

extension FlowLayoutCalculator {
    func realignAttibutes(_ attributes: [PluginLayoutAttributes], inAvailableWidth width: CGFloat, alignment: FlowLayoutAlignment, insets: UIEdgeInsets) {
        let maxX = attributes.map { $0.frame.maxX }.sorted(by: >).first ?? width
        let maxY = attributes.map { $0.frame.maxY }.sorted(by: >).first ?? 0
        let totalDelta = width - maxX + insets.left
        let singleSpacing = totalDelta / CGFloat(max(1, attributes.count - 1))
        attributes.enumerated().forEach { tuple in
            let (index, attribute) = tuple
            var f = attribute.frame
            switch alignment {
            case .start: break
            case .center: f.origin.x += totalDelta / 2
            case .end: f.origin.x += totalDelta
            default:
                if attributes.count < 2 {
                    f.origin.x += totalDelta / 2
                } else {
                    f.origin.x += CGFloat(index) * singleSpacing
                }
            }
            
            f.origin.y += (maxY - f.maxY) / 2
            attribute.frame = f
        }
    }
    
    func realignAttibutes(_ attributes: [PluginLayoutAttributes], inAvailableHeight height: CGFloat, alignment: FlowLayoutAlignment, insets: UIEdgeInsets) {
        let maxX = attributes.map { $0.frame.maxX }.sorted(by: >).first ?? 0
        let maxY = attributes.map { $0.frame.maxY }.sorted(by: >).first ?? height
        let totalDelta = height - maxY + insets.top
        
        let singleSpacing = totalDelta / CGFloat(max(1, attributes.count - 1))
        attributes.enumerated().forEach { tuple in
            let (index, attribute) = tuple
            var f = attribute.frame
            
            f.origin.x += (maxX - f.maxX) / 2
            switch alignment {
            case .start: break
            case .center: f.origin.y += totalDelta / 2
            case .end: f.origin.y += totalDelta
            default:
                if attributes.count < 2 {
                    f.origin.y += totalDelta / 2
                } else {
                    f.origin.y += CGFloat(index) * singleSpacing
                }
            }
            attribute.frame = f
        }
    }
}
