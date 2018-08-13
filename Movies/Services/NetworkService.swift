//
//  NetworkService.swift
//  Movies
//
//  Created by Maria Deygin on 7/30/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import Foundation
import RxSwift
import Moya

enum Error: Swift.Error {
    case noImagePath
}

class NetworkService {
    let provider = MoyaProvider<MoviesAPI>()
    let jsonDecoder = JSONDecoder()
    let disposeBag = DisposeBag()
    
    init() {
        jsonDecoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let value = try decoder.singleValueContainer().decode(String.self)

            if let date = DateFormatter.yyyyMMdd.date(from: value) {
                return date
            }
            
            //there was discovered that api can return { "release_date" : "" }
            //release_date is empty for planned movies
            //decoder returns distant future date to continue decoding
            return Date.distantFuture
        })
    }
    
    func getTopRatedMovies(page: Int) -> Single<Movie.Batch> {
        return provider.rx.request(.getTopRatedMovies(page))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(Movie.Batch.self, using: jsonDecoder)
    }
    
    func getMoviesByQuery(_ query: Movie.SearchQuery) -> Single<Movie.Batch> {
        return provider.rx.request(.getMoviesByQuery(query))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(Movie.Batch.self, using: jsonDecoder)
    }
    
    func getMovieDetails(_ movie: Movie) -> Single<Movie> {
        return provider.rx.request(.getMovieDetails(movie))
            .filterSuccessfulStatusCodes()
            .map(Movie.self, using: jsonDecoder)
    }
    
    func getCast(_ movie: Movie) -> Single<Actor.Batch> {
        return provider.rx.request(.getCast(movie))
            .filterSuccessfulStatusCodes()
            .map(Actor.Batch.self, using: jsonDecoder)
    }
    
    func getActorDetails(_ actorId:Int) -> Single<Actor> {
        return provider.rx.request(.getActor(actorId))
            .filterSuccessfulStatusCodes()
            .map(Actor.self, using: jsonDecoder)
    }
    
    func getImage(path: String, size:MoviesAPI.ImageSize) -> Single<Image?> {
        return provider.rx.request(.getImage(path,.medium))
            .filterSuccessfulStatusAndRedirectCodes()
            .mapImage()
    }
    
    func getImage(path: String) -> Single<Image?> {
        return provider.rx.request(.getImage(path,.medium))
            .filterSuccessfulStatusAndRedirectCodes()
            .mapImage()
    }
}
