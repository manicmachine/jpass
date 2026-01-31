//
//  JpsError.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/7/24.
//
import Foundation

enum JpsError: String, LocalizedError {
    var errorDescription: String? {
        return self.rawValue
    }

    // General errors
    case invalidURL = "Invalid URL provided"
    case invalidCredentials = "Invalid credentials provided"
    case unknownError = "An unknown error has occurred"
    
    // Http client errors
    case badRequest = "400, bad request"
    case unauthorized = "401, unauthorized access"
    case forbidden = "403, forbidden access"
    case notFound = "404, requested resource not found"
    case methodNotAllowed = "405, method not allowed for given resource"
    
    // Http server errors
    case internalError = "500, internal server error encountered"
    case badGateway = "502, bad gateway"
    case serviceUnavailable = "503, service unavailable"
    case gatewayTimeout = "504, gateway timeout"
    
    static func mapResponseCodeToError(for code: Int) -> JpsError {
        switch code {
        case 400: return JpsError.badRequest
        case 401: return JpsError.unauthorized
        case 403: return JpsError.forbidden
        case 404: return JpsError.notFound
        case 405: return JpsError.methodNotAllowed
        case 500: return JpsError.internalError
        case 502: return JpsError.badGateway
        case 503: return JpsError.serviceUnavailable
        case 504: return JpsError.gatewayTimeout
        default: return JpsError.unknownError
        }
    }
}
