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
    case mosaic(columns: Int)
    
    static var all: [Scene] {
        return [
            .flow(pinned: false),
            .flow(pinned: true),
            .staggered,
            .mosaic(columns: 4),
            .mosaic(columns: 3)
            
        ]
    }
    
    var title: String {
        switch self {
        case .flow (let pinned): return "Flow" + (pinned ? " Pinned" : "")
        case .grid: return "Grid"
        case .staggered: return "Staggered"
        case .mosaic(let columns): return "Mosaic (\(columns) cols)"
        }
    }
    
    private var pinHeaders: Bool {
        switch self {
        case .flow (let pinned): return pinned
        case .mosaic: return true
        default: return false
        }
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
            
        case .mosaic(let columns) :
            let dataSource = DataSource(count: 60, contentType: .people, sections: 2)
            let delegate = MosaicDelegate(dataSource: dataSource, columns: columns)
            let layout = MosaicLayout()
            layout.sectionFootersPinToVisibleBounds = pinHeaders
            layout.sectionHeadersPinToVisibleBounds = pinHeaders
            return CollectionViewController(dataSource: dataSource, delegate: delegate, layout: layout)
        
        default: return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "simple") //?? UIViewController()
        }
    }
}
