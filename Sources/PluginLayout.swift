//
//  PluginLayout.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

public protocol PluginEffect {
func apply(to originalAttribute: PluginLayoutAttributes, layout: PluginLayout, plugin: PluginType, sectionAttributes attributes: [PluginLayoutAttributes]) -> PluginLayoutAttributes
    func percentage(from originalAttribute: PluginLayoutAttributes, layout: PluginLayout, span: CGFloat) -> CGPoint
}

public extension PluginEffect {
    func percentage(from attribute: PluginLayoutAttributes, layout: PluginLayout, span: CGFloat) -> CGPoint {
        guard let collectionView = layout.collectionView else { return .zero }
        let offset = collectionView.contentOffset
        return CGPoint( x: (offset.x - attribute.frame.origin.x + collectionView.bounds.width - span) / span,
                        y: (offset.y - attribute.frame.origin.y + collectionView.bounds.height - span ) / span)
    }
}

open class PluginLayout: UICollectionViewLayout {
    
    private class PluginLayoutInvalidationContext: UICollectionViewLayoutInvalidationContext {}
    
    class Cache<K: Hashable, T> {
        private(set) var items: [K: [T]] = [:]
        var isEmpty: Bool { return all().count == 0}
        init() {}
        
        func clear() {
            self.items = [:]
        }
        func all() -> [T] {
            return items.flatMap { $0.value }
        }
        func set(items: [T]?, forKey key: K) {
            self.items[key] = items
        }
        func add(item: T, forKey key: K) {
            self.items[key] = (self.items[key] ?? []) + [item]
        }
        func items(forKey key: K) -> [T]? {
            return self.items[key]
        }
    }
    private struct EffectIndex: Hashable {
        let indexPath: IndexPath
        let kind: String?
    }
    
    override open class var invalidationContextClass: AnyClass {
        return PluginLayoutInvalidationContext.self
    }
    
    private var contentSize: CGSize = .zero
    private let attributesCache = Cache<Int, PluginLayoutAttributes>()
    
    private let effectsCacheByIndex = Cache<EffectIndex, PluginEffect>()
    
    private var delegate: PluginLayoutDelegate? {
        return self.collectionView?.delegate as? PluginLayoutDelegate
    }
    
    public var scrollDirection: UICollectionView.ScrollDirection = .vertical {
        didSet { invalidateLayout() }
    }
    
    public var defaultPlugin: PluginType? {
        didSet { invalidateLayout() }
    }
    
    public func plugin(for section: Int) -> PluginType? {
        guard let delegate = self.delegate,
            let collectionView = collectionView else { return defaultPlugin }
        return delegate.collectionView(collectionView, layout: self, pluginForSectionAt: section) ?? defaultPlugin
    }

    public func effects(at indexPath: IndexPath, kind: String? = nil) -> [PluginEffect] {
        guard let delegate = self.delegate,
            let collectionView = collectionView else { return [] }
        return delegate.collectionView(collectionView, layout: self, effectsForItemAt: indexPath, kind: kind)
    }
    
    open override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        return true
    }
    
    private var oldBounds: CGSize = .zero
    
    open override func prepare() {

        if oldBounds != collectionView?.bounds.size {
            attributesCache.clear()
        }
        if !attributesCache.isEmpty { return }
        self.oldBounds = collectionView?.bounds.size ?? .zero
        self.attributesCache.clear()
        self.effectsCacheByIndex.clear()
        
        var offset = CGPoint.zero
        let sections = collectionView?.numberOfSections ?? 0
        (0..<sections).forEach { section in
            let attributes = self.plugin(for: section)?.layoutAttributes(in: section, offset: &offset, layout: self)
            self.attributesCache.set(items: attributes, forKey: section)
            
            attributes?.forEach {
                let effects = self.effects(at: $0.indexPath, kind: $0.representedElementKind)
                self.effectsCacheByIndex.set(items: effects, forKey: EffectIndex(indexPath: $0.indexPath, kind: $0.representedElementKind))
                
            }
        }
        self.contentSize = CGSize(width: offset.x, height: offset.y)
    }
    
    open override var collectionViewContentSize: CGSize {
        return contentSize
    }
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        return (0..<collectionView.numberOfSections).flatMap { section  -> [UICollectionViewLayoutAttributes] in
            guard let plugin = self.plugin(for: section),
                 let attributes = self.attributesCache.items(forKey: section) else { return [] }
            
            var inRect = plugin.layoutAttributesForElements(in: rect, from: attributes, section: section, layout: self )
                .reduce([EffectIndex: PluginLayoutAttributes]()) { acc, element in
                var accumulator = acc
                accumulator[EffectIndex(indexPath: element.indexPath, kind: element.representedElementKind)] = element
                return accumulator
            }
            
            return attributes
                .compactMap { attribute -> PluginLayoutAttributes? in
                    let index = EffectIndex(indexPath: attribute.indexPath, kind: attribute.representedElementKind)
                    let effects = self.effectsCacheByIndex.items(forKey: index) ?? []
                    if effects.count == 0 { return inRect[index] }
                    let properAttribute: PluginLayoutAttributes = inRect[index] ?? attribute
                    return effects
                        .compactMap { $0 }
                        .reduce(properAttribute) {
                            $1.apply(to: $0,
                                     layout: self,
                                     plugin: plugin,
                                     sectionAttributes: attributes)
                    }
            }
            
        }
    }
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesCache.all().filter { $0.indexPath == indexPath && $0.representedElementKind == nil }.first
    }
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesCache.all().filter { $0.indexPath == indexPath && $0.representedElementKind == elementKind }.first
    }
    //This is propably very inefficient at the moment, as it's completely invalidating the layout for each scroll
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if oldBounds != newBounds.size {
            attributesCache.clear()
        }
        return true
    }

    open override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
//        self.effectsCacheByIndex.items.forEach { pair in
//            let index = pair.key
//            if let kind = index.kind {
//                context.invalidateSupplementaryElements(ofKind: kind, at: [index.indexPath])
//            } else {
//                print ("Invalidating: \(index.indexPath)")
//                context.invalidateItems(at: [index.indexPath])
//            }
//
//        }
        super.invalidateLayout(with: context)
    }
    open override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {

        let context = super.invalidationContext(forBoundsChange: newBounds)
        
        //This is where the optimization should happen. Needs investigation
        //        context.invalidateSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader, at: [IndexPath(item: 0, section: 1)])
        //        context.invalidateSupplementaryElements(ofKind: UICollectionView.elementKindSectionFooter, at: [IndexPath(item: 0, section: 0)])
        return context
    }
}
