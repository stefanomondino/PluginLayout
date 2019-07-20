//
//  MosaicLayoutPlugin.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 14/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

public protocol MosaicLayoutDelegate: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, columnsForSectionAt section: Int) -> Int
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, aspectRatioAt indexPath: IndexPath) -> CGFloat
}

open class MosaicLayoutPlugin: Plugin {
    public typealias Parameters = FlowSectionParameters
    public weak var delegate: MosaicLayoutDelegate?
    public required init(delegate: MosaicLayoutDelegate) {
        self.delegate = delegate
    }
    private var chances: [Int: Int] = [:]
    func chanceForBig(at index: Int) -> Int {
        guard let chance = chances[index] else {
            let c = Int.random(in: (0..<100))
            chances[index] = c
            return c
        }
        return chance
    }
    public func layoutAttributes(in section: Int, offset: inout CGPoint, layout: PluginLayout) -> [UICollectionViewLayoutAttributes] {
        guard let collectionView = layout.collectionView,
            let delegate = delegate else { return [] }
        let columnsCount = delegate.collectionView(collectionView, layout: layout, columnsForSectionAt: section)
        let insets = delegate.collectionView?(collectionView, layout: layout, insetForSectionAt: section) ?? .zero
        let itemSpacing = delegate.collectionView?(collectionView, layout: layout, minimumInteritemSpacingForSectionAt: section) ?? 0
        let lineSpacing = delegate.collectionView?(collectionView, layout: layout, minimumLineSpacingForSectionAt: section) ?? 0
        offset.y += insets.top
        let contentBounds = collectionView.frame.inset(by: collectionView.contentInset)
        offset.x = max(offset.x, contentBounds.width)
        let availableWidth = contentBounds.width - insets.left - insets.right
        let columnWidth = (availableWidth - (CGFloat(columnsCount - 1) * itemSpacing)) / CGFloat(columnsCount)
        var columns = (0..<columnsCount).map { _ in offset.y }
        let heightMultiple: CGFloat = 50
        let attributes: [UICollectionViewLayoutAttributes] = (0..<collectionView.numberOfItems(inSection: section))
            .map { item in IndexPath(item: item, section: section) }
            .reduce([]) { itemsAccumulator, indexPath -> [UICollectionViewLayoutAttributes] in
                let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                let ratio = delegate.collectionView(collectionView, layout: layout, aspectRatioAt: indexPath)
                
                let sortedColumns = columns.enumerated().sorted(by: { $0.element < $1.element })
                let minValue = sortedColumns.first?.element ?? 0
                let minimumIndexes = sortedColumns.filter { $0.element == minValue }
                
                var properColumns = minimumIndexes.reduce([]) { acc, element -> [(offset: Int, element: CGFloat)] in
                    guard let last = acc.last else { return [element] }
                    if last.offset + 1 == element.offset {
                        return acc + [element]
                    }
                    return acc
                    }
                    .map { $0.offset }
                
                let properColumn = properColumns.first ?? 0
                let isLandscape = ratio >= 1
                let odds = isLandscape ? 10 : 60
                if self.chanceForBig(at: indexPath.item) < odds ||
                    (itemsAccumulator.last?.frame.width ?? 0) > columnWidth ||
                    (!isLandscape && properColumns.count == columnsCount)
                    {
                    properColumns = [properColumn]
                }
                let x = CGFloat(properColumn) * (columnWidth + itemSpacing) + insets.left
                let y = columns[properColumn] + lineSpacing
                let bigWidth = columnWidth * CGFloat(properColumns.count) + CGFloat(properColumns.count - 1) * itemSpacing
                let bigHeight = bigWidth / ratio
                var height = round(bigHeight / heightMultiple) * heightMultiple
                if let closestHeight = sortedColumns.filter ({ abs($0.element - (y + height)) < 50 }).first {
                    height = closestHeight.element - y
                }
                //let height = round((bigHeight + CGFloat(properColumns.count - 1) * lineSpacing) / heightMultiple ) * heightMultiple
                attribute.frame = CGRect(x: x, y: y, width: bigWidth, height: height)
                properColumns.forEach {
                    columns[$0] = attribute.frame.maxY
                }
                
                return itemsAccumulator + [attribute]
        }
        if let finalY = columns.sorted(by: <).last {
            offset.y = finalY
        }
        offset.y += insets.bottom
        
        return attributes
    }
    
}
