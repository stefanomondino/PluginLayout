//
//  TabViewController.swift
//  Example
//
//  Created by Stefano Mondino on 23/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit
import Inject
class TabViewController: UITabBarController {
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        self.viewControllers = Scene.all.map {
            let viewController = Inject.ViewControllerHost($0.viewController)
            viewController.title = $0.title
            return UINavigationController(rootViewController: viewController)
        }
        
    }
    
}
