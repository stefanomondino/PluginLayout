//
//  CustomViewController.swift
//  Example
//
//  Created by Stefano Mondino on 22/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit
import PluginLayout

class ShowsViewController: UIViewController, StaggeredLayoutDelegate, GridLayoutDelegate, PluginLayoutDelegate {
 
    @IBOutlet weak var collectionView: UICollectionView!
    let dataSource = ShowsDataSource()
    let gridLayout = GridLayout()
    let staggeredLayoyt = StaggeredLayout()
    let flowLayout = FlowLayout()
    lazy var item = UIBarButtonItem(title: "Staggered", style: .done, target: self, action: #selector(switchLayout(_:)))
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        self.collectionView.setCollectionViewLayout(staggeredLayoyt, animated: false)
        self.collectionView.backgroundColor = UIColor.init(white: 0.90, alpha: 1)
        self.collectionView.reloadData()
        
        self.navigationItem.rightBarButtonItem = item
        
    }
    private var currentLayout = 0
    @objc func switchLayout(_ target: Any) {
        let allLayouts = [staggeredLayoyt, gridLayout, flowLayout]
        let titles = ["Staggered", "Grid", "Flow"]
        currentLayout = (currentLayout + 1) % allLayouts.count
        let layout = allLayouts[currentLayout]
        item.title = titles[currentLayout]
        self.collectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, lineCountForSectionAt section: Int) -> Int {
        return 3
    }
    let spacing: CGFloat = 8
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 1
        
        let width = round((collectionView.bounds.width - spacing - spacing - ((columns - 1) * spacing)) / columns)
        guard let cell = dataSource.collectionView(collectionView, placeholderViewAt: indexPath, constrainedToWidth: width) else { return .zero }
        return cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, aspectRatioAt indexPath: IndexPath) -> CGFloat {
        let columns: CGFloat = CGFloat(self.collectionView(collectionView, layout: layout, lineCountForSectionAt: indexPath.section))
        
        let width = floor((collectionView.bounds.width - spacing - spacing - ((columns - 1) * spacing)) / columns)
        guard let cell = dataSource.collectionView(collectionView, placeholderViewAt: indexPath, constrainedToWidth: width) else { return 1 }
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: PluginLayout, effectsForItemAt indexPath: IndexPath, kind: String?) -> [PluginEffect] {
        return [
            ElasticEffect(spacing: 100, span: 100),
            FadeEffect(span: 100)]
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let show = self.dataSource.show(at: indexPath)
        let vc = Scene.cast(show: show).viewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, lineFractionAt indexPath: IndexPath) -> Int {
        return 2
    }
    
}
