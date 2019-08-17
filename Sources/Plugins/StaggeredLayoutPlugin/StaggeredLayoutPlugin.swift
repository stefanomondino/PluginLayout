//
//  GridLayoutPlugin.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import Foundation
import UIKit

public protocol StaggeredLayoutDelegate: AnyObject, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, lineCountForSectionAt section: Int) -> Int
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, aspectRatioAt indexPath: IndexPath) -> CGFloat
}

open class StaggeredLayoutPlugin: Plugin {
    public typealias Parameters = FlowSectionParameters
    public typealias Delegate = StaggeredLayoutDelegate
    public var sectionHeadersPinToVisibleBounds: Bool = false
    public var sectionFootersPinToVisibleBounds: Bool = false
    
    public weak var delegate: Delegate?
    
    required public init(delegate: Delegate ) {
        self.delegate = delegate
    }
    
    public convenience init(delegate: StaggeredLayoutDelegate, pinSectionHeaders: Bool, pinSectionFooters: Bool) {
        self.init(delegate: delegate)
        self.sectionHeadersPinToVisibleBounds = pinSectionHeaders
        self.sectionFootersPinToVisibleBounds = pinSectionFooters
    }
    
    public func layoutAttributes(in section: Int, offset: inout CGPoint, layout: PluginLayout) -> [PluginLayoutAttributes] {
        
        //Create the header if available
        let header: PluginLayoutAttributes? = self.header(in: section, offset: &offset, layout: layout)
        
        let renderer = self.getRenderer(layout: layout, section: section)
        let attributes = renderer?.calculateLayoutAttributes(offset: &offset) ?? []
        
        //Create a footer if possible
        let footer: PluginLayoutAttributes? = self.footer(in: section, offset: &offset, layout: layout)
        
        //Return header + attributes + footer. If header or footer are not available (== nil), compactMap strips them away
        return ([header] + attributes + [footer]).compactMap { $0 }
    }
    
    func getRenderer(layout: PluginLayout, section: Int) -> StaggeredLayoutCalculator? {
        //        guard let collectionView = layout.collectionView else { return nil }
        let sectionParameters = self.sectionParameters(inSection: section, layout: layout)
        
        switch layout.scrollDirection {
        case .vertical: return VerticalStaggeredCalculator(layout: layout,
                                                      attributesClass: self.attributesClass,
                                                      delegate: self.delegate,
                                                      parameters: sectionParameters)
        case .horizontal: return HorizontalStaggeredCalculator(layout: layout,
                                                           attributesClass: self.attributesClass,
                                                           delegate: self.delegate,
                                                           parameters: sectionParameters)
        @unknown default: return nil
        }
    }

    public func layoutAttributesForElements(in rect: CGRect, from attributes: [PluginLayoutAttributes], section: Int, layout: PluginLayout) -> [PluginLayoutAttributes] {
        
        return attributes.filter { $0.frame.intersects(rect) }
    }
}
