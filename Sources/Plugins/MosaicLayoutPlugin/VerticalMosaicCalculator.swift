//
//  VerticalStaggeredCalculator.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 17/08/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

class VerticalMosaicCalculator: MosaicLayoutCalculator {
    
    let layout: PluginLayout
    let parameters: MosaicLayoutPlugin.Parameters
    weak var delegate: MosaicLayoutPlugin.Delegate?
    let attributesClass: PluginLayoutAttributes.Type
    
    init(layout: PluginLayout, attributesClass: PluginLayoutAttributes.Type, delegate: MosaicLayoutPlugin.Delegate?, parameters: MosaicLayoutPlugin.Parameters) {
        self.layout = layout
        self.delegate = delegate
        self.parameters = parameters
        self.attributesClass = attributesClass
    }
    
    func calculateLayoutAttributes(offset: inout CGPoint) -> [PluginLayoutAttributes] {
        guard let collectionView = layout.collectionView,
        let delegate = self.delegate else { return [] }
        let columnsCount = delegate.collectionView(collectionView, layout: layout, lineCountForSectionAt: parameters.section)
        let insets = parameters.insets
        let itemSpacing = parameters.itemSpacing
        let lineSpacing = parameters.lineSpacing
        let section = parameters.section
        
        offset.y += insets.top
        let contentBounds = collectionView.frame.inset(by: collectionView.contentInset)
        offset.x = max(offset.x, contentBounds.width)
        let availableWidth = contentBounds.width - insets.left - insets.right
        let columnWidth = (availableWidth - (CGFloat(columnsCount - 1) * itemSpacing)) / CGFloat(columnsCount)
        var columns = (0..<columnsCount).map { _ in offset.y }
        let heightMultiple: CGFloat = 50
        let attributes: [PluginLayoutAttributes] = (0..<collectionView.numberOfItems(inSection: section))
            .map { item in IndexPath(item: item, section: section) }
            .reduce([]) { itemsAccumulator, indexPath -> [PluginLayoutAttributes] in
                let attribute = PluginLayoutAttributes(forCellWith: indexPath)
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
                    (!isLandscape && properColumns.count == columnsCount) {
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
    private var chances: [Int: Int] = [:]
    func chanceForBig(at index: Int) -> Int {
        guard let chance = chances[index] else {
            let c = Int.random(in: (0..<100))
            chances[index] = c
            return c
        }
        return chance
    }
}
