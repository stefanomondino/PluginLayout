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
    case grid(horizontal: Bool)
    case staggered
    case mixed
    case mosaic(columns: Int)
    case comparison
    case customPlugin
    case shows
    case memes
    case cast(show: Show)
    static var all: [Scene] {
        return [
            .shows,
            .memes,
            .flow(pinned: true),
            .grid(horizontal: false),
            .staggered,
            .mosaic(columns: 4),
            .mixed,
            .mosaic(columns: 3),
            .flow(pinned: false),
            .grid(horizontal: true),
            .comparison,
            .customPlugin
        ]
    }
    
    var title: String {
        switch self {
        case .flow (let pinned): return "Flow" + (pinned ? " Pinned" : "")
        case .memes: return "Memes"
        case .grid(let horizontal): return "Grid \(horizontal ? "Horizontal" : "Vertical")"
        case .staggered: return "Staggered"
        case .mosaic(let columns): return "Mosaic (\(columns) cols)"
        case .mixed: return "Mixed"
        case .comparison: return "Comparison with default flow"
        case .customPlugin: return "Custom Plugin"
        case .shows: return "Shows (TVMaze API)"
        case .cast(let show): return show.title
        }
    }
    
    private var pinHeaders: Bool {
        switch self {
        case .flow (let pinned): return pinned
        case .mosaic: return true
        case .grid: return true
        default: return false
        }
    }
    
    private func fromSceneIdentifier(_ identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
    var viewController: UIViewController {
        switch self {
            
        case .flow :
            let dataSource = PicturesDataSource(count: 40, contentType: .food, sections: 2)
            let delegate = FlowDelegate(dataSource: dataSource)
            let layout = FlowLayout()
            layout.sectionFootersPinToVisibleBounds = pinHeaders
            layout.sectionHeadersPinToVisibleBounds = pinHeaders
            return CollectionViewController(dataSource: dataSource, delegate: delegate, layout: layout)
            
        case .staggered :
            let dataSource = PicturesDataSource(count: 40, contentType: .nature, sections: 2)
            let delegate = StaggeredDelegate(dataSource: dataSource)
            let layout = StaggeredLayout()
            layout.sectionFootersPinToVisibleBounds = pinHeaders
            layout.sectionHeadersPinToVisibleBounds = pinHeaders
            return CollectionViewController(dataSource: dataSource, delegate: delegate, layout: layout)
            
        case .grid(let horizontal) :
            let dataSource = PicturesDataSource(count: 40, contentType: .cats, sections: 2)
            let delegate = GridDelegate(dataSource: dataSource)
            let layout = GridLayout()
            layout.scrollDirection = horizontal ? .horizontal : .vertical
            layout.sectionFootersPinToVisibleBounds = pinHeaders
            layout.sectionHeadersPinToVisibleBounds = pinHeaders
            return CollectionViewController(dataSource: dataSource, delegate: delegate, layout: layout)
            
        case .mosaic(let columns) :
            let dataSource = PicturesDataSource(shows: Show.all())
            let delegate = MosaicDelegate(dataSource: dataSource, columns: columns)
            let layout = MosaicLayout()
            layout.sectionFootersPinToVisibleBounds = pinHeaders
            layout.sectionHeadersPinToVisibleBounds = pinHeaders
            return CollectionViewController(dataSource: dataSource, delegate: delegate, layout: layout)
            
        case .mixed: return fromSceneIdentifier("mixed")
            
        case .customPlugin: return fromSceneIdentifier("customPlugin")
            
        case .shows: return fromSceneIdentifier("shows")
        case .memes: return fromSceneIdentifier("memes")
        case .cast(let show):
            let vc = self.fromSceneIdentifier("cast") as! CastViewController
            vc.show = show
            return vc
            
        default: return fromSceneIdentifier("simple")
        }
    }
}
