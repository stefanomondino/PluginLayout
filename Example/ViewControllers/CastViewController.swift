//
//  CustomViewController.swift
//  Example
//
//  Created by Stefano Mondino on 22/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit
import PluginLayout

class CastViewController: UIViewController, StaggeredLayoutDelegate, MosaicLayoutDelegate, PluginLayoutDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var dataSource: CastDataSource?
    var show: Show?
    var networkHandler: URLSessionDataTask?
    let layout = StaggeredLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let show = show {
            networkHandler = Cast.cast(from: show) {[weak self] (cast) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.dataSource = CastDataSource(cast: cast)
                    self.collectionView.dataSource = self.dataSource
                    self.collectionView.reloadData()
                }
            }
            networkHandler?.resume()
        }
        
        
        collectionView.delegate = self
        self.collectionView.setCollectionViewLayout(layout, animated: false)
        self.collectionView.backgroundColor = UIColor.init(white: 0.90, alpha: 1)
        self.collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, lineCountForSectionAt section: Int) -> Int {
        return 3
    }
    let spacing: CGFloat = 8
    
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, aspectRatioAt indexPath: IndexPath) -> CGFloat {
        let columns: CGFloat = CGFloat(self.collectionView(collectionView, layout: layout, lineCountForSectionAt: indexPath.section))
        
        let width = floor((collectionView.bounds.width - spacing - spacing - ((columns - 1) * spacing)) / columns)
        guard let cell = dataSource?.collectionView(collectionView, placeholderViewAt: indexPath, constrainedToWidth: width) else { return 1 }
        let size = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return size.width / size.height
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }
    
}
