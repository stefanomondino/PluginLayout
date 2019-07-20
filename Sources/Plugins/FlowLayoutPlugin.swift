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
    
    public typealias Parameters = FlowSectionParameters
    public var sectionHeadersPinToVisibleBounds: Bool = false
    public var sectionFootersPinToVisibleBounds: Bool = false
    
    public private(set) weak var delegate: FlowLayoutDelegate?
    
    required public init(delegate: FlowLayoutDelegate) {
        self.delegate = delegate
    }
    
    public func layoutAttributes(in section: Int, offset: inout CGPoint, layout: PluginLayout) -> [UICollectionViewLayoutAttributes] {
        
        guard let collectionView = layout.collectionView else { return [] }
        
//        let insets = delegate.collectionView?(collectionView, layout: layout, insetForSectionAt: section) ?? .zero
//        let itemSpacing = delegate.collectionView?(collectionView, layout: layout, minimumInteritemSpacingForSectionAt: section) ?? 0
//        let lineSpacing = delegate.collectionView?(collectionView, layout: layout, minimumLineSpacingForSectionAt: section) ?? 0
//
        let sectionParameters = self.sectionParameters(inSection: section, layout: layout)
        
        let header: UICollectionViewLayoutAttributes? = self.header(in: section, offset: &offset, layout: layout)
        
        let attributes: [UICollectionViewLayoutAttributes]
        let contentBounds = layout.contentBounds
        
        var lineAttributes: [UICollectionViewLayoutAttributes] = []
        if layout.scrollDirection == .vertical {
            offset.y += sectionParameters.insets.top
            var lineTop: CGFloat = offset.y
            var lineBottom = lineTop
            offset.x = max(offset.x, contentBounds.width)
            let biggestWidth = contentBounds.width - sectionParameters.insets.left - sectionParameters.insets.right
            attributes = (0..<collectionView.numberOfItems(inSection: section))
                .map { item in IndexPath(item: item, section: section) }
                
                .reduce([]) { itemsAccumulator, indexPath -> [UICollectionViewLayoutAttributes] in
                    let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    let itemSize = self.itemSize(at: indexPath, collectionView: collectionView, layout: layout)
                    let origin: CGPoint
                    if let last = itemsAccumulator.last {
                        let x = last.frame.maxX + sectionParameters.itemSpacing
                        if x + itemSize.width + sectionParameters.insets.right > contentBounds.width {
                            realignAttibutes(lineAttributes, inAvailableWidth: biggestWidth)
                            lineAttributes = [attribute]
                            origin = CGPoint(x: sectionParameters.insets.left, y: lineBottom + sectionParameters.lineSpacing)
                            lineTop = origin.y
                        } else {
                            lineAttributes += [attribute]
                            origin = CGPoint(x: x, y: lineTop)
                        }
                    } else {
                        lineAttributes += [attribute]
                        origin = CGPoint(x: sectionParameters.insets.left, y: lineBottom)
                    }
                    attribute.frame = CGRect(origin: origin, size: itemSize)
                    if attribute.frame.minY > lineTop {
                        lineTop = attribute.frame.minY
                    }
                    if attribute.frame.maxY > lineBottom {
                        lineBottom = attribute.frame.maxY
                    }
                    
                    return  itemsAccumulator + [attribute]
            }
            realignAttibutes(lineAttributes, inAvailableWidth: biggestWidth)
            offset.y = lineBottom + sectionParameters.insets.bottom
        } else {
            offset.x += sectionParameters.insets.left
            var lineTop: CGFloat = offset.x
            var lineBottom = lineTop
            let biggestHeight = contentBounds.height - sectionParameters.insets.top - sectionParameters.insets.bottom
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
                            origin = CGPoint(x: lineBottom + sectionParameters.lineSpacing, y: sectionParameters.insets.top )

                            realignAttibutes(lineAttributes, inAvailableHeight: biggestHeight)
                            lineAttributes = [attribute]
                            lineTop = origin.x
                        } else {
                            lineAttributes += [attribute]
                            origin = CGPoint(x: lineTop, y: y)
                        }
                    } else {
                         lineAttributes += [attribute]
                        origin = CGPoint(x: lineBottom, y: sectionParameters.insets.top)
                    }
                    attribute.frame = CGRect(origin: origin, size: itemSize)
                    if attribute.frame.minX > lineTop {
                        lineTop = attribute.frame.minX
                    }
                    if attribute.frame.maxX > lineBottom {
                        lineBottom = attribute.frame.maxX
                    }
                    
                    return  itemsAccumulator + [attribute]
            }
            realignAttibutes(lineAttributes, inAvailableHeight: biggestHeight)
            offset.x = lineBottom + sectionParameters.insets.right
        }
        
        let footer: UICollectionViewLayoutAttributes? = self.footer(in: section, offset: &offset, layout: layout)
        return ([header] + attributes + [footer]).compactMap { $0 }
        
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
    public func layoutAttributesForElements(in rect: CGRect, from attributes: [UICollectionViewLayoutAttributes], section: Int, layout: PluginLayout) -> [UICollectionViewLayoutAttributes] {
        guard let collectionView = layout.collectionView,
            let delegate = delegate else { return [] }
        let defaultAttributes = attributes.filter { $0.frame.intersects(rect) }
        
        if sectionFootersPinToVisibleBounds == false && sectionHeadersPinToVisibleBounds == false { return defaultAttributes }
        
        let insets = delegate.collectionView?(collectionView, layout: layout, insetForSectionAt: section) ?? .zero
        let itemsRect = attributes
            .filter { $0.representedElementKind == nil }
            .map { $0.frame }
            .reduce(nil) { a, i -> CGRect in
            a?.union(i) ?? i
        } ?? .zero
        var supplementary: [UICollectionViewLayoutAttributes] = []
        
        if
            sectionHeadersPinToVisibleBounds == true,
            let header = attributes.filter ({ $0.representedElementKind == UICollectionView.elementKindSectionHeader }).first {
            var frame = header.frame
            switch layout.scrollDirection {
            case .horizontal: frame.origin.x = max(itemsRect.minX - frame.width - insets.left, min(itemsRect.maxX - frame.width, collectionView.contentOffset.x))
            default: frame.origin.y = max(itemsRect.minY - frame.height - insets.top, min(itemsRect.maxY - frame.height,collectionView.contentOffset.y))
            }
            
            header.zIndex = 900 + section + 1
            header.frame = frame
            supplementary += [header]
        }
        
        if
            sectionFootersPinToVisibleBounds == true,
            let footer = attributes.filter ({ $0.representedElementKind == UICollectionView.elementKindSectionFooter }).first {
            var frame = footer.frame
            switch layout.scrollDirection {
            case .horizontal: frame.origin.x = max(itemsRect.minX - insets.left, min(itemsRect.maxX + insets.right, collectionView.contentOffset.x + collectionView.bounds.width - frame.width ))
            default: frame.origin.y = max(itemsRect.minY - insets.top, min(itemsRect.maxY + insets.bottom, collectionView.contentOffset.y + collectionView.bounds.height - frame.height ))
            }
            
            print (rect)
            footer.zIndex = 900 + section
            footer.frame = frame
            supplementary += [footer]
        }
        
        return defaultAttributes + supplementary
    }
    
    open func itemSize(at indexPath: IndexPath, collectionView: UICollectionView, layout: PluginLayout) -> CGSize {
        return delegate?.collectionView?(collectionView, layout: layout, sizeForItemAt: indexPath) ?? .zero
    }
}
