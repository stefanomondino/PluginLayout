//
//  CustomViewController.swift
//  Example
//
//  Created by Stefano Mondino on 22/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit
import PluginLayout

class CustomViewController: UIViewController, TableLayoutDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    let dataSource = PicturesDataSource(count: 26, sections: 2)
    let layout = PluginLayout()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        layout.defaultPlugin = TableLayoutPlugin(delegate: self)
        self.collectionView.setCollectionViewLayout(layout, animated: false)
        
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, rowHeightAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
