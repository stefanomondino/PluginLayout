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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: PluginLayout, effectsForSectionAt section: Int) -> [PluginEffect]
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: PluginLayout, effectsForItemAt indexPath: IndexPath, kind: String?) -> [PluginEffect]
}

public extension PluginLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: PluginLayout, pluginForSectionAt section: Int) -> PluginType? {
        return nil
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: PluginLayout, effectsForSectionAt section: Int) -> [PluginEffect] {
        return []
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: PluginLayout, effectsForItemAt indexPath: IndexPath, kind: String?) -> [PluginEffect] {
        return []
    }
}
