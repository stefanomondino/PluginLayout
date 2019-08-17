//
//  DefaultViewController.swift
//  Example
//
//  Created by Stefano Mondino on 22/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit
import PluginLayout

class FlowDelegate: NSObject, UICollectionViewDelegateFlowLayout, PluginLayoutDelegate {
    let dataSource: PicturesDataSource
    init(dataSource: PicturesDataSource) {
        self.dataSource = dataSource
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: PluginLayout, effectsForItemAt indexPath: IndexPath, kind: String?) -> [PluginEffect] {
        return [FadeEffect(), ElasticEffect()]
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
    private func direction(from layout: UICollectionViewLayout) -> UICollectionView.ScrollDirection {
        switch layout {
        case let flow as UICollectionViewFlowLayout: return flow.scrollDirection
        case let plugin as PluginLayout: return plugin.scrollDirection
        default: return .vertical
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let dimension: CGFloat = 60
        
        switch direction(from: collectionViewLayout) {
        case .horizontal:  return CGSize(width: dimension, height: collectionView.frame.width)
        default:  return CGSize(width: collectionView.frame.width, height: dimension)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let dimension: CGFloat = 60
        switch direction(from: collectionViewLayout) {
        case .horizontal:  return CGSize(width: dimension, height: collectionView.frame.width)
        default:  return CGSize(width: collectionView.frame.width, height: dimension)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch direction(from: collectionViewLayout) {
        case .vertical :
            let width: CGFloat = collectionView.frame.size.width - 4
            let height = width / dataSource.picture(at: indexPath).ratio
            return CGSize(width: width, height: height)
        case .horizontal:
            let height: CGFloat = max((collectionView.frame.size.height  - CGFloat(indexPath.item * 55)), 60)
            let width = height * dataSource.picture(at: indexPath).ratio
            return CGSize(width: width, height: height)
        }
        
    }
    
}
