//
//  VerticalGridRenderer.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 25/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

class VerticalGridCalculator: VerticalFlowCalculator {
    override func itemSize(at indexPath: IndexPath, collectionView: UICollectionView, layout: PluginLayout) -> CGSize {
        let n = (delegate as? GridLayoutDelegate)?.collectionView(collectionView, layout: layout, itemsPerLineAt: indexPath) ?? 1
        let ratio = (delegate as? GridLayoutDelegate)?.collectionView(collectionView, layout: layout, aspectRatioAt: indexPath) ?? 1
        let itemsPerLine = max(n, 1)
        let insets = delegate?.collectionView?(collectionView, layout: layout, insetForSectionAt: indexPath.section) ?? .zero
        let spacing = delegate?.collectionView?(collectionView, layout: layout, minimumInteritemSpacingForSectionAt: indexPath.section) ?? 0
        let availableWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right - insets.left - insets.right
        let itemWidth = (availableWidth - (CGFloat(itemsPerLine - 1) * spacing)) / CGFloat(itemsPerLine)
        return CGSize(width: itemWidth, height: itemWidth / ratio)
    }
}

