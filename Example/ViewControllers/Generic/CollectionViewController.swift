//
//  CollectionViewController.swift
//  Example
//
//  Created by Stefano Mondino on 23/07/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit
import PluginLayout

class CollectionViewController<Delegate: UICollectionViewDelegateFlowLayout>: UIViewController {
    
    let dataSource: DataSource
    let delegate: Delegate?
    let layout: PluginLayout
    @IBOutlet var collectionView: UICollectionView!
    
    init(dataSource: DataSource, delegate: Delegate, layout: PluginLayout) {
        self.dataSource = dataSource
        self.delegate = delegate
        self.layout = layout
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.delegate = nil
        self.dataSource = DataSource(count: 0)
        self.layout = PluginLayout()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        if self.collectionView == nil {
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
            collectionView.backgroundColor = .clear
            if #available(iOS 11.0, *) {
                collectionView.contentInsetAdjustmentBehavior = .automatic
            }
            self.view.addSubview(collectionView)
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
            self.collectionView = collectionView
        }
        
        collectionView.delegate = delegate
        collectionView.dataSource = dataSource
        
        collectionView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }
    
}
