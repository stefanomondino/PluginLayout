//
//  VerticalStaggeredCalculator.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 17/08/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

class VerticalStaggeredCalculator: StaggeredLayoutCalculator {
    
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
        offset.y += parameters.insets.top
        let columns = delegate.collectionView(collectionView, layout: layout, columnsForSectionAt: parameters.section)
        //var lineTop: [CGFloat] = (0..<columns).map { _ in offset.y }
        var lineBottom = (0..<columns).map { _ in offset.y }
        let contentBounds = collectionView.frame.inset(by: collectionView.contentInset)
        offset.x = max(offset.x, contentBounds.width)
        var currentColumn = 0
        let attributes: [PluginLayoutAttributes] = (0..<collectionView.numberOfItems(inSection: parameters.section))
            .map { item in IndexPath(item: item, section: parameters.section) }
            .reduce([]) { itemsAccumulator, indexPath -> [PluginLayoutAttributes] in
                let attribute = PluginLayoutAttributes(forCellWith: indexPath)
                let itemSize = self.itemSize(at: indexPath, collectionView: collectionView, layout: layout)
                let origin: CGPoint
                if let last = itemsAccumulator.last, itemsAccumulator.count >= columns {
                    let x = last.frame.maxX + parameters.itemSpacing
                    if currentColumn + 1 >= columns {
                        origin = CGPoint(x: parameters.insets.left, y: lineBottom[0] + parameters.lineSpacing)
                        lineBottom[0] = origin.y + itemSize.height
                        currentColumn = 0
                    } else {
                        currentColumn += 1
                        origin = CGPoint(x: x, y: lineBottom[currentColumn] + parameters.lineSpacing)
                        lineBottom[currentColumn] = origin.y + itemSize.height
                    }
                } else {
                    let x: CGFloat
                    if let last = itemsAccumulator.last {
                        x = last.frame.maxX + parameters.itemSpacing
                    } else {
                        x = parameters.insets.left
                    }
                    origin = CGPoint(x: x, y: lineBottom[currentColumn])
                    lineBottom[currentColumn] = origin.y + itemSize.height
                    currentColumn += 1
                }
                attribute.frame = CGRect(origin: origin, size: itemSize)
                return  itemsAccumulator + [attribute]
        }
        offset.y = (lineBottom.sorted(by: >).first ?? offset.y) + parameters.insets.bottom
        return attributes
    }
    
    func columnWidth(for section: Int, collectionView: UICollectionView, layout: PluginLayout) -> CGFloat {
        let columnsCount = delegate?.collectionView(collectionView, layout: layout, columnsForSectionAt: section) ?? 1
        let itemsPerLine = max(columnsCount, 1)
        let insets = parameters.insets
        let spacing = parameters.itemSpacing
        let availableWidth = parameters.contentBounds.width - insets.left - insets.right
        let itemWidth = (availableWidth - (CGFloat(itemsPerLine - 1) * spacing)) / CGFloat(itemsPerLine)
        return itemWidth
    }
    
    func itemSize(at indexPath: IndexPath, collectionView: UICollectionView, layout: PluginLayout) -> CGSize {
        let itemWidth = self.columnWidth(for: indexPath.section, collectionView: collectionView, layout: layout)
        let ratio = delegate?.collectionView(collectionView, layout: layout, aspectRatioAt: indexPath) ?? 1
        return CGSize(width: itemWidth, height: itemWidth / ratio)
    }
}
