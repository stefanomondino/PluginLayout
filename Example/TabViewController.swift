//
//  TabViewController.swift
//  Example
//
//  Created by Stefano Mondino on 23/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit
import PluginLayout

enum DefaultScenes {
    case flow(pinned: Bool)
    case grid
    case staggered
    
    var title: String {
        switch self {
        case .flow (let pinned): return "FlowLayout" + (pinned ? " Pinned" : "")
        case .grid: return "GridLayout"
        case .staggered: return "StaggeredLayout"
        }
    }
    
    var viewController: UIViewController {
        switch self {
        case .flow (let pinned):
            let dataSource = DataSource(count: 40, contentType: .food, sections: 2)
            let delegate = FlowDelegate(dataSource: dataSource)
//            let plugin = FlowLayoutPlugin(delegate: delegate, pinSectionHeaders: true, pinSectionFooters: true)
            let layout = FlowLayout()
            layout.sectionFootersPinToVisibleBounds = pinned
            layout.sectionHeadersPinToVisibleBounds = pinned
            return CollectionViewController(dataSource: dataSource, delegate: delegate, layout: layout)
        default: return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "simple") //?? UIViewController()
        }
    }
}


class TabViewController: UITabBarController {
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        self.viewControllers = [
            DefaultScenes.flow(pinned: false),
            DefaultScenes.flow(pinned: true),
            .staggered
            ].map {
            let viewController = $0.viewController
            viewController.title = $0.title
            return UINavigationController(rootViewController: viewController)
        }
        
    }
    
}
