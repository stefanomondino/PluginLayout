//
//  Plugin+Section.swift
//  Example
//
//  Created by Stefano Mondino on 20/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

public protocol SectionParameters {
    var insets: UIEdgeInsets { get }
    var itemSpacing: CGFloat { get }
    var lineSpacing: CGFloat { get }
}

extension Plugin {
    func insets(inSection section: Int, layout: PluginLayout) -> UIEdgeInsets {
        guard let collectionView = layout.collectionView,
            let delegate = self.delegate as? UICollectionViewDelegateFlowLayout else { return .zero }
        return delegate.collectionView?(collectionView, layout: layout, insetForSectionAt: section) ?? .zero
    }
    func lineSpacing(inSection section: Int, layout: PluginLayout) -> CGFloat {
        guard let collectionView = layout.collectionView,
            let delegate = self.delegate as? UICollectionViewDelegateFlowLayout else { return .zero }
        return delegate.collectionView?(collectionView, layout: layout, minimumLineSpacingForSectionAt: section) ?? 0
    }
    func itemSpacing(inSection section: Int, layout: PluginLayout) -> CGFloat {
        guard let collectionView = layout.collectionView,
            let delegate = self.delegate as? UICollectionViewDelegateFlowLayout else { return .zero }
        return delegate.collectionView?(collectionView, layout: layout, minimumInteritemSpacingForSectionAt: section) ?? 0
    }
    
}

public extension Plugin where Parameters == FlowSectionParameters {
    func sectionParameters(inSection section: Int, layout: PluginLayout) -> Parameters {
        return Parameters(insets: insets(inSection: section, layout: layout),
                          itemSpacing: itemSpacing(inSection: section, layout: layout),
                          lineSpacing: lineSpacing(inSection: section, layout: layout))
    }
}
