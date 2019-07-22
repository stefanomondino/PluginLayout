//
//  FlowLayout.swift
//  Example
//
//  Created by Stefano Mondino on 14/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

open class FlowLayout: SingleLayout<FlowLayoutPlugin> {
    
    public var sectionHeadersPinToVisibleBounds: Bool = false {
        didSet { invalidateLayout() }
    }
    
    public var sectionFootersPinToVisibleBounds: Bool = false {
        didSet { invalidateLayout() }
    }
    
    public var alignment: FlowLayoutAlignment = .default {
        didSet { invalidateLayout() }
    }
    
    open override func prepare() {
        super.prepare()
        plugin?.sectionHeadersPinToVisibleBounds = sectionHeadersPinToVisibleBounds
        plugin?.sectionFootersPinToVisibleBounds = sectionFootersPinToVisibleBounds
        plugin?.alignment = alignment
    }
}
