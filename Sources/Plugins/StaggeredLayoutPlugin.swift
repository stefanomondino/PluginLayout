//
//  GridLayoutPlugin.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import Foundation
import UIKit

public protocol StaggeredLayoutDelegate: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, columnsForSectionAt section: Int) -> Int
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, aspectRatioAt indexPath: IndexPath) -> CGFloat
}

open class StaggeredLayoutPlugin: Plugin {
    public func layoutAttributes(in section: Int, offset: inout CGPoint, layout: PluginLayout) -> [UICollectionViewLayoutAttributes] {
        
        guard let collectionView = layout.collectionView,
            let delegate = delegate else { return [] }
        let columns = delegate.collectionView(collectionView, layout: layout, columnsForSectionAt: section)
        let insets = delegate.collectionView?(collectionView, layout: layout, insetForSectionAt: section) ?? .zero
        let itemSpacing = delegate.collectionView?(collectionView, layout: layout, minimumInteritemSpacingForSectionAt: section) ?? 0
        let lineSpacing = delegate.collectionView?(collectionView, layout: layout, minimumLineSpacingForSectionAt: section) ?? 0
        offset.y += insets.top
        //var lineTop: [CGFloat] = (0..<columns).map { _ in offset.y }
        var lineBottom = (0..<columns).map { _ in offset.y }
        let contentBounds = collectionView.frame.inset(by: collectionView.contentInset)
        offset.x = max(offset.x, contentBounds.width)
        var currentColumn = 0
        let attributes: [UICollectionViewLayoutAttributes] = (0..<collectionView.numberOfItems(inSection: section))
            .map { item in IndexPath(item: item, section: section) }
            .reduce([]) { itemsAccumulator, indexPath -> [UICollectionViewLayoutAttributes] in
                let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                let itemSize = self.itemSize(at: indexPath, collectionView: collectionView, layout: layout)
                let origin: CGPoint
                if let last = itemsAccumulator.last, itemsAccumulator.count >= columns {
                    let x = last.frame.maxX + itemSpacing
                    if currentColumn + 1 >= columns {
                        origin = CGPoint(x: insets.left, y: lineBottom[0] + lineSpacing)
                        lineBottom[0] = origin.y + itemSize.height
                        currentColumn = 0
                    } else {
                        currentColumn = currentColumn + 1
                        origin = CGPoint(x: x, y: lineBottom[currentColumn] + lineSpacing)
                        lineBottom[currentColumn] = origin.y + itemSize.height
                    }
                } else {
                    let x: CGFloat
                    if let last = itemsAccumulator.last {
                        x = last.frame.maxX + itemSpacing
                    } else {
                        x = insets.left
                    }
                    origin = CGPoint(x: x, y: lineBottom[currentColumn])
                    lineBottom[currentColumn] = origin.y + itemSize.height
                    currentColumn = currentColumn + 1
                }
                attribute.frame = CGRect(origin: origin, size: itemSize)
//                if attribute.frame.minY > lineTop {
//                    lineTop = attribute.frame.minY
//                }
//                if attribute.frame.maxY > lineBottom {
//                    lineBottom = attribute.frame.maxY
//                }
                
                return  itemsAccumulator + [attribute]
        }
        offset.y = (lineBottom.sorted(by: >).first ?? offset.y) + insets.bottom
        return attributes
    }
    
    public weak var delegate: StaggeredLayoutDelegate?
    
    required public init(delegate: StaggeredLayoutDelegate ) {
        self.delegate = delegate
    }
    
    func columnWidth(for section: Int, collectionView: UICollectionView, layout: PluginLayout) -> CGFloat {
        let n = delegate?.collectionView(collectionView, layout: layout, columnsForSectionAt: section) ?? 1
        
        let itemsPerLine = max(n, 1)
        let insets = delegate?.collectionView?(collectionView, layout: layout, insetForSectionAt: section) ?? .zero
        let spacing = delegate?.collectionView?(collectionView, layout: layout, minimumInteritemSpacingForSectionAt: section) ?? 0
        let availableWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right - insets.left - insets.right
        let itemWidth = (availableWidth - (CGFloat(itemsPerLine - 1) * spacing)) / CGFloat(itemsPerLine)
        return itemWidth
    }
    func itemSize(at indexPath: IndexPath, collectionView: UICollectionView, layout: PluginLayout) -> CGSize {
        let itemWidth = self.columnWidth(for: indexPath.section, collectionView: collectionView, layout: layout)
        let ratio = delegate?.collectionView(collectionView, layout: layout, aspectRatioAt: indexPath) ?? 1
        
        return CGSize(width: itemWidth, height: itemWidth / ratio)
    }
}
