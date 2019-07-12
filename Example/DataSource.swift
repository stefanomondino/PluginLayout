//
//  DataSource.swift
//  Example
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import Foundation
import UIKit

class DataSource: NSObject, UICollectionViewDataSource {

    var pictures: [[Picture]] = []
    init(pictures:[[Picture]]) {
        super.init()
        self.pictures = pictures
    }
    convenience init(pictures:[Picture]) {
        self.init(pictures:[pictures])
    }
    convenience init(count: Int, contentType: Picture.ContentType = .food) {
        let pictures = (0..<count).map { Picture(id: $0, type: contentType)}
        self.init(pictures: pictures)
    }
    
    func picture(at indexPath: IndexPath) -> Picture {
        return pictures[indexPath.section][indexPath.item]
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return pictures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictures[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.register(UINib(nibName: "PictureCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "picture")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "picture", for: indexPath)
        (cell as? PictureCollectionViewCell)?.picture = pictures[indexPath.section][indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        collectionView.register(UINib(nibName: "SupplementaryCollectionViewCell", bundle: nil), forSupplementaryViewOfKind: kind, withReuseIdentifier: "supplementary")
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "supplementary", for: indexPath)
         (cell as? SupplementaryCollectionViewCell)?.titleLabel.text = kind.uppercased()
        return cell
    }
}
