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

open class FlowLayoutPlugin: Plugin {
    public typealias Delegate = FlowLayoutDelegate
    public typealias Parameters = FlowSectionParameters
    public var sectionHeadersPinToVisibleBounds: Bool = false
    public var sectionFootersPinToVisibleBounds: Bool = false
    
    public private(set) weak var delegate: FlowLayoutDelegate?
    
    required public init(delegate: Delegate) {
        self.delegate = delegate
    }
    
    convenience public init(delegate: Delegate, pinSectionHeaders: Bool, pinSectionFooters: Bool) {
        self.init(delegate: delegate)
        self.sectionHeadersPinToVisibleBounds = pinSectionHeaders
        self.sectionFootersPinToVisibleBounds = pinSectionFooters
    }
    
    public func layoutAttributes(in section: Int, offset: inout CGPoint, layout: PluginLayout) -> [UICollectionViewLayoutAttributes] {
        
        guard let collectionView = layout.collectionView else { return [] }

        let sectionParameters = self.sectionParameters(inSection: section, layout: layout)
        
        let header: UICollectionViewLayoutAttributes? = self.header(in: section, offset: &offset, layout: layout)
        
        let attributes: [UICollectionViewLayoutAttributes]
        let contentBounds = layout.contentBounds
        
        var lastLineAttributes: [UICollectionViewLayoutAttributes] = []
        
        if layout.scrollDirection == .vertical {
            offset.y += sectionParameters.insets.top
            var lineStart: CGFloat = offset.y
            var lineEnd = lineStart
            offset.x = max(offset.x, contentBounds.width)
            let lineMaxWidth = contentBounds.width - sectionParameters.insets.left - sectionParameters.insets.right
            attributes = (0..<collectionView.numberOfItems(inSection: section))
                .map { item in IndexPath(item: item, section: section) }
                
                .reduce([]) { itemsAccumulator, indexPath -> [UICollectionViewLayoutAttributes] in
                    let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    let itemSize = self.itemSize(at: indexPath, collectionView: collectionView, layout: layout)
                    let origin: CGPoint
                    if let last = itemsAccumulator.last {
                        let x = last.frame.maxX + sectionParameters.itemSpacing
                        if x + itemSize.width + sectionParameters.insets.right > contentBounds.width {
                            realignAttibutes(lastLineAttributes, inAvailableWidth: lineMaxWidth)
                            lastLineAttributes = [attribute]
                            origin = CGPoint(x: sectionParameters.insets.left, y: lineEnd + sectionParameters.lineSpacing)
                            lineStart = origin.y
                        } else {
                            lastLineAttributes += [attribute]
                            origin = CGPoint(x: x, y: lineStart)
                        }
                    } else {
                        lastLineAttributes += [attribute]
                        origin = CGPoint(x: sectionParameters.insets.left, y: lineEnd)
                    }
                    attribute.frame = CGRect(origin: origin, size: itemSize)
                    if attribute.frame.minY > lineStart {
                        lineStart = attribute.frame.minY
                    }
                    if attribute.frame.maxY > lineEnd {
                        lineEnd = attribute.frame.maxY
                    }
                    
                    return  itemsAccumulator + [attribute]
            }
            realignAttibutes(lastLineAttributes, inAvailableWidth: lineMaxWidth)
            offset.y = lineEnd + sectionParameters.insets.bottom
        } else {
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
            realignAttibutes(lastLineAttributes, inAvailableHeight: lineMaxHeight)
            offset.x = lineEnd + sectionParameters.insets.right
        }
        
        let footer: UICollectionViewLayoutAttributes? = self.footer(in: section, offset: &offset, layout: layout)
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
        attributes.forEach {
            var f = $0.frame
            f.origin.x += (maxX - f.maxX) / 2
            f.origin.y += (height - maxY) / 2
            $0.frame = f
        }
    }
    
    private func realignAttibutes(_ attributes: [UICollectionViewLayoutAttributes], inAvailableWidth width: CGFloat ) {
        let maxX = attributes.map { $0.frame.maxX }.sorted(by: >).first ?? width
        let maxY = attributes.map { $0.frame.maxY }.sorted(by: >).first ?? 0
        attributes.forEach {
            var f = $0.frame
            f.origin.x += (width - maxX) / 2
            f.origin.y += (maxY - f.maxY) / 2
            $0.frame = f
        }
    }

}
