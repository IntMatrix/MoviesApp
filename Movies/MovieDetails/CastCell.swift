//
//  CastCell.swift
//  Movies
//
//  Created by Maria Deygin on 7/30/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import UIKit

class CastCell: RxCollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var characterLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        characterLabel.text = nil
        photoImageView?.image = nil
    }
}
