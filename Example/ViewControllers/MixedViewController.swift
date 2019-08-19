//
//  ViewController.swift
//  PluginLayout
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit
import PluginLayout

class MixedViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var chances: [Int: Int] = [:]
    lazy var plugins: [PluginType] = {
        return [
            FlowLayoutPlugin(delegate: self, pinSectionHeaders: true, pinSectionFooters: true),
            StaggeredLayoutPlugin(delegate: self, pinSectionHeaders: true, pinSectionFooters: true),
            MosaicLayoutPlugin(delegate: self, pinSectionHeaders: true, pinSectionFooters: true),
            GridLayoutPlugin(delegate: self)
        ]
    }()
    let dataSource: PicturesDataSource = {
        let nature = (0..<100).map { Picture(id: $0, type: .nature)}
        let cats = (0..<10).map { Picture(id: $0, type: .cats)}
        let people = (0..<100).map { Picture(id: $0, type: .people)}
        let sports = (0..<30).map { Picture(id: $0, type: .sports)}
        return PicturesDataSource(pictures: [
            cats,
            nature,
            people,
            sports
            ])
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = dataSource
        collectionView.delegate = self

        self.collectionView.setCollectionViewLayout(PluginLayout(), animated: false)
        self.collectionView.reloadData()
    }
}

extension MixedViewController: PluginLayoutDelegate, StaggeredLayoutDelegate, GridLayoutDelegate, MosaicLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: PluginLayout, pluginForSectionAt section: Int) -> PluginType? {
        return plugins[section]
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, lineCountForSectionAt section: Int) -> Int {
        switch section {
        case 1: return 3
        default: return 4
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, aspectRatioAt indexPath: IndexPath) -> CGFloat {
        return dataSource.picture(at: indexPath).ratio
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, lineFractionAt indexPath: IndexPath) -> Int {
        switch indexPath.item {
        case  0..<4: return 2
        case  0..<7: return 4
        case 0..<16: return 5
        default: return 3
        }
        
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 4, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, canBeBigAt indexPath: IndexPath) -> Bool {
        return chanceForBig(at: indexPath.item) > 60
    }
    
    func chanceForBig(at index: Int) -> Int {
        guard let chance = chances[index] else {
            let c = Int.random(in: (0..<100))
            chances[index] = c
            return c
        }
        return chance
    }
}
