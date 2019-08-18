//
//  DataSource.swift
//  Example
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import Foundation
import UIKit

class CastDataSource: NSObject, UICollectionViewDataSource {
    struct Section {
        var cast: [Cast]
        var header: String?
        var footer: String?
    }
    var sections: [Section] = []
    
    init(cast: [Cast]) {
        super.init()
        sections = [Section(cast: cast, header: nil, footer: nil)]
//        sections = Show.all().enumerated().map {
//            Section(shows: [$0.element], header: "Section #\($0.offset)", footer: "Total count: \($0.element.count)")
//        }
    }
    func item(at indexPath: IndexPath) -> Cast {
        return sections[indexPath.section].cast[indexPath.item]
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].cast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.register(UINib(nibName: "ShowCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "show")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "show", for: indexPath)
        (cell as? ShowCollectionViewCell)?.cast = self.item(at: indexPath)
        return cell
    }
    
    private var placeholderCell: ShowCollectionViewCell?
    private var placeholderConstraint: NSLayoutConstraint?
    func collectionView(_ collectionView: UICollectionView, placeholderViewAt indexPath: IndexPath, constrainedToWidth width: CGFloat) -> UICollectionViewCell? {
        if placeholderCell == nil {
            
        guard let cell = UINib(nibName: "ShowCollectionViewCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as? ShowCollectionViewCell else { return nil }
            placeholderCell = cell
            
            cell.contentView.translatesAutoresizingMaskIntoConstraints = false
            placeholderConstraint = cell.contentView.widthAnchor.constraint(equalToConstant: width)
            placeholderConstraint?.isActive = true
        }
        guard let cell = placeholderCell else { return nil }
        cell.cast = self.item(at: indexPath)
        placeholderConstraint?.constant = width
        cell.contentView.layoutIfNeeded()
        return cell
        
    }
}
