//
//  DataSource.swift
//  Example
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import Foundation
import UIKit

class MemesDataSource: NSObject, UICollectionViewDataSource {
    struct Section {
        var memes: [Meme]
        var header: String?
        var footer: String?
    }
    var sections: [Section] = []
    
    override init() {
        super.init()
        sections = [Section(memes: Meme.all(), header: nil, footer: nil)]
//        sections = Show.all().enumerated().map {
//            Section(shows: [$0.element], header: "Section #\($0.offset)", footer: "Total count: \($0.element.count)")
//        }
    }
    func meme(at indexPath: IndexPath) -> Meme {
        return sections[indexPath.section].memes[indexPath.item]
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].memes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.register(UINib(nibName: "MemeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "meme")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "meme", for: indexPath)
        (cell as? MemeCollectionViewCell)?.meme = sections[indexPath.section].memes[indexPath.item]
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
    
    private var placeholderCell: MemeCollectionViewCell?
    private var placeholderConstraint: NSLayoutConstraint?
    func collectionView(_ collectionView: UICollectionView, placeholderViewAt indexPath: IndexPath, constrainedToWidth width: CGFloat) -> UICollectionViewCell? {
        if placeholderCell == nil {
            
        guard let cell = UINib(nibName: "MemeCollectionViewCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as? MemeCollectionViewCell else { return nil }
            placeholderCell = cell
            
            cell.contentView.translatesAutoresizingMaskIntoConstraints = false
            placeholderConstraint = cell.contentView.widthAnchor.constraint(equalToConstant: width)
            placeholderConstraint?.isActive = true
        }
        guard let cell = placeholderCell else { return nil }
        cell.meme = self.meme(at: indexPath)
        placeholderConstraint?.constant = width
        cell.contentView.layoutIfNeeded()
        return cell
        
    }
}
