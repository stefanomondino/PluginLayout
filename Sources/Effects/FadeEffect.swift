//
//  FadeEffect.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 25/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

public class FadeEffect<T: UICollectionViewLayoutAttributes>: PluginEffect {
    public init() {}
    public func apply<T: UICollectionViewLayoutAttributes>(to originalAttribute: T, layout: PluginLayout) -> T {
        guard originalAttribute.representedElementKind == nil else { return originalAttribute }
        guard
            let collectionView = layout.collectionView,
            let attribute = originalAttribute.copy() as? T else { return originalAttribute }
        let offset:CGFloat = collectionView.contentOffset.y
        
        let height = collectionView.bounds.height
        let percentage = (offset - attribute.frame.origin.y + height ) / 400

        attribute.alpha = percentage
        return attribute
    }
}

public class TiltEffect<T: UICollectionViewLayoutAttributes> {
    public func apply<T: UICollectionViewLayoutAttributes>(to originalAttribute: T, layout: PluginLayout) -> T {
        guard originalAttribute.representedElementKind == nil else { return originalAttribute }
        guard let attribute = originalAttribute.copy() as? T else { return originalAttribute }
        let offset = layout.collectionView?.contentOffset.y ?? 0
        let height = (layout.collectionView?.bounds.height ?? 0)
        let percentage = 1 - (offset - attribute.frame.minY + height) / (height - attribute.frame.height)
        var transform = CATransform3DMakeRotation(-CGFloat.pi * max(0, min(1, percentage)) / 3.0, 1, 0, 0)
        transform.m34 = 1/4000
        attribute.transform3D = transform
        return attribute
    }
}

public class ElasticEffect<T: UICollectionViewLayoutAttributes>: PluginEffect {
    public init() {}
    public func apply<T: UICollectionViewLayoutAttributes>(to originalAttribute: T, layout: PluginLayout) -> T {
        guard originalAttribute.representedElementKind == nil else { return originalAttribute }
        guard
            let collectionView = layout.collectionView,
            let attribute = originalAttribute.copy() as? T else { return originalAttribute }
        let offset:CGFloat //= collectionView.contentOffset.y
        if #available(iOS 11.0, *) {
            offset = collectionView.contentOffset.y //- collectionView.adjustedContentInset.top
        } else {
            offset = collectionView.contentOffset.y
        }
        let height = collectionView.bounds.height
        let percentage = (offset - attribute.frame.origin.y + height - 200 ) / 200
//        if attribute.indexPath.item == 0 {
//        print ("\(attribute.indexPath.item): offset: \(offset) - attribute's origin: \(attribute.frame.origin.y) - percentage: \(percentage)")
        
//            print(percentage)
//        }
        var frame = attribute.frame
        
        let spacing: CGFloat = 90 * (attribute.frame.size.height / attribute.frame.size.width)
        frame.origin.y += max(0, min((1 - percentage) * spacing, spacing))
        attribute.frame = frame
        return attribute
    }
}
