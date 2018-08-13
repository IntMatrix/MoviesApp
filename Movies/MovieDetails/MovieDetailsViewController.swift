//
//  MovieDetailsViewController.swift
//  Movies
//
//  Created by Maria Deygin on 7/30/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import UIKit
import RxSwift

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var backdropView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var starView: UIView!
    @IBOutlet weak var clockView: UIView!

    @IBOutlet weak var castCollectionView: UICollectionView!
    @IBOutlet var viewModel: MovieDetailsViewModel!
    
    var heroCell:CastCell? {
        willSet {
            heroCell?.heroReset()
        }
        didSet {
            heroCell?.heroSetup()
        }
    }
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHero()
        setupMovieData()
        setupCastCollectionView()
    }
    
    private func setupHero() {
        hero.isEnabled = true
        nameLabel.hero.id = "movie.name"
        yearLabel.hero.id = "movie.year"
        overviewLabel.hero.id = "movie.overview"
        backdropView.hero.id = "movie.backdrop"
        starView.hero.id = "movie.star"
        view.hero.modifiers = [.fade]
        clockView.hero.modifiers = [ .fade]
        castCollectionView.hero.modifiers = [.fade]
    }
    
    private func setupMovieData() {
        viewModel.movie.asObservable().map{ $0.title }
            .bind(to: nameLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.movie.asObservable().map { $0.displayedReleaseDate }
            .bind(to: yearLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.movie.asObservable().map{ $0.overview }
            .bind(to: overviewLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.movie.asObservable().map{ String(format: "%.1f", $0.voteAverage ?? 0.0 ) }
            .bind(to: ratingLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.movie.asObservable().map{ String($0.runtime ?? 0) + "min" }
            .bind(to: lengthLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.movie.asObservable().map{ $0.runtime == nil }
            .bind(to: lengthLabel.rx.isHidden).disposed(by: disposeBag)

        viewModel.movie.asObservable().flatMap { [unowned self] (movie) -> Observable<UIImage?> in
            return self.viewModel.backdrop(for: movie).catchErrorJustReturn(#imageLiteral(resourceName: "no_poster"))
        }.bind(to: imageView.rx.image).disposed(by: disposeBag)
    }
    
    private func setupCastCollectionView() {
        
        viewModel.cast.asObservable()
            .bind(to: castCollectionView.rx.items(cellIdentifier: String(describing: CastCell.self), cellType: CastCell.self)) { [unowned self] (index, actor, cell) in
            cell.hero.modifiers = [.fade, .scale(0.5)]

            cell.nameLabel.text = actor.name
            cell.characterLabel.text = actor.character
            
            let placeholderImage = actor.gender == .female ? #imageLiteral(resourceName: "femalePlaceholder") : #imageLiteral(resourceName: "malePlaceholder")
            _ = cell.disposeBag.insert(
                self.viewModel.portrait(for: actor)
                .startWith(placeholderImage)
                .catchErrorJustReturn(placeholderImage)
                .bind(to: cell.photoImageView.rx.image) )
                
            }.disposed(by:disposeBag)
        
        castCollectionView.rx.modelSelected(Actor.self).bind(to: viewModel.openActorDetailsAction.inputs).disposed(by: disposeBag)
        
        castCollectionView.rx.itemSelected.asObservable().bind { [unowned self] (indexPath) in
            self.heroCell = self.castCollectionView.cellForItem(at: indexPath) as? CastCell
            }.disposed(by: disposeBag)
    }

}

fileprivate extension CastCell {
    
    func heroSetup() {
        self.hero.id = "cast.image"
    }
    
    func heroReset() {
        self.hero.id = nil
    }
}

