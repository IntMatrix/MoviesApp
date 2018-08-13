//
//  MoviesViewController.swift
//  Movies
//
//  Created by Maria Deygin on 7/29/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import UIKit
import RxSwift
import Hero

class MoviesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var viewModel: MoviesViewModel!
    
    let disposeBag = DisposeBag()
    
    var heroCell: MovieCell? {
        willSet {
            guard let heroCell = heroCell else { return }
            heroCell.heroReset()
        }
        didSet {
            guard let heroCell = heroCell else { return }
            heroCell.heroSetup()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHero()
        setupSearchBar()
        setupTableView()
        setupRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.shadowImage = UIImage() // to remove gray stripe on navigation bar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        heroCell = nil
    }
    
    private func setupHero() {
        hero.isEnabled = true
        navigationController?.hero.isEnabled = true
        tableView.hero.modifiers = [.translate(x:-tableView.frame.size.width)]
    }
    
    private func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        searchController.searchBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        searchController.hidesNavigationBarDuringPresentation = false
        
        let searchBar = searchController.searchBar
        
        searchBar.rx.cancelButtonClicked.map{ _ in () }
            .bind(to: viewModel.cancelSearchQueryAction.inputs)
            .disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked
            .map{ searchBar.text }
            .bind(to: viewModel.inputText)
            .disposed(by: disposeBag)
        
        searchBar.rx.value.orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: viewModel.inputText).disposed(by: disposeBag)
    }
    
    private func setupTableView() {
        viewModel.movies.asObservable().bind(to: tableView.rx.items(cellIdentifier: String(describing: MovieCell.self), cellType: MovieCell.self)) { [unowned self] (row, movie, cell) in
            
            cell.nameLabel.text = movie.title
            cell.overviewLabel.text = movie.overview
            cell.nameLabel.hero.id = nil
            cell.ratingLabel.text = String(format: "%.1f", movie.voteAverage ?? 0.0)
            cell.yearLabel.text = movie.displayedReleaseDate
            
            _ = cell.disposeBag.insert( self.viewModel.poster(for: movie)
                .startWith(#imageLiteral(resourceName: "no_poster"))
                .catchErrorJustReturn(#imageLiteral(resourceName: "no_poster"))
                .bind(to: cell.posterImageView.rx.image) )
            
            _ = cell.disposeBag.insert( self.viewModel.backdrop(for: movie)
                .catchErrorJustReturn(#imageLiteral(resourceName: "no_poster"))
                .bind(to: cell.backgroundImageView.rx.image) )
            
            }.disposed(by: disposeBag)
            
        
        tableView.rx.modelSelected(Movie.self).bind(to: viewModel.openMovieAction.inputs).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.asObservable().bind { [unowned self] (indexPath) in
            self.heroCell = self.tableView.cellForRow(at: indexPath) as? MovieCell
            self.tableView.deselectRow(at: indexPath, animated: true)
            }.disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .filter { [unowned self] (contentOffset) -> Bool in
                let res = contentOffset.y >= self.tableView.contentSize.height - self.tableView.bounds.size.height * 2
                return res && self.tableView.contentSize.height >= self.tableView.bounds.size.height
            }.map{ _ in () }
            .bind(to: viewModel.loadNextPageAction.inputs).disposed(by: disposeBag)
        
        tableView.tableFooterView = UIView()
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        let title = "Loading movies..."
        refreshControl.attributedTitle = NSAttributedString(string: title, attributes: [.foregroundColor : UIColor.white])
        tableView.refreshControl = refreshControl
        tableView.refreshControl?.rx.action = viewModel.refreshMoviesAction
    }
}

extension MoviesViewController: UIScrollViewDelegate {
    
    //a workaround to normalize contentOffset after scrollToTop action
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        var contentOffset = scrollView.contentOffset
        if (contentOffset.y < 0) {
            contentOffset.y = 0
            scrollView.setContentOffset(contentOffset, animated: true)
        }
    }
    
}

fileprivate extension MovieCell {
    
    func heroSetup() {
        self.nameLabel.hero.id = "movie.name"
        self.yearLabel.hero.id = "movie.year"
        self.overviewLabel.hero.id = "movie.overview"
        self.starView.hero.id = "movie.star"
        self.hero.id = "movie.backdrop"
        self.posterImageView.hero.modifiers = [.translate(x: -self.posterImageView.frame.maxX)]
    }
    
    func heroReset() {
        self.nameLabel.hero.id = nil
        self.yearLabel.hero.id = nil
        self.overviewLabel.hero.id = nil
        self.starView.hero.id = nil
        self.hero.id = nil
        self.posterImageView.hero.modifiers = nil
    }
    
}

