//
//  CustomPlugin.swift
//  Example
//
//  Created by Stefano Mondino on 22/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

//Example of custom plugin

import UIKit
import PluginLayout


protocol TableLayoutDelegate: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, rowHeightAt indexPath: IndexPath) -> CGFloat
}

class TableLayoutPlugin: Plugin {
    typealias Delegate = TableLayoutDelegate
    typealias Parameters = FlowSectionParameters
    var delegate: Delegate?
    
    required init(delegate: Delegate) {
        self.delegate = delegate
    }
    
    var sectionHeadersPinToVisibleBounds: Bool = false
    
    var sectionFootersPinToVisibleBounds: Bool = false
    
    func layoutAttributes(in section: Int, offset: inout CGPoint, layout: PluginLayout) -> [PluginLayoutAttributes] {
        guard let collectionView = layout.collectionView else { return [] }
        let parameters = self.sectionParameters(inSection: section, layout: layout)
        offset.x = max(offset.x, collectionView.bounds.width)
        return (0..<collectionView.numberOfItems(inSection: section))
            .map { IndexPath(item: $0, section: section) }
            .map { indexPath in
                let attribute = attributesClass.init(forCellWith: indexPath)
                let height = delegate?.collectionView(collectionView, layout: layout, rowHeightAt: indexPath) ?? 0
                let frame = CGRect(x: parameters.insets.left, y: offset.y, width: collectionView.bounds.width - parameters.insets.left - parameters.insets.right, height: height)
                offset.y = frame.maxY
                attribute.frame = frame
                return attribute
        }
    }
}
