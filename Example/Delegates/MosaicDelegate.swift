//
//  DefaultViewController.swift
//  Example
//
//  Created by Stefano Mondino on 22/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit
import PluginLayout

class MosaicDelegate: NSObject, MosaicLayoutDelegate, PluginLayoutDelegate {
    private var chances: [Int: Int] = [:]
    func chanceForBig(at index: Int) -> Int {
        guard let chance = chances[index] else {
            let c = Int.random(in: (0..<100))
            chances[index] = c
            return c
        }
        return chance
    }
    
    let dataSource: PicturesDataSource
    let columns: Int
    init(dataSource: PicturesDataSource, columns: Int = 4) {
        self.dataSource = dataSource
        self.columns = columns
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: PluginLayout, effectsForSectionAt section: Int) -> [PluginEffect] {
        return [ElasticEffect()]
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 60)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 60)
    }
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, lineCountForSectionAt section: Int) -> Int {
        return columns
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, aspectRatioAt indexPath: IndexPath) -> CGFloat {
        return dataSource.picture(at: indexPath).ratio
    }
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, canBeBigAt indexPath: IndexPath) -> Bool {
        return chanceForBig(at: indexPath.item) > 60
    }
}
