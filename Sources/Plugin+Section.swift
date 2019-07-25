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
//}
//
//public extension Plugin {
    func header(in section: Int, offset: inout CGPoint, layout: PluginLayout) -> UICollectionViewLayoutAttributes? {
        if
            let delegate = self.delegate as? UICollectionViewDelegateFlowLayout,
            let collectionView = layout.collectionView,
            let headerSize = delegate.collectionView?(collectionView, layout: layout, referenceSizeForHeaderInSection: section),
            headerSize.height > 0 && headerSize.width > 0 {
            let header = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: section))
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
    
    func footer(in section: Int, offset: inout CGPoint, layout: PluginLayout) -> UICollectionViewLayoutAttributes? {
        if
            let delegate = self.delegate as? UICollectionViewDelegateFlowLayout,
            let collectionView = layout.collectionView,
            let footerSize = delegate.collectionView?(collectionView, layout: layout, referenceSizeForFooterInSection: section),
            footerSize.height > 0 && footerSize.width > 0 {
            let footer = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: IndexPath(item: 0, section: section))
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
    
    func pinSectionHeadersAndFooters(from attributes:[UICollectionViewLayoutAttributes], layout: PluginLayout, section: Int) -> [UICollectionViewLayoutAttributes] {
        guard let collectionView = layout.collectionView else { return [] }
        let sectionParameters = self.sectionParameters(inSection: section, layout: layout)
        var supplementary: [UICollectionViewLayoutAttributes] = []
        let itemsRect = attributes
            .filter { $0.representedElementKind == nil }
            .map { $0.frame }
            .reduce(nil) { a, i -> CGRect in
                a?.union(i) ?? i
            } ?? .zero
        if
            self.sectionHeadersPinToVisibleBounds == true,
            let header = attributes.filter ({ $0.representedElementKind == UICollectionView.elementKindSectionHeader }).first {
            var frame = header.frame
            switch layout.scrollDirection {
            case .horizontal: frame.origin.x = max(itemsRect.minX - frame.width - sectionParameters.insets.left, min(itemsRect.maxX - frame.width, collectionView.contentOffset.x))
            default: frame.origin.y = max(itemsRect.minY - frame.height - sectionParameters.insets.top, min(itemsRect.maxY - frame.height, collectionView.contentOffset.y))
            }
            
            header.zIndex = 900 + section + 1
            header.frame = frame
            supplementary += [header]
        }
        
        if
            self.sectionFootersPinToVisibleBounds == true,
            let footer = attributes.filter ({ $0.representedElementKind == UICollectionView.elementKindSectionFooter }).first {
            var frame = footer.frame
            switch layout.scrollDirection {
            case .horizontal: frame.origin.x = max(itemsRect.minX - sectionParameters.insets.left, min(itemsRect.maxX + sectionParameters.insets.right, collectionView.contentOffset.x + collectionView.bounds.width - frame.width ))
            default: frame.origin.y = max(itemsRect.minY - sectionParameters.insets.top, min(itemsRect.maxY + sectionParameters.insets.bottom, collectionView.contentOffset.y + collectionView.bounds.height - frame.height ))
            }
            
            footer.zIndex = 900 + section
            footer.frame = frame
            supplementary += [footer]
        }
        return supplementary
    }
    
}
