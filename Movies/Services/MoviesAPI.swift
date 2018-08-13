//
//  MoviesAPI.swift
//  Movies
//
//  Created by Maria Deygin on 7/30/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import Foundation
import Moya

enum MoviesAPI {
    
    //API key is hidden for rights purposes
    static private let apiKey = ""
    
    case getTopRatedMovies(Int)
    case getMoviesByQuery(Movie.SearchQuery)
    case getMovieDetails(Movie)
    case getCast(Movie)
    case getActor(Int)
    
    enum ImageSize: String {
        case Original = "original"
        case big = "w500"
        case medium = "w300"
        case small =  "w200"
    }
    
    case getImage(String, ImageSize)
}

extension MoviesAPI: TargetType {

    var baseURL: URL {
        switch self {
        case .getImage:
            return URL(string: "https://image.tmdb.org/t/p")!
        default:
            return URL(string: "https://api.themoviedb.org/3")!
        }
    }
    
    var path: String {
        switch self {
        case .getTopRatedMovies:
            return "/movie/top_rated"
        case .getMovieDetails(let movie):
            return "/movie/\(movie.id)"
        case .getMoviesByQuery:
            return "/search/movie"
        case .getImage(let path, let size): 
            return "/\(size.rawValue)\(path)"
        case .getCast(let movie):
            return "/movie/\(movie.id)/credits"
        case .getActor(let id):
            return "/person/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getTopRatedMovies,
             .getMoviesByQuery,
             .getMovieDetails,
             .getImage,
             .getCast,
             .getActor:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .getImage:
            return .requestPlain
        default:
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    var parameters: [String:Any] {
        switch self {
        case .getImage:
            return [:]
        case .getTopRatedMovies(let page):
            return ["api_key" : MoviesAPI.apiKey, "page" : page]
        case .getMoviesByQuery(let query):
            return ["api_key" : MoviesAPI.apiKey, "query" : query.query, "page" : query.page]
        default:
            return ["api_key" : MoviesAPI.apiKey]
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .getImage:
            return nil
        default:
            return ["Content-Type": "application/json", "Accept": "application/json"]
        }
    }

    public var validationType: ValidationType {
        return .successCodes
    }
    
}
