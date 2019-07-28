//
//  VerticalFlowRenderer.swift
//  PluginLayout
//
//  Created by Andrea Altea on 25/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

class VerticalFlowCalculator: LayoutCalculator {
    
    
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
        
        //Offset should be incremented by insets top, to create padding between header (if present) or previous section.
        
        offset.y += self.parameters.insets.top
        
        //First line should start from current offset. It's the proper point (y) where the new attribute's origin should be placed
        var lineStart: CGFloat = offset.y
        
        //This is the highest point (y) reached by every attribute in current section
        //At the beginning, since no attribute has been evaluated yet, this should be equal to lineStart
        var lineEnd = lineStart
        
        /*  Since layout is vertical, we need to "inflate" the offset horizontally.
         This plugin handles line that have same width as encapsulating collection view, but other plugins previously evaluated could have inflated
         the layout to higher values. For this reason, we are keeping that value if already bigger than bounds, otherwise we are inflating it.
         */
        offset.x = max(offset.x, self.parameters.contentBounds.width)
        
        //Maximum width of each line. Should take into account section insets.
        let lineMaxWidth = self.parameters.contentBounds.width - self.parameters.insets.left - self.parameters.insets.right
        
        //Accumulates attributes for last line.
        var lastLineAttributes: [PluginLayoutAttributes] = []

        //Iterate through all items in current section
        let attributes = (0..<collectionView.numberOfItems(inSection: self.parameters.section))
            //convert each item into an IndexPath
            .map { item in IndexPath(item: item, section: self.parameters.section) }
            //We use reduce to have access to last attribute's values
            .reduce([]) { itemsAccumulator, indexPath -> [PluginLayoutAttributes] in
                //Create new attribute
                let attribute = attributesClass.init(forCellWith: indexPath)
                //Fetch attribute's size
                let itemSize = self.itemSize(at: indexPath, collectionView: collectionView, layout: self.layout)
                let origin: CGPoint
                //If a previous item exists (from second item in iteration on)
                if let last = itemsAccumulator.last {
                    //Desired starting x of freshly created item
                    let x = last.frame.maxX + self.parameters.itemSpacing
                    //If placing this item at desired x would cause item itself to overflow collection view bounds, create a new line
                    if x + itemSize.width + self.parameters.insets.right > self.parameters.contentBounds.width {
                        //Take all previous line attributes and re-space them
                        realignAttibutes(lastLineAttributes, inAvailableWidth: lineMaxWidth, alignment: alignment)
                        //Recreate the line array with new attribute
                        lastLineAttributes = [attribute]
                        //Place new attribute's origin on a new line.
                        origin = CGPoint(x: parameters.insets.left, y: lineEnd + parameters.lineSpacing)
                        //Update the current lineStart value
                        lineStart = origin.y
                    } else {
                        //We have space on current line, so we just update it with current attribute
                        lastLineAttributes += [attribute]
                        origin = CGPoint(x: x, y: lineStart)
                    }
                } else {
                    //This is the first item in this section
                    lastLineAttributes += [attribute]
                    //Start from insets. Line start or end is the same in this case.
                    origin = CGPoint(x: parameters.insets.left, y: lineEnd)
                }
                //Finally set attribute's frame
                attribute.frame = CGRect(origin: origin, size: itemSize)
                //If attribute is starting AFTER current line start
                if attribute.frame.minY > lineStart {
                    //Increase line start value to match the bottom-most item's origin
                    lineStart = attribute.frame.minY
                }
                //If attribute is ending AFTER current line end
                if attribute.frame.maxY > lineEnd {
                    //Increase line end to match the bottom-most item's origin + height
                    lineEnd = attribute.frame.maxY
                }
                //Append new item to the accumulator and proceed with iteration
                return  itemsAccumulator + [attribute]
        }
        
        //Realign last line. Note: UICollectionViewFlowLayout seems to NOT do this.
        if alignment != .default {
            realignAttibutes(lastLineAttributes, inAvailableWidth: lineMaxWidth, alignment: alignment)
        }
        
        //Update the offset with insets
        offset.y = lineEnd + parameters.insets.bottom
        return attributes
    }
    
    func itemSize(at indexPath: IndexPath, collectionView: UICollectionView, layout: PluginLayout) -> CGSize {
        return delegate?.collectionView?(collectionView, layout: layout, sizeForItemAt: indexPath) ?? .zero
    }
}

