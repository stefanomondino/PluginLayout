//
//  GridLayoutPlugin.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import Foundation
import UIKit

public protocol GridLayoutDelegate: AnyObject, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, lineFractionAt indexPath: IndexPath) -> Int
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, aspectRatioAt indexPath: IndexPath) -> CGFloat
}

open class GridLayoutPlugin: FlowLayoutPlugin {
    public convenience init(delegate: GridLayoutDelegate ) {
        self.init(delegate: delegate as FlowLayoutDelegate)
    }
    
    required public init(delegate: FlowLayoutDelegate) {
        super.init(delegate: delegate)
    }
    
    override func calculator(layout: PluginLayout, section: Int) -> FlowLayoutCalculator? {
//        guard let collectionView = layout.collectionView else { return nil }
        let sectionParameters = self.sectionParameters(inSection: section, layout: layout)
        
        switch layout.scrollDirection {
        case .vertical: return VerticalGridCalculator(layout: layout,
                                                    attributesClass: self.attributesClass,
                                                    delegate: self.delegate,
                                                    parameters: sectionParameters)
            
        case .horizontal: return HorizontalGridCalculator(layout: layout,
                                                        attributesClass: self.attributesClass,
                                                        delegate: self.delegate,
                                                        parameters: sectionParameters)
        @unknown default: return nil
        }
    }
}
