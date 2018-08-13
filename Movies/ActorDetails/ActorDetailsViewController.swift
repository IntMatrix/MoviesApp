//
//  ActorDetailsViewController.swift
//  Movies
//
//  Created by Maria Deygin on 8/3/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import UIKit
import RxSwift

class ActorDetailsViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var placeOfBirthLabel: UILabel!
    @IBOutlet weak var biographyLabel: UILabel!
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet var viewModel: ActorDetailsViewModel!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActorData()
    }
    
    private func setupActorData() {
        viewModel.actor.asObservable().map{ $0.name }
            .bind(to: nameLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.actor.asObservable().map { (actor) -> String? in
            guard let birthday = actor.birthday else { return nil }
            var text = DateFormatter.mediumStyled.string(from: birthday)
            
            if let deathday = actor.deathday {
                text += " - " + DateFormatter.mediumStyled.string(from: deathday)
            }
            return text
            }.bind(to: yearLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.actor.asObservable().map{ $0.placeOfBirth }
            .bind(to: placeOfBirthLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.actor.asObservable().map{ $0.biography }
            .bind(to: biographyLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.actor.asObservable().map{ String(format: "%.1f", $0.popularity ?? 0.0 ) }
            .bind(to: popularityLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.actor.asObservable().flatMap { [unowned self] (actor) -> Observable<UIImage?> in
            let placeholderImage = actor.gender == .female ? #imageLiteral(resourceName: "femalePlaceholder") : #imageLiteral(resourceName: "malePlaceholder")
            return self.viewModel.portrait(for: actor).catchErrorJustReturn(placeholderImage)
            }.bind(to: imageView.rx.image).disposed(by: disposeBag)
    }
}
