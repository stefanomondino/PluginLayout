//
//  PictureCollectionViewCell.swift
//  Example
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import UIKit
import PluginLayout

class ShowCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var genre: UILabel!
      @IBOutlet weak var title: UILabel!
    private var task: URLSessionTask?
    @IBOutlet weak var rightLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLabelConstraint: NSLayoutConstraint!
    var show: Show? {
        didSet {
            task?.cancel()
            self.image.image = nil
            self.genre.text = show?.genre ?? ""
            self.title.text = show?.title ?? ""
            task = show?.poster?.download { [weak self] in
                self?.image.image = $0
            }
        }
    }
    var cast: Cast? {
        didSet {
            task?.cancel()
            self.image.image = nil
            self.genre.text = cast?.person.name ?? ""
            self.title.text = cast?.character.name ?? ""
            task = cast?.character.poster?.download { [weak self] in
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
