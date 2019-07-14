//
//  FlowLayout.swift
//  Example
//
//  Created by Stefano Mondino on 14/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

open class SingleLayout<P: Plugin>: PluginLayout {
    
    var plugin: P? { return defaultPlugin as? P }
    
    open override func prepare() {
        if let delegate = self.collectionView?.delegate as? P.Delegate, self.defaultPlugin == nil {
            let plugin = P(delegate: delegate)
            self.defaultPlugin = plugin
        }
        super.prepare()
    }
}
