//
//  Plugin.swift
//  Example
//
//  Created by Stefano Mondino on 20/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

public protocol PluginType {
    func layoutAttributes(in section: Int, offset: inout CGPoint, layout: PluginLayout) -> [PluginLayoutAttributes]
    func layoutAttributesForElements(in rect: CGRect, from attributes: [PluginLayoutAttributes], section: Int, layout: PluginLayout) -> [PluginLayoutAttributes]
    var attributesClass: PluginLayoutAttributes.Type { get }
}

public extension PluginType {
    var attributesClass: PluginLayoutAttributes.Type {
        return PluginLayoutAttributes.self
    }
}

public protocol Plugin: PluginType {
    associatedtype Delegate = UICollectionViewDelegateFlowLayout 
    associatedtype Parameters = SectionParameters
    var delegate: Delegate? { get }
    init(delegate: Delegate)
    func sectionParameters(inSection section: Int, layout: PluginLayout) -> Parameters
    func header(in section: Int, offset: inout CGPoint, layout: PluginLayout) -> PluginLayoutAttributes?
    func footer(in section: Int, offset: inout CGPoint, layout: PluginLayout) -> PluginLayoutAttributes?
    var sectionHeadersPinToVisibleBounds: Bool { get }
    var sectionFootersPinToVisibleBounds: Bool { get }
    
}

public extension Plugin {
    func layoutAttributesForElements(in rect: CGRect, from attributes: [PluginLayoutAttributes], section: Int, layout: PluginLayout) -> [PluginLayoutAttributes] {
        return attributes.filter { $0.frame.intersects(rect) }
    }
    
}
