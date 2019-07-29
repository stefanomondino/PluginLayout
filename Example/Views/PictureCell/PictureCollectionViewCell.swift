//
//  PictureCollectionViewCell.swift
//  Example
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit
import PluginLayout

class PictureCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var number: UILabel!
    private var task: URLSessionTask?
    @IBOutlet weak var rightLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLabelConstraint: NSLayoutConstraint!
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
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
    }
}
