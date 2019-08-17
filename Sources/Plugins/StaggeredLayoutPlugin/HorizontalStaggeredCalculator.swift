//
//  HorizontalStaggeredCalculator.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 17/08/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

class HorizontalStaggeredCalculator: StaggeredLayoutCalculator {
    
    let layout: PluginLayout
    let parameters: StaggeredLayoutPlugin.Parameters
    weak var delegate: StaggeredLayoutPlugin.Delegate?
    let attributesClass: PluginLayoutAttributes.Type
    
    init(layout: PluginLayout, attributesClass: PluginLayoutAttributes.Type, delegate: StaggeredLayoutPlugin.Delegate?, parameters: StaggeredLayoutPlugin.Parameters) {
        self.layout = layout
        self.delegate = delegate
        self.parameters = parameters
        self.attributesClass = attributesClass
    }
    
    func calculateLayoutAttributes(offset: inout CGPoint) -> [PluginLayoutAttributes] {
        guard let collectionView = layout.collectionView,
        let delegate = self.delegate else { return [] }
        offset.x += parameters.insets.left
        let columns = delegate.collectionView(collectionView, layout: layout, columnsForSectionAt: parameters.section)
        //var lineTop: [CGFloat] = (0..<columns).map { _ in offset.y }
        var lineBottom = (0..<columns).map { _ in offset.x }
        let contentBounds = parameters.contentBounds
        offset.y = max(offset.y, contentBounds.height)
        var currentColumn = 0
        let attributes: [PluginLayoutAttributes] = (0..<collectionView.numberOfItems(inSection: parameters.section))
            .map { item in IndexPath(item: item, section: parameters.section) }
            .reduce([]) { itemsAccumulator, indexPath -> [PluginLayoutAttributes] in
                let attribute = PluginLayoutAttributes(forCellWith: indexPath)
                let itemSize = self.itemSize(at: indexPath, collectionView: collectionView, layout: layout)
                let origin: CGPoint
                if let last = itemsAccumulator.last, itemsAccumulator.count >= columns {
                    let y = last.frame.maxY + parameters.itemSpacing
                    if currentColumn + 1 >= columns {
                        origin = CGPoint(x: lineBottom[0] + parameters.lineSpacing, y: parameters.insets.top)
                        lineBottom[0] = origin.x + itemSize.width
                        currentColumn = 0
                    } else {
                        currentColumn += 1
                        origin = CGPoint(x: lineBottom[currentColumn] + parameters.lineSpacing, y: y)
                        lineBottom[currentColumn] = origin.x + itemSize.width
                    }
                } else {
                    let y: CGFloat
                    if let last = itemsAccumulator.last {
                        y = last.frame.maxY + parameters.itemSpacing
                    } else {
                        y = parameters.insets.top
                    }
                    origin = CGPoint(x: lineBottom[currentColumn], y: y)
                    lineBottom[currentColumn] = origin.x + itemSize.width
                    currentColumn += 1
                }
                attribute.frame = CGRect(origin: origin, size: itemSize)
                return  itemsAccumulator + [attribute]
        }
        offset.x = (lineBottom.sorted(by: >).first ?? offset.x) + parameters.insets.right
        return attributes
    }
    
    func columnHeight(for section: Int, collectionView: UICollectionView, layout: PluginLayout) -> CGFloat {
        let columnsCount = delegate?.collectionView(collectionView, layout: layout, columnsForSectionAt: section) ?? 1
        let itemsPerLine = max(columnsCount, 1)
        let insets = parameters.insets
        let spacing = parameters.itemSpacing
        let availableHeight = parameters.contentBounds.height - insets.top - insets.bottom
        let itemHeight = (availableHeight - (CGFloat(itemsPerLine - 1) * spacing)) / CGFloat(itemsPerLine)
        return itemHeight
    }
    
    func itemSize(at indexPath: IndexPath, collectionView: UICollectionView, layout: PluginLayout) -> CGSize {
        let itemHeight = self.columnHeight(for: indexPath.section, collectionView: collectionView, layout: layout)
        let ratio = delegate?.collectionView(collectionView, layout: layout, aspectRatioAt: indexPath) ?? 1
        return CGSize(width: itemHeight * ratio, height: itemHeight)
    }
}
