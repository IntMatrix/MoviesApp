//
//  Actor.swift
//  Movies
//
//  Created by Maria Deygin on 8/1/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import Foundation

enum Gender: Int, Codable {
    case female = 1
    case male = 2
    case unknown = 0
}

struct Actor: Codable {
    
    var id: Int?
    var gender: Gender?
    var profilePath: String?
    var name: String?
    
    var castID:Int?
    var character: String?
    var creditID: String?
    var order: Int?
    
    var biography:String?
    var birthday: Date?
    var deathday: Date?
    var popularity: Double?
    var homepage: String?
    var placeOfBirth: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case gender
        case profilePath = "profile_path"
        case name
        
        case castID = "cast_id"
        case character
        case creditID = "credit_id"
        case order
        
        case biography
        case birthday
        case deathday
        case popularity
        case homepage
        case placeOfBirth = "place_of_birth"
    }
}

extension Actor {
    
    struct Batch: Codable {
        var cast: [Actor] = []
        enum CodingKeys: String, CodingKey {
            case cast
        }
    }
    
}

