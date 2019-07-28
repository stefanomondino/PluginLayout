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
    
    public func layoutAttributes(in section: Int, offset: inout CGPoint, layout: PluginLayout) -> [UICollectionViewLayoutAttributes] {
        
        //Create the header if available
        let header: UICollectionViewLayoutAttributes? = self.header(in: section, offset: &offset, layout: layout)
        
        let renderer = self.getRenderer(layout: layout, section: section)
        let attributes = renderer?.calculateLayoutAttributes(offset: &offset, alignment: self.alignment) ?? []
        
        //Create a footer if possible
        let footer: UICollectionViewLayoutAttributes? = self.footer(in: section, offset: &offset, layout: layout)

        //Return header + attributes + footer. If header or footer are not available (== nil), compactMap strips them away
        return ([header] + attributes + [footer]).compactMap { $0 }
    }
    
    func getRenderer(layout: PluginLayout, section: Int) -> LayoutCalculator? {
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

    public func layoutAttributesForElements(in rect: CGRect, from attributes: [UICollectionViewLayoutAttributes], section: Int, layout: PluginLayout) -> [UICollectionViewLayoutAttributes] {
        
        let defaultAttributes = attributes.filter { $0.frame.intersects(rect) }
        
        if sectionFootersPinToVisibleBounds == false && sectionHeadersPinToVisibleBounds == false { return defaultAttributes }
        
        let supplementary: [UICollectionViewLayoutAttributes] = pinSectionHeadersAndFooters(from: attributes, layout: layout, section: section)
        
        return defaultAttributes + supplementary
    }
}

