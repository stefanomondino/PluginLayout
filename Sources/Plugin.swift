//
//  Plugin.swift
//  Example
//
//  Created by Stefano Mondino on 20/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

public protocol PluginType {
    func layoutAttributes(in section: Int, offset: inout CGPoint, layout: PluginLayout) -> [UICollectionViewLayoutAttributes]
    func layoutAttributesForElements(in rect: CGRect, from attributes: [UICollectionViewLayoutAttributes], section: Int,  layout: PluginLayout) -> [UICollectionViewLayoutAttributes]
}

public protocol Plugin: PluginType {
    associatedtype Delegate = UICollectionViewDelegateFlowLayout
    associatedtype Parameters = SectionParameters
    var delegate:Delegate? { get }
    init(delegate: Delegate)
    func sectionParameters(inSection section: Int, layout: PluginLayout) -> Parameters
}

public extension Plugin {
    func layoutAttributesForElements(in rect: CGRect, from attributes: [UICollectionViewLayoutAttributes], section: Int, layout: PluginLayout) -> [UICollectionViewLayoutAttributes] {
        return attributes.filter { $0.frame.intersects(rect) }
    }
}
