//
//  DataSource.swift
//  Example
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import Foundation
import UIKit

class ShowsDataSource: NSObject, UICollectionViewDataSource {
    struct Section {
        var shows: [Show]
        var header: String?
        var footer: String?
    }
    var sections: [Section] = []
    
    override init() {
        super.init()
        sections = [Section(shows: Show.all(), header: nil, footer: nil)]
//        sections = Show.all().enumerated().map {
//            Section(shows: [$0.element], header: "Section #\($0.offset)", footer: "Total count: \($0.element.count)")
//        }
    }
    func show(at indexPath: IndexPath) -> Show {
        return sections[indexPath.section].shows[indexPath.item]
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].shows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.register(UINib(nibName: "ShowCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "show")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "show", for: indexPath)
        (cell as? ShowCollectionViewCell)?.show = sections[indexPath.section].shows[indexPath.item]
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
    func collectionView(_ collectionView: UICollectionView, placeholderViewAt indexPath: IndexPath) -> UICollectionViewCell? {
        guard let cell = UINib(nibName: "ShowCollectionViewCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as? ShowCollectionViewCell else { return nil }
        cell.show = self.show(at: indexPath)
        return cell
        
    }
}
