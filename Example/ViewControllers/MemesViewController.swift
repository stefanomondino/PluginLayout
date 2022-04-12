//
//  CustomViewController.swift
//  Example
//
//  Created by Stefano Mondino on 22/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit
import PluginLayout
extension CGSize {
    var ratio: CGFloat {
        width / height
    }
}
class MemeViewController: UIViewController, MosaicLayoutDelegate {

 
    @IBOutlet weak var collectionView: UICollectionView!
    let dataSource = MemesDataSource()
    
    let mosaicLayout = MosaicLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        self.collectionView.setCollectionViewLayout(mosaicLayout, animated: false)
        self.collectionView.backgroundColor = UIColor.init(white: 0.90, alpha: 1)
        self.collectionView.reloadData()

        
    }
    private var currentLayout = 0
    
    let spacing: CGFloat = 8
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 1
        
        let width = round((collectionView.bounds.width - spacing - spacing - ((columns - 1) * spacing)) / columns)
        guard let cell = dataSource.collectionView(collectionView, placeholderViewAt: indexPath, constrainedToWidth: width) else { return .zero }
        
        return cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, lineCountForSectionAt section: Int) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, lineMultipleForSectionAt section: Int) -> CGFloat {
        20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, canBeBigAt indexPath: IndexPath) -> Bool {
        dataSource.meme(at: indexPath).size.ratio > 1.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, aspectRatioAt indexPath: IndexPath) -> CGFloat {
        dataSource.meme(at: indexPath).size.ratio
        
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: PluginLayout, effectsForItemAt indexPath: IndexPath, kind: String?) -> [PluginEffect] {
        return []
    }
}
