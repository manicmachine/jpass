//
//  JPassError.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/20/24.
//

import Foundation

enum JPassError: LocalizedError {
    case Error(error: String)
    case InvalidState(error: String)
    case NoResults(error: String = "No results found")
    
    var errorDescription: String? {
        switch self {
            case .Error(let error): return error
            case .InvalidState(let error): return error
            case .NoResults(let error): return error
        }
    }
}
