//
//  JPassError.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/20/24.
//

enum JPassError: Error {
    case Error(error: String)
    case InvalidState(error: String)
    case NoResults
}
