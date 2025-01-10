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
    case InvalidURL = "Invalid URL provided"
    case InvalidCredentials = "Invalid credentials provided"
    case UnknownError = "An unknown error has occurred"
    
    // Http client errors
    case BadRequest = "400, bad request"
    case Unauthorized = "401, unauthorized access"
    case Forbidden = "403, forbidden access"
    case NotFound = "404, requested resource not found"
    case MethodNotAllowed = "405, method not allowed for given resource"
    
    // Http server errors
    case InternalError = "500, internal server error encountered"
    case BadGateway = "502, bad gateway"
    case ServiceUnavailable = "503, service unavailable"
    case GatewayTimeout = "504, gateway timeout"
    
    static func mapResponseCodeToError(for code: Int) -> JpsError {
        switch code {
        case 400: return JpsError.BadRequest
        case 401: return JpsError.Unauthorized
        case 403: return JpsError.Forbidden
        case 404: return JpsError.NotFound
        case 405: return JpsError.MethodNotAllowed
        case 500: return JpsError.InternalError
        case 502: return JpsError.BadGateway
        case 503: return JpsError.ServiceUnavailable
        case 504: return JpsError.GatewayTimeout
        default: return JpsError.UnknownError
        }
    }
}
