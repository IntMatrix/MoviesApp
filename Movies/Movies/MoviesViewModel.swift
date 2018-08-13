//
//  MoviesViewModel.swift
//  Movies
//
//  Created by Maria Deygin on 7/30/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Action

class MoviesViewModel: NSObject {
    
    var moviesModel = MoviesModel()
    var movies: BehaviorSubject<[Movie]> {
        get {
            return moviesModel.movies
        }
    }
    
    var loading = BehaviorSubject<Bool>(value: false)
    var cancelPreviousLoads = PublishSubject<Void>()
    var nextPageTrigger: Observable<Bool>!
    
    var searchQuery: Movie.SearchQuery?
    var inputText = BehaviorSubject<String?>(value: nil)
    
    var networkService = NetworkService()
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var viewController: UIViewController!
    
    override init() {
        super.init()
        
        nextPageTrigger = loading.asObservable()
            .map({ (value) -> Bool in
                guard self.moviesModel.isNextPage else { return false }
                return !value
            })
        
        loading.filter{ $0 == true }
            .subscribe(onNext: { _ in
                self.cancelPreviousLoads.onNext(())
            }).disposed(by: disposeBag)
        
        self.loadMovies().subscribe().disposed(by: disposeBag)
        
        inputText.asObservable()
            .flatMap{ $0.map(Observable.just) ?? .empty() }
            .filter{ !$0.isEmpty }
            .distinctUntilChanged()
            .flatMap{ self.startSearchQuery($0) }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    lazy var refreshMoviesAction = CocoaAction {
        [weak self] _ in
        guard let strongSelf = self else { return .empty() }
        
        strongSelf.moviesModel.reset()
        
        if var query = strongSelf.searchQuery {
            query.page = 1
            return strongSelf.loadMovies(query)
        }
        return strongSelf.loadMovies()
    }
    
    lazy var loadNextPageAction = CocoaAction (enabledIf: nextPageTrigger) {
        [weak self] _ in
        guard let strongSelf = self else { return .empty() }
        
        if var query = strongSelf.searchQuery {
            query.page = strongSelf.moviesModel.loadedPage + 1
            return strongSelf.loadMovies(query)
        }
        return strongSelf.loadMovies()
    }
    
    lazy var cancelSearchQueryAction = CocoaAction {
        [weak self] _ in
        guard let strongSelf = self,
            let searchQuery = strongSelf.searchQuery
            else { return .empty() }
        
        strongSelf.searchQuery = nil
        strongSelf.moviesModel.reset()
        return strongSelf.loadMovies()
    }
    
    private func loadMovies() -> Observable<Void> {
        loading.onNext(true)
        return networkService.getTopRatedMovies(page: moviesModel.loadedPage + 1)
            .catchError{ _ in Single.just(Movie.Batch()) }
            .asObservable()
            .takeUntil(cancelPreviousLoads.asObservable())
            .do(onNext: { (batch) in
                self.moviesModel.update(batch)
                self.loading.onNext(false)
            }).map{ _ in }
    }
    
    private func loadMovies(_ query: Movie.SearchQuery) -> Observable<Void> {
        loading.onNext(true)
        return networkService.getMoviesByQuery(query)
            .catchError{ _ in Single.just(Movie.Batch()) }
            .asObservable()
            .takeUntil(cancelPreviousLoads.asObservable())
            .do(onNext: { (batch) in
                self.moviesModel.update(batch)
                self.loading.onNext(false)
            }).map{ _ in }
    }
    
    private func startSearchQuery(_ text: String) -> Observable<Void> {
        let query = Movie.SearchQuery(query: text, page: 1)
        self.searchQuery = query
        
        self.moviesModel.reset()
        return self.loadMovies(query)
    }
    
    lazy var openMovieAction = Action<Movie, Void> {
        [weak self] movie in
        guard let strongSelf = self,
            let navigationController = strongSelf.viewController.navigationController
            else { return .empty() }
        
        let viewController = UIStoryboard(name: "Main", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: String(describing: MovieDetailsViewController.self)) as! MovieDetailsViewController
        viewController.viewModel.setupMovie(movie)
        navigationController.pushViewController(viewController, animated: true)
        return .empty()
    }
    
    func poster(for movie: Movie) -> Observable<UIImage?> {
        guard let posterPath = movie.posterPath else { return  Observable.error(Error.noImagePath)  }
        return networkService.getImage(path: posterPath, size: .medium).asObservable()
    }
    func backdrop(for movie: Movie) -> Observable<UIImage?> {
        guard let posterPath = movie.backdropPath else { return Observable.error(Error.noImagePath)  }
        return networkService.getImage(path: posterPath).asObservable()
    }
}
