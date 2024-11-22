//
//  URLRequest+Method.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/7/24.
//

import Foundation

extension URLRequest {
    enum Method: String {
        case get
        case post
        case put
        case patch
        case delete
        case head
        case options
    }
}
