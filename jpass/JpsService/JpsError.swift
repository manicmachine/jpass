//
//  JpsError.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/7/24.
//


enum JpsError: String, Error {
    // General errors
    case InvalidURL = "Invalid URL provided"
    case InvalidCredentials = "Invalid credentials provided"
    case UnknownError = "An unknown error has occurred"
    
    // Http client errors
    case BadRequest = "Error 400"
    case Unauthorized = "Error 401, unauthorized access"
    case Forbidden = "Error 403, forbidden access"
    case NotFound = "Error 404, requested resource not found"
    case MethodNotAllowed = "Error 405, method not allowed for given resource"
    
    // Http server errors
    case InternalError = "Error 500, internal server error encountered"
    case BadGateway = "Error 502, bad gateway"
    case ServiceUnavailable = "Error 503, service unavailable"
    case GatewayTimeout = "Error 504, gateway timeout"
    
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
