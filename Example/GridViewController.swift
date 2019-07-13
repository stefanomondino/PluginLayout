//
//  ViewController.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit
import PluginLayout

class GridViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let dataSource = DataSource(count: 160, contentType: .cats)
    
    let layout = PluginLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toggleDirection = UIBarButtonItem(title: "Toggle Direction", style: .done, target: self, action: #selector(toggleDirection(_:)))
        self.navigationItem.rightBarButtonItem = toggleDirection
        
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        layout.scrollDirection = .horizontal
        layout.defaultPlugin = GridLayoutPlugin(delegate: self)
        self.collectionView.setCollectionViewLayout(layout, animated: false)
        
        self.collectionView.reloadData()
    }
    
    @objc func toggleDirection(_ sender: Any) {
        layout.scrollDirection = layout.scrollDirection == .horizontal ? .vertical : .horizontal
    }
 
}

extension GridViewController: GridLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, itemsPerLineAt indexPath: IndexPath) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, aspectRatioAt indexPath: IndexPath) -> CGFloat {
        return dataSource.picture(at: indexPath).ratio
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
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
}
