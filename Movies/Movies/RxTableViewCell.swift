//
//  RxTableViewCell.swift
//  Movies
//
//  Created by Maria Deygin on 7/31/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import UIKit
import RxSwift

class RxTableViewCell: UITableViewCell {

    private (set) open var disposeBag = CompositeDisposable()
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag.dispose()
        disposeBag = CompositeDisposable()
    }
    
    deinit {
        disposeBag.dispose()
    }

}
