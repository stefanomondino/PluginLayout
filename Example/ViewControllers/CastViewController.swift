//
//  CustomViewController.swift
//  Example
//
//  Created by Stefano Mondino on 22/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit
import PluginLayout

struct SpiralEffect: PluginEffect {
    
    let radius: CGFloat
    
    public func apply(to originalAttribute: PluginLayoutAttributes, layout: PluginLayout, plugin: PluginType, sectionAttributes attributes: [PluginLayoutAttributes]) -> PluginLayoutAttributes {
        guard originalAttribute.representedElementKind == nil else { return originalAttribute }
        guard
            let collectionView = layout.collectionView,
            let attribute = originalAttribute.copy() as? PluginLayoutAttributes else { return originalAttribute }
        let offset: CGFloat = collectionView.contentOffset.x
        let width = collectionView.bounds.width
        let percentage = (offset - attribute.frame.origin.x + width - attribute.frame.width / 2.0 ) / width
        let alpha = 1 - pow((percentage - 0.5) * 2, 2)
        attribute.alpha = alpha
        let maxRotation: CGFloat = (cos(collectionView.bounds.width / (radius)))
        let rotationValue = ((percentage * 2) - 1) * maxRotation / 2.0
        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, 0, -radius, 0)
        if rotationValue.isNaN == false {
            transform = CATransform3DRotate(transform, rotationValue, 0, 0, 1)
        }
        
        let xOffset = -((percentage) - 0.5) * width
        
        let trimmed = max(-width, min(width, xOffset))
        transform.m34 = 1 / 2000
        transform = CATransform3DTranslate(transform, trimmed, radius, 200 + xOffset * 10.0)
        
        attribute.transform3D = transform
        
        return attribute
    }
}

class CastViewController: UIViewController, UICollectionViewDelegateFlowLayout, PluginLayoutDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var dataSource: CastDataSource?
    var show: Show?
    var networkHandler: URLSessionDataTask?
    let layout = FlowLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout.scrollDirection = .horizontal
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
        collectionView.isPagingEnabled = true
        self.collectionView.setCollectionViewLayout(layout, animated: false)
        self.collectionView.backgroundColor = UIColor.init(white: 0.90, alpha: 1)
        self.collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: PluginLayout, effectsForItemAt indexPath: IndexPath, kind: String?) -> [PluginEffect] {
        return [SpiralEffect(radius: -10)]
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}


