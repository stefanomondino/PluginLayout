//
//  Plugin.swift
//  Example
//
//  Created by Stefano Mondino on 20/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

/**
    An object capable of calculating layout attributes for a specific section of the collection view.
 
    Each plugin must be capable to pre-calculate all the attributes and "inflate" total content size by proper values.
    It also must be able to return a subset of internal attributes for a given visible rectangle for each step of current scroll.
*/
public protocol PluginType {
    /**   Asks for all attributes in specific section.
     
     This is the main part of each plugin; the plugin must be able to retrieve the total count of elements in current section and create a specific layout attribut for each one. At the end of the iteration, the `offset` property must be updated to reflect the bottom-right-most point "inflated" by the plugin at current stage.
     Plugins are always iterated sequentially by parent layout.
     
     - Parameters:
        - section: The section where calculations will happen
        - offset: The current distance from content view's origin. It should be updated at least once at the end of all iterations.
        - layout: The layout requesting the information.
     
     - Returns: A layout attributes array for each element in current section, including supplementary and decoration view attributes when needed.
     */
    func layoutAttributes(in section: Int, offset: inout CGPoint, layout: PluginLayout) -> [PluginLayoutAttributes]
    func layoutAttributesForElements(in rect: CGRect, from attributes: [PluginLayoutAttributes], section: Int, layout: PluginLayout) -> [PluginLayoutAttributes]
    var attributesClass: PluginLayoutAttributes.Type { get }
     func defaultEffectsForAttribute(_ attribute: PluginLayoutAttributes) -> [PluginEffect]
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
        return attributes.filter(in: rect)
    }
    
    func defaultEffectsForAttribute(_ attribute: PluginLayoutAttributes) -> [PluginEffect] {
        if sectionHeadersPinToVisibleBounds && attribute.representedElementKind == UICollectionView.elementKindSectionHeader {
            return [StickyEffect(position: .start)]
        }
        if sectionFootersPinToVisibleBounds && attribute.representedElementKind == UICollectionView.elementKindSectionFooter {
            return [StickyEffect(position: .end)]
        }
        return []
    }

}
