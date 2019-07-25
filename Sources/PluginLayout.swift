//
//  PluginLayout.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit
public protocol PluginEffect {
//    associatedtype T: UICollectionViewLayoutAttributes
    func apply<T: UICollectionViewLayoutAttributes>(to originalAttribute: T, layout: PluginLayout) -> T
}
open class PluginLayout: UICollectionViewLayout {
    
    class Cache<T> {
        private var items: [Int: [T]] = [:]
        
        init() {}
        
        func clear() {
            self.items = [:]
        }
        func all() -> [T] {
            return items.flatMap { $0.value }
        }
        func set(items: [T]?, forSection section: Int) {
            self.items[section] = items
        }
        func add(item: T, forSection section: Int) {
            self.items[section] = (self.items[section] ?? []) + [item]
        }
        func items(forSection section: Int) -> [T]? {
            return self.items[section]
        }
    }
    
    private var contentSize: CGSize = .zero
    private let attributesCache = Cache<UICollectionViewLayoutAttributes>()
    private let effectsCache = Cache<PluginEffect>()
    
    private var delegate: PluginLayoutDelegate? {
        return self.collectionView?.delegate as? PluginLayoutDelegate
    }
    
    @IBInspectable
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
    public func effects(for section: Int) -> [PluginEffect] {
        guard let delegate = self.delegate,
            let collectionView = collectionView else { return [] }
        return delegate.collectionView(collectionView, layout: self, effectsForSectionAt: section)
    }

    open override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        return true
    }
    open override func prepare() {
        super.prepare()
        
        var offset = CGPoint.zero
        let sections = collectionView?.numberOfSections ?? 0
        (0..<sections).forEach { section in
            let attributes = self.plugin(for: section)?.layoutAttributes(in: section, offset: &offset, layout: self)
            self.attributesCache.set(items: attributes, forSection: section)
        }
        self.contentSize = CGSize(width: offset.x, height: offset.y)
    }
    
    open override var collectionViewContentSize: CGSize {
        return contentSize
    }
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        return (0..<collectionView.numberOfSections).flatMap { section  -> [UICollectionViewLayoutAttributes] in
            let attributes = self.attributesCache.items(forSection: section)
            let plugin = self.plugin(for: section)
            let effects = self.effects(for: section)
            let results = plugin?
                .layoutAttributesForElements(in: rect, from: attributes ?? [], section: section, layout: self )
                .map { attribute in
                    effects.reduce(attribute) { $1.apply(to: $0, layout: self)
                    }
            }
            return results ?? []
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
        return true
    }
    open override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        
        var context = super.invalidationContext(forBoundsChange: newBounds)
        //This is where the optimization should happen. Needs investigation
//        context.invalidateSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader, at: [IndexPath(item: 0, section: 1)])
//        context.invalidateSupplementaryElements(ofKind: UICollectionView.elementKindSectionFooter, at: [IndexPath(item: 0, section: 0)])
        return context
    }
}
