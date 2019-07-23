//
//  Scene.swift
//  Example
//
//  Created by Stefano Mondino on 23/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import Foundation
import UIKit
import PluginLayout

enum Scene {
    case flow(pinned: Bool)
    case grid
    case staggered
    case mixed
    case mosaic(columns: Int)
    case comparison
    case customPlugin
    
    static var all: [Scene] {
        return [
            .flow(pinned: true),
            .grid,
            .staggered,
            .mosaic(columns: 4),
            .mixed,
            .mosaic(columns: 3),
            .flow(pinned: false),
            .comparison,
            .customPlugin
        ]
    }
    
    var title: String {
        switch self {
        case .flow (let pinned): return "Flow" + (pinned ? " Pinned" : "")
        case .grid: return "Grid"
        case .staggered: return "Staggered"
        case .mosaic(let columns): return "Mosaic (\(columns) cols)"
        case .mixed: return "Mixed"
        case .comparison: return "Comparison with default flow"
        case .customPlugin: return "Custom Plugin"
        }
    }
    
    private var pinHeaders: Bool {
        switch self {
        case .flow (let pinned): return pinned
        case .mosaic: return true
        default: return false
        }
    }
    
    private func fromSceneIdentifier(_ identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
    var viewController: UIViewController {
        switch self {
            
        case .flow :
            let dataSource = DataSource(count: 40, contentType: .food, sections: 2)
            let delegate = FlowDelegate(dataSource: dataSource)
            let layout = FlowLayout()
            layout.sectionFootersPinToVisibleBounds = pinHeaders
            layout.sectionHeadersPinToVisibleBounds = pinHeaders
            return CollectionViewController(dataSource: dataSource, delegate: delegate, layout: layout)
            
        case .staggered :
            let dataSource = DataSource(count: 40, contentType: .nature, sections: 2)
            let delegate = StaggeredDelegate(dataSource: dataSource)
            let layout = StaggeredLayout()
            layout.sectionFootersPinToVisibleBounds = pinHeaders
            layout.sectionHeadersPinToVisibleBounds = pinHeaders
            return CollectionViewController(dataSource: dataSource, delegate: delegate, layout: layout)
            
        case .grid :
            let dataSource = DataSource(count: 40, contentType: .cats, sections: 2)
            let delegate = GridDelegate(dataSource: dataSource)
            let layout = GridLayout()
            layout.sectionFootersPinToVisibleBounds = pinHeaders
            layout.sectionHeadersPinToVisibleBounds = pinHeaders
            return CollectionViewController(dataSource: dataSource, delegate: delegate, layout: layout)
            
        case .mosaic(let columns) :
            let dataSource = DataSource(count: 60, contentType: .people, sections: 2)
            let delegate = MosaicDelegate(dataSource: dataSource, columns: columns)
            let layout = MosaicLayout()
            layout.sectionFootersPinToVisibleBounds = pinHeaders
            layout.sectionHeadersPinToVisibleBounds = pinHeaders
            return CollectionViewController(dataSource: dataSource, delegate: delegate, layout: layout)
            
        case .mixed: return fromSceneIdentifier("mixed")
            
        case .customPlugin: return fromSceneIdentifier("customPlugin")
            
        default: return fromSceneIdentifier("simple")
        }
    }
}
