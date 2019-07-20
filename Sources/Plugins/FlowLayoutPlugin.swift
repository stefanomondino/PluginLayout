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

open class FlowLayoutPlugin: Plugin {

    public enum ItemsAlignemt {
        case start
        case center
        case end
    }

    struct CollectionContext {
        var collectionView: UICollectionView
        var layout: PluginLayout
        var delegate: FlowLayoutDelegate
        var section: Int
    }

    struct SectionParameters {
        var insets: UIEdgeInsets
        var itemSpacing: CGFloat
        var lineSpacing: CGFloat
        var contentBounds: CGRect
        var offset: CGPoint
    }
    
    public var sectionHeadersPinToVisibleBounds: Bool = false
    public var sectionFootersPinToVisibleBounds: Bool = false
    
    public var itemsAlignment: ItemsAlignemt = .center
    
    public private(set) weak var delegate: FlowLayoutDelegate?
    
    required public init(delegate: FlowLayoutDelegate) {
        self.delegate = delegate
    }
    
    public func layoutAttributes(in section: Int, offset: inout CGPoint, layout: PluginLayout) -> [UICollectionViewLayoutAttributes] {
        guard let collectionView = layout.collectionView,
            let delegate = delegate else { return [] }
        let collectionContext = CollectionContext(collectionView: collectionView,
                                                  layout: layout,
                                                  delegate: delegate,
                                                  section: section)
        var sectionParameters = delegate.sectionParameters(section, for: collectionView, layout: layout)

        let header = self.setupHeader(for: collectionContext, parameters: &sectionParameters)
        let layoutAttributes = self.setupItems(for: collectionContext, parameters: &sectionParameters)
        let footer = self.setupFooter(for: collectionContext, parameters: &sectionParameters)
        offset = sectionParameters.offset
        return ([header] + layoutAttributes + [footer]).compactMap { $0 }
    }
    
    func setupHeader(for context: CollectionContext, parameters: inout SectionParameters) -> UICollectionViewLayoutAttributes? {
        guard let headerSize = context.delegate.collectionView?(context.collectionView,
                                                          layout: context.layout,
                                                          referenceSizeForHeaderInSection: context.section),
            headerSize.height > 0 && headerSize.width > 0 else {
                return nil
        }
        let header = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                                      with: IndexPath(item: 0, section: context.section))
        switch context.layout.scrollDirection {
        case .horizontal:
            header.frame = CGRect(origin: CGPoint(x: parameters.offset.x, y: 0),
                                   size: CGSize(width: headerSize.width, height: parameters.contentBounds.height))
            parameters[keyPath: \.offset.x] = headerSize.width
        case .vertical:
            header.frame = CGRect(origin: CGPoint(x: 0, y: parameters.offset.y),
                                  size: CGSize(width: parameters.contentBounds.width, height: headerSize.height))
            parameters[keyPath: \.offset.x] = headerSize.height
        @unknown default:
            return nil
        }
        return header
    }
    
    func setupItems(for context: CollectionContext, parameters: inout SectionParameters) -> [UICollectionViewLayoutAttributes] {
        let itemsCount = context.numberOfItems()
        guard itemsCount > 0 else { return [] }

        #warning("should consider scroll and language direction")
        parameters[keyPath: \.offset.y] += parameters.insets.top
        parameters[keyPath: \.offset.x] = max(parameters.offset.x, parameters.contentBounds.width) // don't know

        let maxBaseline = context.layout.scrollDirection == .vertical ? parameters.contentBounds.width : parameters.contentBounds.height
        let rowAccumulator = RowAccumulator(direction: context.layout.scrollDirection,
                                            offset: parameters.offset,
                                            itemSpacing: parameters.itemSpacing,
                                            lineSpacing: parameters.lineSpacing,
                                            maxBaselineLenght: maxBaseline,
                                            alignment: self.itemsAlignment)
        
        (0 ..< itemsCount).forEach { index in
            let itemSize = context.referenceSizeForItem(at: index)
            rowAccumulator.appendItem(at: IndexPath(item: index, section: context.section),
                                      size: itemSize)
        }
        let items = rowAccumulator.resolveItems()
        #warning("should consider scroll direction")
        parameters[keyPath: \.offset.y] += items.perpendicularOffset
        return items.attributes
    }
    
    func setupFooter(for context: CollectionContext, parameters: inout SectionParameters) -> UICollectionViewLayoutAttributes? {
        guard let footerSize = context.delegate.collectionView?(context.collectionView,
                                                                layout: context.layout, referenceSizeForFooterInSection: context.section),
            footerSize.height > 0 && footerSize.width > 0 else {
                return nil
        }
        let footer = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                                      with: IndexPath(item: 0, section: context.section))
        switch context.layout.scrollDirection {
        case .horizontal:
            footer.frame = CGRect(origin: CGPoint(x: parameters.offset.x, y: 0),
                                  size: CGSize(width: footerSize.width, height: parameters.contentBounds.height))
            parameters[keyPath: \.offset.x] = footerSize.width
        case .vertical:
            footer.frame = CGRect(origin: CGPoint(x: 0, y: parameters.offset.y),
                                  size: CGSize(width: parameters.contentBounds.width, height: footerSize.height))
            parameters[keyPath: \.offset.x] = footerSize.height
        @unknown default:
            return nil
        }
        return footer
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

internal extension UICollectionViewDelegateFlowLayout {
    
    func sectionParameters(_ section: Int, for collectionView: UICollectionView, layout: UICollectionViewLayout) -> FlowLayoutPlugin.SectionParameters {
        return FlowLayoutPlugin.SectionParameters(
            insets: self.collectionView?(collectionView, layout: layout, insetForSectionAt: section) ?? .zero,
            itemSpacing: self.collectionView?(collectionView, layout: layout, minimumInteritemSpacingForSectionAt: section) ?? 0,
            lineSpacing: self.collectionView?(collectionView, layout: layout, minimumLineSpacingForSectionAt: section) ?? 0,
            contentBounds: collectionView.frame.inset(by: collectionView.contentInset),
            offset: .zero
        )
    }
}

internal extension FlowLayoutPlugin.CollectionContext {
    
    func headerReferenceSize() -> CGSize {
        return delegate.collectionView?(collectionView, layout: layout, referenceSizeForHeaderInSection: section) ?? .zero
    }
    
    func numberOfItems() -> Int {
        return collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section) ?? 0
    }
    
    func referenceSizeForItem(at index: Int) -> CGSize {
        return delegate.collectionView?(collectionView, layout: layout, sizeForItemAt: IndexPath(item: index, section: section)) ?? .zero
    }
}

internal extension FlowLayoutPlugin.SectionParameters {
    
    var lineTop: CGFloat {
        return offset.y
    }
}

class RowAccumulator {
    
    struct RowItem {
        var index: IndexPath
        var size: CGSize
        
        func baseline(for direction: UICollectionView.ScrollDirection) -> CGFloat {
            return direction == .vertical ? self.size.width : self.size.height
        }
        
        func perpendicular(for direction: UICollectionView.ScrollDirection) -> CGFloat {
            return direction == .vertical ? self.size.width : self.size.height
        }
    }
    
    struct RowAttributes {
        var interItemSpacing: CGFloat
        var maxPerpendicularSpace: CGFloat
        var perpendicularCenter: CGFloat
    }
    
    var direction: UICollectionView.ScrollDirection
    let originalOffset: CGPoint
    var offset: CGPoint
    var itemSpacing: CGFloat
    var lineSpacing: CGFloat
    
    var maxBaselineLenght: CGFloat
    var alignment: FlowLayoutPlugin.ItemsAlignemt
    
    private var rowItems = [RowItem]()
    private var rowSize: CGFloat = 0

    private var attributes = [UICollectionViewLayoutAttributes]()
    
    init(direction: UICollectionView.ScrollDirection,
         offset: CGPoint,
         itemSpacing: CGFloat,
         lineSpacing: CGFloat,
         maxBaselineLenght: CGFloat,
         alignment: FlowLayoutPlugin.ItemsAlignemt) {
        self.direction = direction
        self.originalOffset = offset
        self.offset = offset
        self.itemSpacing = itemSpacing
        self.lineSpacing = lineSpacing
        self.maxBaselineLenght = maxBaselineLenght
        self.alignment = alignment
    }
    
    func appendItem(at index: IndexPath, size: CGSize) {
        let rowItem = RowItem(index: index, size: size)
        let baseline = rowItem.baseline(for: self.direction)
        self.rowSize += (itemSpacing + baseline)
        
        if self.rowSize <= self.maxBaselineLenght {
            self.rowItems.append(rowItem)
            return
        }
        self.resolveRow()
        self.rowItems.append(rowItem)
    }
    
    func resolveRow() {
        let rowParam = self.rowParameters()
        self.attributes.append(contentsOf: self.resolveRowAlignCenter(rowParam))
        self.offset.addPerpendicular(for: self.direction, value: rowParam.maxPerpendicularSpace + self.lineSpacing)
        self.rowItems = []
    }
    
    func resolveItems() -> (attributes: [UICollectionViewLayoutAttributes], perpendicularOffset: CGFloat) {
        let rowParam = self.rowParameters()
        var allAttributes = self.attributes
        self.attributes = []
        switch alignment {
        case .start: allAttributes.append(contentsOf: resolveRowAlignStart(rowParam))
        case .center: allAttributes.append(contentsOf: resolveRowAlignStart(rowParam))
        case .end: allAttributes.append(contentsOf: resolveRowAlignEnd(rowParam))
        }
        self.offset.addPerpendicular(for: self.direction, value: rowParam.maxPerpendicularSpace)
        let perpendicularOffset = self.offset.perpendicular(for: self.direction)
        self.offset = originalOffset
        return (attributes: allAttributes, perpendicularOffset: perpendicularOffset)
    }
    
    func resolveRowAlignCenter(_ rowParam: RowAttributes) -> [UICollectionViewLayoutAttributes] {
        var baseLineOffset: CGFloat = 0
        return rowItems.map { item in
            let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: item.index)
            itemAttributes.frame = CGRect.create(baselineOffset: baseLineOffset,
                                                 perpendicularCenter: rowParam.perpendicularCenter,
                                                 direction: self.direction,
                                                 size: item.size)
            baseLineOffset += item.baseline(for: self.direction) + itemSpacing
            return itemAttributes
        }
    }
    
    func resolveRowAlignStart(_ rowParam: RowAttributes) -> [UICollectionViewLayoutAttributes] {
        return []
    }
    
    func resolveRowAlignEnd(_ rowParam: RowAttributes) -> [UICollectionViewLayoutAttributes] {
        return []
    }
    
    func rowParameters() -> RowAttributes {
        let maxPerpendicularSpace = rowItems.reduce(0) { max($0, $1.perpendicular(for: self.direction)) }
        return RowAttributes(
            interItemSpacing: (self.maxBaselineLenght - self.rowItems.map { $0.baseline(for: self.direction) }.reduce(0, +)) / CGFloat(rowItems.count),
            maxPerpendicularSpace: maxPerpendicularSpace,
            perpendicularCenter: (maxPerpendicularSpace / 2) + self.offset.perpendicular(for: self.direction))
    }
}

fileprivate extension CGPoint {
    
    static func point(_ direction: UICollectionView.ScrollDirection, baseline: CGFloat, perpendicular: CGFloat) -> CGPoint {
        switch direction {
        case .vertical: return CGPoint(x: baseline, y: perpendicular)
        case .horizontal: return CGPoint(x: perpendicular, y: baseline)
        @unknown default: return .zero
        }
    }
    
    func baseline(for direction: UICollectionView.ScrollDirection) -> CGFloat {
        return direction == .vertical ? self.x : self.y
    }
    
    func perpendicular(for direction: UICollectionView.ScrollDirection) -> CGFloat {
        return direction == .horizontal ? self.x : self.y
    }

    mutating func addPerpendicular(for direction: UICollectionView.ScrollDirection, value: CGFloat) {
        switch direction {
        case .vertical: self.y += value
        case .horizontal: self.x += value
        @unknown default: break
        }
    }
}

fileprivate extension CGRect {
    
    static func create(baselineOffset: CGFloat, perpendicularCenter: CGFloat, direction: UICollectionView.ScrollDirection, size: CGSize) -> CGRect {
        let origin = CGPoint(x: direction == .vertical ? baselineOffset : perpendicularCenter - (size.width / 2),
                             y: direction == .horizontal ? baselineOffset : perpendicularCenter - (size.height / 2))
        return CGRect(origin: origin, size: size)
    }
}
