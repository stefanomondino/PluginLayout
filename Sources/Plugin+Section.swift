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
        return Parameters(section: section,
                          insets: insets(inSection: section, layout: layout),
                          itemSpacing: itemSpacing(inSection: section, layout: layout),
                          lineSpacing: lineSpacing(inSection: section, layout: layout),
                          contentBounds: layout.contentBounds)
    }

    func header(in section: Int, offset: inout CGPoint, layout: PluginLayout) -> PluginLayoutAttributes? {
        if
            let delegate = self.delegate as? UICollectionViewDelegateFlowLayout,
            let collectionView = layout.collectionView,
            let headerSize = delegate.collectionView?(collectionView, layout: layout, referenceSizeForHeaderInSection: section),
            headerSize.height > 0 && headerSize.width > 0 {
            let header = PluginLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: section))
            switch layout.scrollDirection {
            case .horizontal:
                header.frame = CGRect(origin: CGPoint(x: offset.x, y: 0), size: CGSize(width: headerSize.width, height: layout.contentBounds.height))
                offset.x += headerSize.width
            case .vertical:
                header.frame = CGRect(origin: CGPoint(x: 0, y: offset.y), size: CGSize(width: layout.contentBounds.width, height: headerSize.height))
                offset.y += headerSize.height
            @unknown default:
                break
            }
            return header
        }
        return nil
    }
    
    func footer(in section: Int, offset: inout CGPoint, layout: PluginLayout) -> PluginLayoutAttributes? {
        if
            let delegate = self.delegate as? UICollectionViewDelegateFlowLayout,
            let collectionView = layout.collectionView,
            let footerSize = delegate.collectionView?(collectionView, layout: layout, referenceSizeForFooterInSection: section),
            footerSize.height > 0 && footerSize.width > 0 {
            let footer = PluginLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: IndexPath(item: 0, section: section))
            switch layout.scrollDirection {
            case .horizontal:
                footer.frame = CGRect(origin: CGPoint(x: offset.x, y: 0), size: CGSize(width: footerSize.width, height: layout.contentBounds.height))
                offset.x += footerSize.width
            case .vertical:
                footer.frame = CGRect(origin: CGPoint(x: 0, y: offset.y), size: CGSize(width: layout.contentBounds.width, height: footerSize.height))
                offset.y += footerSize.height
            @unknown default:
                break
            }
            return footer
        }
        return nil
    }
}
