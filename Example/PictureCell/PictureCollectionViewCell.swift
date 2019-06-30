//
//  PictureCollectionViewCell.swift
//  Example
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit

class PictureCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    private var task: URLSessionTask?
    
    var picture: Picture? {
        didSet {
            task?.cancel()
            self.image.image = nil
            task = picture?.download { [weak self] in
                self?.image.image = $0
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.image.contentMode = .scaleAspectFill
        self.image.clipsToBounds = true
    }

}
