//
//  PluginLayout.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import Foundation
import UIKit

public protocol Plugin {
    func layoutAttributes(in section: Int, offset: inout CGPoint, layout: PluginLayout) -> [UICollectionViewLayoutAttributes]
}

public protocol PluginDelegate: class {
    func plugin(for section: Int) -> Plugin?
}
open class PluginLayout: UICollectionViewLayout {
    
    private var contentSize: CGSize = .zero
    private var attributesCache: Set<UICollectionViewLayoutAttributes> = []
    
    private var plugins:[Int: Plugin] = [:]
    public var defaultPlugin: Plugin? {
        didSet { invalidateLayout() }
    
    }
    
    weak var delegate: PluginDelegate?
    
    public init(delegate: PluginDelegate? = nil) {
        self.delegate = delegate
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public func register(plugin: Plugin?, for section: Int) {
        self.plugins[section] = plugin
        invalidateLayout()
    }
    
    public func plugin(for section: Int) -> Plugin? {
        if let delegate = delegate,
            let plugin = delegate.plugin(for: section) {
            return plugin
        }
        return plugins[section] ?? defaultPlugin
    }
    
    open override func prepare() {
        super.prepare()
        var offset = CGPoint.zero
        let sections = collectionView?.numberOfSections ?? 0
        let items = (0..<sections).compactMap {
            self.plugin(for: $0)?.layoutAttributes(in: $0, offset: &offset, layout: self)
        }
        self.attributesCache = Set(items.flatMap { $0 })
        self.contentSize = CGSize(width: offset.x, height: offset.y)
    }
    
    open override var collectionViewContentSize: CGSize {
        return contentSize
    }
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesCache.filter { $0.frame.intersects(rect) }
    }
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesCache.filter { $0.indexPath == indexPath}.first
    }
}
