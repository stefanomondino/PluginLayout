//
//  FlowLayoutPlugin.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import Foundation
import UIKit

public typealias FlowLayoutDelegate = UICollectionViewDelegateFlowLayout

public enum FlowLayoutAlignment: Int {
    case start
    case center
    case end
    case `default`
}

open class FlowLayoutPlugin: Plugin {
    
    public typealias Delegate = FlowLayoutDelegate
    public typealias Parameters = FlowSectionParameters
    
    public var sectionHeadersPinToVisibleBounds: Bool = false
    public var sectionFootersPinToVisibleBounds: Bool = false
    
    public var alignment: FlowLayoutAlignment = .default
    
    public private(set) weak var delegate: FlowLayoutDelegate?
    
    required public init(delegate: Delegate) {
        self.delegate = delegate
    }
    
    convenience public init(delegate: Delegate, pinSectionHeaders: Bool, pinSectionFooters: Bool, alignment: FlowLayoutAlignment = .default) {
        self.init(delegate: delegate)
        self.sectionHeadersPinToVisibleBounds = pinSectionHeaders
        self.sectionFootersPinToVisibleBounds = pinSectionFooters
        self.alignment = alignment
    }

    open func layoutAttributes(in section: Int, offset: inout CGPoint, layout: PluginLayout) -> [PluginLayoutAttributes] {
        
        //Create the header if available
        let header: PluginLayoutAttributes? = self.header(in: section, offset: &offset, layout: layout)
        
        let renderer = self.calculator(layout: layout, section: section)
        let attributes = renderer?.calculateLayoutAttributes(offset: &offset, alignment: self.alignment) ?? []
        
        //Create a footer if possible
        let footer: PluginLayoutAttributes? = self.footer(in: section, offset: &offset, layout: layout)

        //Return header + attributes + footer. If header or footer are not available (== nil), compactMap strips them away
        return ([header] + attributes + [footer]).compactMap { $0 }
    }
    
    func calculator(layout: PluginLayout, section: Int) -> FlowLayoutCalculator? {
//        guard let collectionView = layout.collectionView else { return nil }
        let sectionParameters = self.sectionParameters(inSection: section, layout: layout)
        
        switch layout.scrollDirection {
        case .vertical: return VerticalFlowCalculator(layout: layout,
                                                      attributesClass: self.attributesClass,
                                                    delegate: self.delegate,
                                                    parameters: sectionParameters)
            
        case .horizontal: return HorizontalFlowCalculator(layout: layout,
                                                          attributesClass: self.attributesClass,
                                                        delegate: self.delegate,
                                                        parameters: sectionParameters)
        @unknown default: return nil
        }
    }

    open func layoutAttributesForElements(in rect: CGRect, from attributes: [PluginLayoutAttributes], section: Int, layout: PluginLayout) -> [PluginLayoutAttributes] {
        
        return attributes.filter(in: rect, scrollDirection: layout.scrollDirection)

    }
}
