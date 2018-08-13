//
//  Movie.swift
//  Movies
//
//  Created by Maria Deygin on 7/30/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import Foundation

struct Movie: Codable {

    var id: Int = 0
    var title: String?
    var overview: String?
    var voteAverage: Double?
    var posterPath: String?
    var backdropPath: String?
    var releaseDate: Date?
    var runtime: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case voteAverage = "vote_average"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case runtime
    }
    
    var displayedReleaseDate: String? {
        if let date = releaseDate, date != Date.distantFuture {
            return DateFormatter.yyyy.string(from: date)
        }
        return nil
    }
}

extension Movie {
    
    struct Batch: Codable {
        var page: Int
        var totalResults: Int
        var totalPages: Int
        var movies: [Movie] = []
        
        enum CodingKeys: String, CodingKey {
            case page
            case totalResults = "total_results"
            case totalPages = "total_pages"
            case movies = "results"
        }
        
        init() {
            page = 0
            totalResults = 0
            totalPages = 0
        }
    }
    
    struct SearchQuery {
        var query: String
        var page: Int
    }

}

