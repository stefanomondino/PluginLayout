//
//  StaggeredLayoutCalculator.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 17/08/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

protocol StaggeredLayoutCalculator {
    func calculateLayoutAttributes(offset: inout CGPoint) -> [PluginLayoutAttributes]
}
