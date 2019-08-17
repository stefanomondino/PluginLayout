//
//  CustomViewController.swift
//  Example
//
//  Created by Stefano Mondino on 22/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit
import PluginLayout

class ShowsViewController: UIViewController, StaggeredLayoutDelegate {
 
    
    @IBOutlet weak var collectionView: UICollectionView!
    let dataSource = ShowsDataSource()
    let layout = StaggeredLayout()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        self.collectionView.setCollectionViewLayout(layout, animated: false)
        self.collectionView.backgroundColor = UIColor.init(white: 0.90, alpha: 1)
        self.collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, lineCountForSectionAt section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, aspectRatioAt indexPath: IndexPath) -> CGFloat {
        guard let cell = dataSource.collectionView(collectionView, placeholderViewAt: indexPath) else { return 1 }
        
        let width = floor((collectionView.bounds.width - 8 - 8 - (2 * 8)) / 3)
        
        cell.contentView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.widthAnchor.constraint(equalToConstant: width).isActive = true
        cell.contentView.layoutIfNeeded()
        let size = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
//        let size = cell.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize, withHorizontalFittingPriority: .defaultLow, verticalFittingPriority: .defaultLow)
        return size.width / size.height
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
}
