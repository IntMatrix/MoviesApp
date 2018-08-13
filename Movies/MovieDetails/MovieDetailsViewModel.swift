//
//  MovieDetailsViewModel.swift
//  Movies
//
//  Created by Maria Deygin on 7/30/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import UIKit
import RxSwift
import Action

class MovieDetailsViewModel: NSObject {
    
    var movie: BehaviorSubject<Movie>!
    var cast = BehaviorSubject<[Actor]>(value: [])
    var networkService = NetworkService()
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var viewController: UIViewController!
    
    func setupMovie(_ movie: Movie) {
        self.movie = BehaviorSubject<Movie>(value: movie)
        
        loadDetails(movie).subscribe().disposed(by: disposeBag)
        loadCast(movie).subscribe().disposed(by: disposeBag)
    }
    
    private func loadDetails(_ movie: Movie) -> Observable<Void> {
        return self.networkService.getMovieDetails(movie).asObservable()
            .do(onNext: { (updatedMovie) in
                self.movie.onNext(updatedMovie)
            }).map{ _ in }
    }
    
    private func loadCast(_ movie:Movie) -> Observable<Void> {
        return networkService.getCast(movie).asObservable()
            .flatMap{ self.fillCast($0) }
    }
    
    private func fillCast(_ batch: Actor.Batch) -> Observable<Void> {
        var updatedCast:[Actor]
        do {
            updatedCast = try self.cast.value()
        } catch {
            updatedCast = []
        }
        updatedCast += batch.cast
        self.cast.onNext(updatedCast)
        return.empty()
    }
 
    func backdrop(for movie: Movie) -> Observable<UIImage?> {
        guard let backdropPath = movie.backdropPath else { return Observable.error(Error.noImagePath) }
        return networkService.getImage(path: backdropPath, size: .Original).asObservable()
    }
    
    func portrait(for actor: Actor) -> Observable<UIImage?> {
        guard let portraitPath = actor.profilePath else { return Observable.error(Error.noImagePath) }
        return networkService.getImage(path: portraitPath, size: .small).asObservable()
    }
    
    lazy var openActorDetailsAction = Action<Actor, Void> {
        [weak self] actor in
        guard let strongSelf = self,
            let navigationController = strongSelf.viewController.navigationController
            else { return .empty() }
        
        let viewController = UIStoryboard(name: "Main", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: String(describing: ActorDetailsViewController.self)) as! ActorDetailsViewController
        viewController.viewModel.setupActor(actor)

        navigationController.pushViewController(viewController, animated: true)
        return .empty()
    }

}
