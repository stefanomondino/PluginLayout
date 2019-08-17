//
//  Extensions.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 17/08/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

open class FlowSectionParameters: SectionParameters {
    public let section: Int
    public let insets: UIEdgeInsets
    public let itemSpacing: CGFloat
    public let lineSpacing: CGFloat
    public let contentBounds: CGRect
    
    public init(section: Int, insets: UIEdgeInsets = .zero, itemSpacing: CGFloat = 0, lineSpacing: CGFloat = 0, contentBounds: CGRect) {
        self.section = section
        self.insets = insets
        self.itemSpacing = itemSpacing
        self.lineSpacing = lineSpacing
        self.contentBounds = contentBounds
    }
}

extension PluginLayout {
    var contentBounds: CGRect {
        guard let collectionView = self.collectionView else { return .zero }
        let insets: UIEdgeInsets
        if #available(iOS 11.0, *) {
            insets = collectionView.adjustedContentInset
        } else {
            insets = collectionView.contentInset
        }
        return collectionView.frame.inset(by: insets)
    }
}
