//
//  JPassError.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/20/24.
//

import Foundation

enum JPassError: LocalizedError {
    case error(error: String)
    case invalidState(error: String)
    case noResults(error: String = "No results found")
    
    var errorDescription: String? {
        switch self {
        case .error(let error): return error
        case .invalidState(let error): return error
        case .noResults(let error): return error
        }
    }
}
