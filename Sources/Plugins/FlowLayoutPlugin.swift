//
//  FlowLayoutPlugin.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import Foundation
import UIKit

open class FlowLayoutPlugin: Plugin {
    public private(set) weak var delegate: UICollectionViewDelegateFlowLayout?
    public init(delegate: UICollectionViewDelegateFlowLayout) {
        self.delegate = delegate
    }
    public func layoutAttributes(in section: Int, offset: inout CGPoint, layout: PluginLayout) -> [UICollectionViewLayoutAttributes] {
        
        guard let collectionView = layout.collectionView,
            let delegate = delegate else { return [] }
        let insets = delegate.collectionView?(collectionView, layout: layout, insetForSectionAt: section) ?? .zero
        let itemSpacing = delegate.collectionView?(collectionView, layout: layout, minimumInteritemSpacingForSectionAt: section) ?? 0
        let lineSpacing = delegate.collectionView?(collectionView, layout: layout, minimumLineSpacingForSectionAt: section) ?? 0
        
        var header: UICollectionViewLayoutAttributes?
        var footer: UICollectionViewLayoutAttributes?
        
        if let headerSize = delegate.collectionView?(collectionView, layout: layout, referenceSizeForHeaderInSection: section),
            headerSize.height > 0 {
            header = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: section))
            header?.frame = CGRect(origin: CGPoint(x: 0, y: offset.y), size: headerSize)
            offset.y += headerSize.height
        }
        
        offset.y += insets.top
        var lineTop: CGFloat = offset.y
        var lineBottom = lineTop
        let contentBounds = collectionView.frame.inset(by: collectionView.contentInset)
        offset.x = max(offset.x, contentBounds.width)
        
       
        let attributes: [UICollectionViewLayoutAttributes] = (0..<collectionView.numberOfItems(inSection: section))
            .map { item in IndexPath(item: item, section: section) }
            .reduce([]) { itemsAccumulator, indexPath -> [UICollectionViewLayoutAttributes] in
                let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                let itemSize = self.itemSize(at: indexPath, collectionView: collectionView, layout: layout)
                let origin: CGPoint
                if let last = itemsAccumulator.last {
                    let x = last.frame.maxX + itemSpacing
                    if x + itemSize.width + insets.right > contentBounds.width {
                        origin = CGPoint(x: insets.left, y: lineBottom + lineSpacing)
                        lineTop = origin.y
                    } else {
                        origin = CGPoint(x: x, y: lineTop)
                    }
                } else {
                    origin = CGPoint(x: insets.left, y: lineBottom)
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
        
        offset.y = lineBottom + insets.bottom
    
        if let footerSize = delegate.collectionView?(collectionView, layout: layout, referenceSizeForFooterInSection: section),
            footerSize.height > 0 {
            footer = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: IndexPath(item: 0, section: section))
            footer?.frame = CGRect(origin: CGPoint(x: 0, y: offset.y), size: footerSize)
            offset.y += footerSize.height
        }
        return ([header] + attributes + [footer]).compactMap { $0 }
        
    }
    open func itemSize(at indexPath: IndexPath, collectionView: UICollectionView, layout: PluginLayout) -> CGSize {
        return delegate?.collectionView?(collectionView, layout: layout, sizeForItemAt: indexPath) ?? .zero
    }
    
    
}
