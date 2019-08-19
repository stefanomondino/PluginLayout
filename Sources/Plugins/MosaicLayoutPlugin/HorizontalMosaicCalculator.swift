//
//  HorizontalStaggeredCalculator.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 17/08/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

class HorizontalMosaicCalculator: MosaicLayoutCalculator {
    
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
        
        offset.x += insets.left
        let contentBounds = parameters.contentBounds
        offset.y = max(offset.y, contentBounds.height)
        let availableHeight = contentBounds.height - insets.top - insets.bottom
        let columnHeight = (availableHeight - (CGFloat(columnsCount - 1) * itemSpacing)) / CGFloat(columnsCount)
        var columns = (0..<columnsCount).map { _ in offset.x }
        let widthMultiple: CGFloat = delegate.collectionView(collectionView, layout: layout, lineMultipleForSectionAt: section)
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
//                let odds = isLandscape ? 10 : 60
                let canBeBig = delegate.collectionView(collectionView, layout: layout, canBeBigAt: indexPath)
                if !canBeBig ||
                    (itemsAccumulator.last?.frame.height ?? 0) > columnHeight ||
                    (!isLandscape && properColumns.count == columnsCount) {
                    properColumns = [properColumn]
                }
                let y = CGFloat(properColumn) * (columnHeight + itemSpacing) + insets.top
                let x = columns[properColumn] + lineSpacing
                let bigHeight = columnHeight * CGFloat(properColumns.count) + CGFloat(properColumns.count - 1) * itemSpacing
                let bigWidth = bigHeight * ratio
                var width = round(bigWidth / widthMultiple) * widthMultiple
                if let closestWidth = sortedColumns.filter ({ abs($0.element - (x + width)) < widthMultiple }).first {
                    width = closestWidth.element - x
                }
                //let height = round((bigHeight + CGFloat(properColumns.count - 1) * lineSpacing) / heightMultiple ) * heightMultiple
                attribute.frame = CGRect(x: x, y: y, width: width, height: bigHeight)
                properColumns.forEach {
                    columns[$0] = attribute.frame.maxX
                }
                
                return itemsAccumulator + [attribute]
        }
        if let finalX = columns.sorted(by: <).last {
            offset.x = finalX
        }
        offset.x += insets.right
        return attributes
    }
    
}
