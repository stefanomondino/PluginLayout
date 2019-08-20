//
//  HorizontalFlowRenderer.swift
//  PluginLayout
//
//  Created by Andrea Altea on 25/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

class HorizontalFlowCalculator: FlowLayoutCalculator {
    
    let layout: PluginLayout
    let parameters: FlowSectionParameters
    weak var delegate: FlowLayoutDelegate?
    let attributesClass: PluginLayoutAttributes.Type
    
    init(layout: PluginLayout, attributesClass: PluginLayoutAttributes.Type, delegate: FlowLayoutDelegate?, parameters: FlowSectionParameters) {
        self.layout = layout
        self.delegate = delegate
        self.parameters = parameters
        self.attributesClass = attributesClass
    }
    
    func calculateLayoutAttributes(offset: inout CGPoint, alignment: FlowLayoutAlignment) -> [PluginLayoutAttributes] {
        
        guard let collectionView = layout.collectionView else { return [] }
        
        //Please refer to vertical explanation (this is just a copy of it, flipped for horizontal flow)
        offset.x += self.parameters.insets.left
        var lineStart: CGFloat = offset.x
        var lineEnd = lineStart
        let lineMaxHeight = self.parameters.contentBounds.height - self.parameters.insets.top - self.parameters.insets.bottom
        
        offset.y = max(offset.y, self.parameters.contentBounds.height)
        
        let section = self.parameters.section

        //Accumulates attributes for last line.
        var lastLineAttributes: [PluginLayoutAttributes] = []

        let attributes = (0 ..< collectionView.numberOfItems(inSection: section))
            .map { item in IndexPath(item: item, section: section) }
            .reduce([]) { itemsAccumulator, indexPath -> [PluginLayoutAttributes] in
                let attribute = attributesClass.init(forCellWith: indexPath)
                let itemSize = self.itemSize(at: indexPath, collectionView: collectionView, layout: layout)
                let origin: CGPoint
                if let last = itemsAccumulator.last {
                    let y = last.frame.maxY + parameters.itemSpacing
                    if y + itemSize.height + parameters.insets.bottom > parameters.contentBounds.height {
                        origin = CGPoint(x: lineEnd + parameters.lineSpacing, y: parameters.insets.top )
                        
                        realignAttibutes(lastLineAttributes, inAvailableHeight: lineMaxHeight, alignment: alignment, insets: parameters.insets)
                        lastLineAttributes = [attribute]
                        lineStart = origin.x
                    } else {
                        lastLineAttributes += [attribute]
                        origin = CGPoint(x: lineStart, y: y)
                    }
                } else {
                    lastLineAttributes += [attribute]
                    origin = CGPoint(x: lineEnd, y: parameters.insets.top)
                }
                attribute.frame = CGRect(origin: origin, size: itemSize)
                if attribute.frame.minX > lineStart {
                    lineStart = attribute.frame.minX
                }
                if attribute.frame.maxX > lineEnd {
                    lineEnd = attribute.frame.maxX
                }
                
                return  itemsAccumulator + [attribute]
        }
        
        if alignment != .default {
            realignAttibutes(lastLineAttributes, inAvailableHeight: lineMaxHeight, alignment: alignment, insets: parameters.insets)
        }
        offset.x = lineEnd + parameters.insets.right
        return attributes
    }
    
    func itemSize(at indexPath: IndexPath, collectionView: UICollectionView, layout: PluginLayout) -> CGSize {
        return delegate?.collectionView?(collectionView, layout: layout, sizeForItemAt: indexPath) ?? .zero
    }
}
