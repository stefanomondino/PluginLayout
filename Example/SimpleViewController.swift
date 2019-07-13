//
//  ViewController.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit
import PluginLayout

class SimpleViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let dataSource = DataSource(count: 30)
    let layout = PluginLayout()
    let flow = UICollectionViewFlowLayout()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toggleDirection = UIBarButtonItem(title: "Toggle Direction", style: .done, target: self, action: #selector(toggleDirection(_:)))
        self.navigationItem.rightBarButtonItem = toggleDirection
        
        let toggleFlow = UIBarButtonItem(title: "Toggle Flow", style: .done, target: self, action: #selector(toggleFlow(_:)))
        self.navigationItem.leftBarButtonItem = toggleFlow
        
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        layout.defaultPlugin = FlowLayoutPlugin(delegate: self)
        self.collectionView.setCollectionViewLayout(layout, animated: false)
        
        self.collectionView.reloadData()
    }
    @objc func toggleDirection(_ sender: Any) {
        layout.scrollDirection = layout.scrollDirection == .horizontal ? .vertical : .horizontal
        flow.scrollDirection = layout.scrollDirection
    }
    @objc func toggleFlow(_ sender: Any) {
        let newLayout = collectionView.collectionViewLayout == flow ? layout : flow
        self.collectionView.setCollectionViewLayout(newLayout, animated: true)
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w: CGFloat = collectionView.frame.size.width - 4
        let h = w / dataSource.picture(at: indexPath).ratio
        return CGSize(width: w, height: h)
    }
    
}

