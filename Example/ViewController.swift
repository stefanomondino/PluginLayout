//
//  ViewController.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit
import PluginLayout

class ViewController: UIViewController, GridLayoutDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let dataSource = DataSource(count: 30)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        let layout = PluginLayout()
//        layout.defaultPlugin = FlowLayoutPlugin(delegate: self)
        layout.defaultPlugin = GridLayoutPlugin(delegate: self)
       self.collectionView.setCollectionViewLayout(layout, animated: false)
        
        self.collectionView.reloadData()
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
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, widthForItemAt indexPath: IndexPath, itemsPerLine: Int) -> CGFloat {
        let itemsPerLine = max(itemsPerLine, 1)
        let insets = self.collectionView(collectionView, layout: layout, insetForSectionAt: indexPath.section)
        let spacing = self.collectionView(collectionView, layout: layout, minimumInteritemSpacingForSectionAt: indexPath.section)
        let availableWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right - insets.left - insets.right
        return (availableWidth - (CGFloat(itemsPerLine - 1) * spacing)) / CGFloat(itemsPerLine)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = self.collectionView(collectionView, layout: collectionViewLayout, widthForItemAt: indexPath, itemsPerLine: 3)
        let h = w / dataSource.picture(at: indexPath).ratio
        return CGSize(width: w, height: h)
    }
    func itemsPerLine(at indexPath: IndexPath) -> Int {
        return 4
    }

}

