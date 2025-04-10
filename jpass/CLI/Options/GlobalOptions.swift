//
//  GlobalOptions.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/7/24.
//

import ArgumentParser
import Foundation
import OSLog

struct GlobalOptions: ParsableArguments {
    static let userKey = "JPASS_USER"
    static let serverKey = "JPASS_SERVER"
    static let clientIdKey = "JPASS_CLIENT_ID"
    static let noCacheKey = "JPASS_NO_CACHE"
    
    @Option(name: .shortAndLong, help: "The Jamf Pro server URL and port (if not standard). If no port is defined, the default port 443 will be used for Jamf Cloud instances and 8443 for everything else. Can be set using the environment variable \(serverKey).")
    var server: String?
    
    @Option(name: .shortAndLong, help: "The Jamf Pro user used for authentication. Can be set using the environment variable \(userKey).")
    var user: String?
    
    @Option(name: .long, help: "The Jamf Pro API client used for authentication. Can be set using the environment variable \(clientIdKey).")
    var clientId: String?
    
    @Flag(name: .long, help: "Disables retrieval and caching of credentials in local keychain. Can be set using the environment variable \(noCacheKey).")
    var noCache = false
    
    @Flag(name: .shortAndLong, help: "Enable verbose logging.")
    var verbose = false
    
    var authenticatingUser: String? {
        if let user {
            return user
        } else if let clientId {
            return clientId
        } else {
            return nil
        }
    }
    
    var isApiClient: Bool {
        return clientId != nil
    }
    
    mutating func validate() throws {
        // Retrieve any set environment variables
        if server == nil {
            if let envVar = ProcessInfo.processInfo.environment[Self.serverKey] {
                server = envVar
            } else {
                throw ValidationError("Server address must be provided.")
            }
        }
        
        let userEnvVar = ProcessInfo.processInfo.environment[Self.userKey]
        let clientIdEnvVar = ProcessInfo.processInfo.environment[Self.clientIdKey]
        
        if (user == nil && userEnvVar == nil) && (clientId == nil && clientIdEnvVar == nil) {
            throw ValidationError("A Jamf user or API client id must be provided.")
        } else if (user != nil || userEnvVar != nil) && (clientId != nil || clientIdEnvVar != nil) {
            throw ValidationError("Both a Jamf user and API client were provided but only 1 is allowed.")
        } else {
            if let userEnvVar, user == nil {
                user = userEnvVar
            } else if let clientIdEnvVar, clientId == nil {
                clientId = clientIdEnvVar
            }
        }
        
        if let _ = ProcessInfo.processInfo.environment[Self.noCacheKey] {
            noCache = true
        }
        
        GlobalSettings.shared.verbose = verbose
    }
}
