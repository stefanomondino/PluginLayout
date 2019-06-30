//
//  GridLayoutPlugin.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import Foundation
import UIKit

public protocol GridLayoutDelegate: UICollectionViewDelegateFlowLayout {
    func itemsPerLine(at indexPath: IndexPath) -> Int
}

open class GridLayoutPlugin: FlowLayoutPlugin {
    public init(delegate: GridLayoutDelegate ) {
        super.init(delegate: delegate)
        
    }
    open override func itemSize(at indexPath: IndexPath, collectionView: UICollectionView, layout: PluginLayout) -> CGSize {
        let n = (delegate as? GridLayoutDelegate)?.itemsPerLine(at: indexPath) ?? 1
        let itemsPerLine = max(n, 1)
        let insets = delegate?.collectionView?(collectionView, layout: layout, insetForSectionAt: indexPath.section) ?? .zero
        let spacing = delegate?.collectionView?(collectionView, layout: layout, minimumInteritemSpacingForSectionAt: indexPath.section) ?? 0
        let availableWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right - insets.left - insets.right
        let itemWidth = (availableWidth - (CGFloat(itemsPerLine - 1) * spacing)) / CGFloat(itemsPerLine)
        return CGSize(width: itemWidth, height: itemWidth)
    }
}
