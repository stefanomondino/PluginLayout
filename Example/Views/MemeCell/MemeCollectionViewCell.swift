//
//  PictureCollectionViewCell.swift
//  Example
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit
import PluginLayout

class MemeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!

    private var task: URLSessionTask?
    @IBOutlet weak var rightLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLabelConstraint: NSLayoutConstraint!
    var meme: Meme? {
        didSet {
            task?.cancel()
            self.image.image = nil
            task = meme?.url.download { [weak self] in
                self?.image.image = $0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.image.contentMode = .scaleAspectFill
        self.image.clipsToBounds = true
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        
        super.apply(layoutAttributes)
    }
}
