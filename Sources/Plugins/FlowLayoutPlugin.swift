//
//  FlowLayoutPlugin.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import Foundation
import UIKit

public typealias FlowLayoutDelegate = UICollectionViewDelegateFlowLayout

open class FlowSectionParameters: SectionParameters {
    public let insets: UIEdgeInsets
    public let itemSpacing: CGFloat
    public let lineSpacing: CGFloat
    
    public init(insets: UIEdgeInsets = .zero, itemSpacing: CGFloat = 0, lineSpacing: CGFloat = 0) {
        self.insets = insets
        self.itemSpacing = itemSpacing
        self.lineSpacing = lineSpacing
        
    }
}

extension PluginLayout {
    var contentBounds: CGRect {
        guard let collectionView = self.collectionView else { return .zero }
        return collectionView.frame.inset(by: collectionView.contentInset)
    }
}

public enum FlowLayoutAlignment: Int {
    case start
    case center
    case end
    case `default`
}

open class FlowLayoutPlugin: Plugin {
    public typealias Delegate = FlowLayoutDelegate
    public typealias Parameters = FlowSectionParameters
    
    public var sectionHeadersPinToVisibleBounds: Bool = false
    public var sectionFootersPinToVisibleBounds: Bool = false
    
    public var alignment: FlowLayoutAlignment = .default
    
    public private(set) weak var delegate: FlowLayoutDelegate?
    
    required public init(delegate: Delegate) {
        self.delegate = delegate
    }
    
    convenience public init(delegate: Delegate, pinSectionHeaders: Bool, pinSectionFooters: Bool, alignment: FlowLayoutAlignment = .default) {
        self.init(delegate: delegate)
        self.sectionHeadersPinToVisibleBounds = pinSectionHeaders
        self.sectionFootersPinToVisibleBounds = pinSectionFooters
        self.alignment = alignment
    }
    
    public func layoutAttributes(in section: Int, offset: inout CGPoint, layout: PluginLayout) -> [UICollectionViewLayoutAttributes] {
        
        guard let collectionView = layout.collectionView else { return [] }
        
        let sectionParameters = self.sectionParameters(inSection: section, layout: layout)
        
        //Create the header if available
        let header: UICollectionViewLayoutAttributes? = self.header(in: section, offset: &offset, layout: layout)
        
        let attributes: [UICollectionViewLayoutAttributes]
        let contentBounds = layout.contentBounds
        
        //Accumulates attributes for last line.
        var lastLineAttributes: [UICollectionViewLayoutAttributes] = []
        
        if layout.scrollDirection == .vertical {
            //Offset should be incremented by insets top, to create padding between header (if present) or previous section.
            offset.y += sectionParameters.insets.top
            
            //First line should start from current offset. It's the proper point (y) where the new attribute's origin should be placed
            var lineStart: CGFloat = offset.y
            
            //This is the highest point (y) reached by every attribute in current section
            //At the beginning, since no attribute has been evaluated yet, this should be equal to lineStart
            var lineEnd = lineStart
            
            /*  Since layout is vertical, we need to "inflate" the offset horizontally.
             This plugin handles line that have same width as encapsulating collection view, but other plugins previously evaluated could have inflated
             the layout to higher values. For this reason, we are keeping that value if already bigger than bounds, otherwise we are inflating it.
             */
            offset.x = max(offset.x, contentBounds.width)
            
            //Maximum width of each line. Should take into account section insets.
            let lineMaxWidth = contentBounds.width - sectionParameters.insets.left - sectionParameters.insets.right
            
            //Iterate through all items in current section
            attributes = (0..<collectionView.numberOfItems(inSection: section))
                //convert each item into an IndexPath
                .map { item in IndexPath(item: item, section: section) }
                //We use reduce to have access to last attribute's values
                .reduce([]) { itemsAccumulator, indexPath -> [UICollectionViewLayoutAttributes] in
                    //Create new attribute
                    let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    //Fetch attribute's size
                    let itemSize = self.itemSize(at: indexPath, collectionView: collectionView, layout: layout)
                    let origin: CGPoint
                    //If a previous item exists (from second item in iteration on)
                    if let last = itemsAccumulator.last {
                        //Desired starting x of freshly created item
                        let x = last.frame.maxX + sectionParameters.itemSpacing
                        //If placing this item at desired x would cause item itself to overflow collection view bounds, create a new line
                        if x + itemSize.width + sectionParameters.insets.right > contentBounds.width {
                            //Take all previous line attributes and re-space them
                            realignAttibutes(lastLineAttributes, inAvailableWidth: lineMaxWidth)
                            //Recreate the line array with new attribute
                            lastLineAttributes = [attribute]
                            //Place new attribute's origin on a new line.
                            origin = CGPoint(x: sectionParameters.insets.left, y: lineEnd + sectionParameters.lineSpacing)
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
                        origin = CGPoint(x: sectionParameters.insets.left, y: lineEnd)
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
                realignAttibutes(lastLineAttributes, inAvailableWidth: lineMaxWidth)
            }
            
            //Update the offset with insets
            offset.y = lineEnd + sectionParameters.insets.bottom
        } else {
            //Please refer to vertical explanation (this is just a copy of it, flipped for horizontal flow)
            offset.x += sectionParameters.insets.left
            var lineStart: CGFloat = offset.x
            var lineEnd = lineStart
            let lineMaxHeight = contentBounds.height - sectionParameters.insets.top - sectionParameters.insets.bottom
            offset.y = max(offset.y, contentBounds.height)
            
            attributes = (0..<collectionView.numberOfItems(inSection: section))
                .map { item in IndexPath(item: item, section: section) }
                .reduce([]) { itemsAccumulator, indexPath -> [UICollectionViewLayoutAttributes] in
                    let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    let itemSize = self.itemSize(at: indexPath, collectionView: collectionView, layout: layout)
                    let origin: CGPoint
                    if let last = itemsAccumulator.last {
                        let y = last.frame.maxY + sectionParameters.itemSpacing
                        if y + itemSize.height + sectionParameters.insets.bottom > contentBounds.height {
                            origin = CGPoint(x: lineEnd + sectionParameters.lineSpacing, y: sectionParameters.insets.top )
                            
                            realignAttibutes(lastLineAttributes, inAvailableHeight: lineMaxHeight)
                            lastLineAttributes = [attribute]
                            lineStart = origin.x
                        } else {
                            lastLineAttributes += [attribute]
                            origin = CGPoint(x: lineStart, y: y)
                        }
                    } else {
                        lastLineAttributes += [attribute]
                        origin = CGPoint(x: lineEnd, y: sectionParameters.insets.top)
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
                realignAttibutes(lastLineAttributes, inAvailableHeight: lineMaxHeight)
            }
            offset.x = lineEnd + sectionParameters.insets.right
        }
        //Create a footer if possible
        let footer: UICollectionViewLayoutAttributes? = self.footer(in: section, offset: &offset, layout: layout)
        //Return header + attributes + footer. If header or footer are not available (== nil), compactMap strips them away
        return ([header] + attributes + [footer]).compactMap { $0 }
        
    }
    
    
    public func layoutAttributesForElements(in rect: CGRect, from attributes: [UICollectionViewLayoutAttributes], section: Int, layout: PluginLayout) -> [UICollectionViewLayoutAttributes] {
        
        let defaultAttributes = attributes.filter { $0.frame.intersects(rect) }
        
        if sectionFootersPinToVisibleBounds == false && sectionHeadersPinToVisibleBounds == false { return defaultAttributes }
        
        let supplementary: [UICollectionViewLayoutAttributes] = pinSectionHeadersAndFooters(from: attributes, layout: layout, section: section)
        
        return defaultAttributes + supplementary
    }
    
    open func itemSize(at indexPath: IndexPath, collectionView: UICollectionView, layout: PluginLayout) -> CGSize {
        return delegate?.collectionView?(collectionView, layout: layout, sizeForItemAt: indexPath) ?? .zero
    }
    
    private func realignAttibutes(_ attributes: [UICollectionViewLayoutAttributes], inAvailableHeight height: CGFloat ) {
        let maxX = attributes.map { $0.frame.maxX }.sorted(by: >).first ?? 0
        let maxY = attributes.map { $0.frame.maxY }.sorted(by: >).first ?? height
        let totalDelta = height - maxY
        
        let singleSpacing = totalDelta / CGFloat(max(1,attributes.count - 1))
        attributes.enumerated().forEach { tuple in
            let (index, attribute) = tuple
            var f = attribute.frame
            
            f.origin.x += (maxX - f.maxX) / 2
            switch self.alignment {
            case .start: break
            case .center: f.origin.y += (height - maxY) / 2
            case .end: f.origin.y += (height - maxY)
            default:
                if attributes.count < 2 {
                    f.origin.y += (height - maxY) / 2
                } else {
                    f.origin.y += CGFloat(index) * singleSpacing 
                }
            }
            attribute.frame = f
        }
    }
    
    private func realignAttibutes(_ attributes: [UICollectionViewLayoutAttributes], inAvailableWidth width: CGFloat ) {
        let maxX = attributes.map { $0.frame.maxX }.sorted(by: >).first ?? width
        let maxY = attributes.map { $0.frame.maxY }.sorted(by: >).first ?? 0
        let totalDelta = width - maxX
        let singleSpacing = totalDelta / CGFloat(max(1,attributes.count - 1))
        attributes.enumerated().forEach { tuple in
            let (index, attribute) = tuple
            var f = attribute.frame
            switch self.alignment {
            case .start: break
            case .center: f.origin.x += (width - maxX) / 2
            case .end: f.origin.x += (width - maxX)
            default:
                if attributes.count < 2 {
                    f.origin.x += (width - maxX) / 2
                } else {
                    f.origin.x += CGFloat(index) * singleSpacing
                }
            }
            
            f.origin.y += (maxY - f.maxY) / 2
            attribute.frame = f
        }
    }
    
}
