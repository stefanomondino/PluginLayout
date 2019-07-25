//
//  HorizontalFlowRenderer.swift
//  PluginLayout
//
//  Created by Andrea Altea on 25/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

class HorizontalFlowRenderer: FlowRenderer {
    
    var collectionView: UICollectionView
    var layout: PluginLayout
    var delegate: FlowLayoutDelegate?
    var parameters: FlowSectionParameters
    
    init(collectionView: UICollectionView, layout: PluginLayout, delegate: FlowLayoutDelegate?, parameters: FlowSectionParameters) {
        self.collectionView = collectionView
        self.layout = layout
        self.delegate = delegate
        self.parameters = parameters
    }
    
    func renderItems(offset: inout CGPoint, alignment: FlowLayoutAlignment) -> [UICollectionViewLayoutAttributes] {
        //Please refer to vertical explanation (this is just a copy of it, flipped for horizontal flow)
        offset.x += self.parameters.insets.left
        var lineStart: CGFloat = offset.x
        var lineEnd = lineStart
        let lineMaxHeight = self.parameters.contentBounds.height - self.parameters.insets.top - self.parameters.insets.bottom
        offset.y = max(offset.y, self.parameters.contentBounds.height)
        
        let section = self.parameters.section

        //Accumulates attributes for last line.
        var lastLineAttributes: [UICollectionViewLayoutAttributes] = []

        let attributes = (0 ..< self.collectionView.numberOfItems(inSection: section))
            .map { item in IndexPath(item: item, section: section) }
            .reduce([]) { itemsAccumulator, indexPath -> [UICollectionViewLayoutAttributes] in
                let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                let itemSize = self.itemSize(at: indexPath, collectionView: collectionView, layout: layout)
                let origin: CGPoint
                if let last = itemsAccumulator.last {
                    let y = last.frame.maxY + parameters.itemSpacing
                    if y + itemSize.height + parameters.insets.bottom > parameters.contentBounds.height {
                        origin = CGPoint(x: lineEnd + parameters.lineSpacing, y: parameters.insets.top )
                        
                        realignAttibutes(lastLineAttributes, inAvailableHeight: lineMaxHeight, alignment: alignment)
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
            realignAttibutes(lastLineAttributes, inAvailableHeight: lineMaxHeight, alignment: alignment)
        }
        offset.x = lineEnd + parameters.insets.right
        return attributes
    }
    
    func itemSize(at indexPath: IndexPath, collectionView: UICollectionView, layout: PluginLayout) -> CGSize {
        return delegate?.collectionView?(collectionView, layout: layout, sizeForItemAt: indexPath) ?? .zero
    }
}

