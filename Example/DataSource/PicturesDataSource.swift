//
//  DataSource.swift
//  Example
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import Foundation
import UIKit

class PicturesDataSource: NSObject, UICollectionViewDataSource {
    struct Section {
        var pictures: [Picture]
        var header: String?
        var footer: String?
    }
    var sections: [Section] = []
    var showIndexes: Bool = true
    init(pictures: [[Picture]]) {
        super.init()
        sections = pictures.enumerated().map {
            Section(pictures: $0.element, header: "Section #\($0.offset)", footer: "Total count: \($0.element.count)")
        }
    }
    convenience init(pictures: [Picture], showIndexes: Bool = true) {
        self.init(pictures: [pictures])
        self.showIndexes = showIndexes
    }
    convenience init(count: Int, contentType: Picture.ContentType = .food, sections: Int = 1) {
        let pictures = (0..<count).map { Picture(id: $0, type: contentType)}
        self.init(pictures: (0..<sections).map { _ in pictures })
    }
    
    init(shows: [Show]) {
        sections =
            [Section(pictures: shows.map { Picture(show: $0 )}, header: "Shows", footer: nil)]
        showIndexes = false
    }
    
    func picture(at indexPath: IndexPath) -> Picture {
        return sections[indexPath.section].pictures[indexPath.item]
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].pictures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.register(UINib(nibName: "PictureCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "picture")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "picture", for: indexPath)
        (cell as? PictureCollectionViewCell)?.picture = sections[indexPath.section].pictures[indexPath.item]
        (cell as? PictureCollectionViewCell)?.number.text = showIndexes ? "\(indexPath.item)" : ""
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        collectionView.register(UINib(nibName: "SupplementaryCollectionViewCell", bundle: nil), forSupplementaryViewOfKind: kind, withReuseIdentifier: "supplementary")
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "supplementary", for: indexPath)
        let text: String
        switch kind {
        case UICollectionView.elementKindSectionHeader: text = sections[indexPath.section].header ?? ""
        case UICollectionView.elementKindSectionFooter: text = sections[indexPath.section].footer ?? ""
        default: text = "\(indexPath.section) " + kind.uppercased()
        }
         (cell as? SupplementaryCollectionViewCell)?.titleLabel.text = text
        return cell
    }
    
    func hasHeaderInSection(_ section: Int) -> Bool {
        return sections[section].header != nil
    }
    
    func hasFooterInSection(_ section: Int) -> Bool {
        return sections[section].footer != nil
    }
}
