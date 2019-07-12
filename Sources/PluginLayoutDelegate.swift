//
//  PluginLayoutDelegate.swift
//  Example
//
//  Created by Andrea Altea on 03/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

public protocol Plugin {
    func layoutAttributes(in section: Int, offset: inout CGPoint, layout: PluginLayout) -> [UICollectionViewLayoutAttributes]
}

public protocol PluginLayoutDelegate: UICollectionViewDelegate {
    func plugin(for section: Int) -> Plugin?
}

extension PluginLayoutDelegate {
    func plugin(for section: Int) -> Plugin? {
        return nil
    }
}
