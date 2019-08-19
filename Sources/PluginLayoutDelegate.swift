//
//  PluginLayoutDelegate.swift
//  Example
//
//  Created by Andrea Altea on 03/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

/// Delegate for Plugin Layout
public protocol PluginLayoutDelegate: UICollectionViewDelegate {
    
    /**   Asks the delegate for a specific plugin in a section.
     
     - Parameters:
         - collectionView: The collection view using the layout.
         - collectionViewLayout: The layout requesting the information.
         - section: The section of the item
     
     - Returns: A Plugin that will be used by collection view in specific section
     */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: PluginLayout, pluginForSectionAt section: Int) -> PluginType?
    
    /**   Asks the delegate for an effects array for a specific item at indexPath and optional kind.
     
     - Parameters:
         - collectionView: The collection view using the layout.
         - collectionViewLayout: The layout requesting the information.
         - indexPath: The index path of the item
         - kind: The `representedElementKind` of the item. When `nil`, represents a normal cell, otherwise a supplementary cell.
     
     - Returns: An array of `PluginEffect`s that will be used for current item. Return `[]` (empty array) for no effects.
     */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: PluginLayout, effectsForItemAt indexPath: IndexPath, kind: String?) -> [PluginEffect]
}

public extension PluginLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: PluginLayout, pluginForSectionAt section: Int) -> PluginType? {
        return nil
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: PluginLayout, effectsForItemAt indexPath: IndexPath, kind: String?) -> [PluginEffect] {
        return []
    }
}
