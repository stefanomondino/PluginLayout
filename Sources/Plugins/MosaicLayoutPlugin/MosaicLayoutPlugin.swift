//
//  MosaicLayoutPlugin.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 14/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

public protocol MosaicLayoutDelegate: AnyObject, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, lineCountForSectionAt section: Int) -> Int
    
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, lineMultipleForSectionAt section: Int) -> CGFloat 
    
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, aspectRatioAt indexPath: IndexPath) -> CGFloat
    
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, canBeBigAt indexPath: IndexPath) -> Bool
}

open class MosaicLayoutPlugin: Plugin {
    public typealias Parameters = FlowSectionParameters
    public typealias Delegate = MosaicLayoutDelegate
    public weak var delegate: Delegate?
    
    public var sectionHeadersPinToVisibleBounds: Bool = false
    public var sectionFootersPinToVisibleBounds: Bool = false
    
    public required init(delegate: Delegate) {
        self.delegate = delegate
    }
    
    convenience public init(delegate: Delegate, pinSectionHeaders: Bool, pinSectionFooters: Bool) {
        self.init(delegate: delegate)
        self.sectionHeadersPinToVisibleBounds = pinSectionHeaders
        self.sectionFootersPinToVisibleBounds = pinSectionFooters
    }
        
    public func layoutAttributes(in section: Int, offset: inout CGPoint, layout: PluginLayout) -> [PluginLayoutAttributes] {
        
        //Create the header if available
        let header: PluginLayoutAttributes? = self.header(in: section, offset: &offset, layout: layout)
        
        let renderer = self.calculator(layout: layout, section: section)
        let attributes = renderer?.calculateLayoutAttributes(offset: &offset) ?? []
        
        //Create a footer if possible
        let footer: PluginLayoutAttributes? = self.footer(in: section, offset: &offset, layout: layout)
        
        //Return header + attributes + footer. If header or footer are not available (== nil), compactMap strips them away
        return ([header] + attributes + [footer]).compactMap { $0 }
    }
    
    func calculator(layout: PluginLayout, section: Int) -> MosaicLayoutCalculator? {
        //        guard let collectionView = layout.collectionView else { return nil }
        let sectionParameters = self.sectionParameters(inSection: section, layout: layout)
        
        switch layout.scrollDirection {
        case .vertical: return VerticalMosaicCalculator(layout: layout,
                                                           attributesClass: self.attributesClass,
                                                           delegate: self.delegate,
                                                           parameters: sectionParameters)
        case .horizontal: return HorizontalMosaicCalculator(layout: layout,
                                                               attributesClass: self.attributesClass,
                                                               delegate: self.delegate,
                                                               parameters: sectionParameters)
        @unknown default: return nil
        }
    }
    
    public func layoutAttributesForElements(in rect: CGRect, from attributes: [PluginLayoutAttributes], section: Int, layout: PluginLayout) -> [PluginLayoutAttributes] {
        
        return attributes.filter(in: rect, scrollDirection: layout.scrollDirection)

    }
}
