//
//  MovieCell.swift
//  Movies
//
//  Created by Maria Deygin on 7/30/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import UIKit

class MovieCell: RxTableViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var starView: UIView!
    //background
    @IBOutlet weak var backgroundSuperView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundShadowView: UIView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        yearLabel.text = nil
        overviewLabel.text = nil
        posterImageView.image = nil
        backgroundImageView.image = nil
    }
    
    //prevent standard action on cell highlight by calling super
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {}
    override func setSelected(_ selected: Bool, animated: Bool) {}
    
}
