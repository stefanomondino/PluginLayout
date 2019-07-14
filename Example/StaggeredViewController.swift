//
//  ViewController.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit
import PluginLayout

class StaggeredViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let dataSource = DataSource(count: 160, contentType: .nature)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        let layout = StaggeredLayout()
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
    
}

extension StaggeredViewController: StaggeredLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, columnsForSectionAt section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, aspectRatioAt indexPath: IndexPath) -> CGFloat {
        return dataSource.picture(at: indexPath).ratio
    }
    
}
