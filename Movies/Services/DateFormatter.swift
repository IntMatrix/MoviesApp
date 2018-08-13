//
//  DateFormatter.swift
//  Movies
//
//  Created by Maria Deygin on 7/31/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    //API date format
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        return formatter
    }()
    
    //Year display format
    static let yyyy: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    //Date display format
    static let mediumStyled: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

}
