//
//  MoviesResult.swift
//  Movies
//
//  Created by Maria Deygin on 8/1/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import Foundation
import RxSwift

struct MoviesModel {
    
    var movies = BehaviorSubject<[Movie]>(value: [])
    
    var totalResults: Int = 0
    var totalPages: Int = 0
    var loadedPage: Int = 0
    var loadedResults: Int = 0
    
    var isNextPage: Bool {
        return loadedPage < totalPages
    }
    
    private mutating func fill(_ batch: Movie.Batch) {
        loadedPage = batch.page
        loadedResults += batch.movies.count
        
        if totalPages < batch.totalPages {
            totalPages = batch.totalPages
        }
        
        if totalResults < batch.totalResults {
            totalResults = batch.totalResults
        }
    }
    
    mutating func update(_ batch: Movie.Batch) {
        guard batch.page > loadedPage else { return }
        
        var updatedMovies: [Movie]
        do {
            updatedMovies = try movies.value()
        } catch {
            updatedMovies = []
        }
        
        if loadedPage > 0 {
            updatedMovies += batch.movies
        }
        else {
            updatedMovies = batch.movies
        }
        movies.onNext(updatedMovies)
        
        fill(batch)
    }
    
    mutating func reset() {
        totalResults = 0
        totalPages = 0
        loadedPage = 0
        loadedResults = 0
    }
}
