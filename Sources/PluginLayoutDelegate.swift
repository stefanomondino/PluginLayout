//
//  PluginLayoutDelegate.swift
//  Example
//
//  Created by Andrea Altea on 03/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

public protocol PluginLayoutDelegate: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: PluginLayout, pluginForSectionAt section: Int) -> PluginType?
    
}

extension PluginLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: PluginLayout, pluginForSectionAt section: Int) -> PluginType? {
        return nil
    }
}
