//
//  GlobalOptions.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/7/24.
//

import ArgumentParser
import Foundation
import OSLog

struct GlobalOptions: ParsableCommand {
    static let userKey = "JPASS_USER"
    static let serverKey = "JPASS_SERVER"
    
    @Option(name: .shortAndLong, help: "The Jamf Pro server URL and port (if not standard). If not port is defined, the default port 443 will be used for Jamf Cloud instances and 8443 for everything else. Can be set using the environment variable \(serverKey).")
    var server: String?
    
    @Option(name: .shortAndLong, help: "The Jamf Pro user used for authentication. Can be set using the environment variable \(userKey).")
    var user: String?
    
    @Flag(name: .long, help: "Disables retrieval and caching of credentials in local keychain.")
    var noCache = false
    
    @Flag(name: .shortAndLong, help: "Enable verbose logging.")
    var verbose = false
    
    mutating func validate() throws {
        if server == nil {
            if let envVar = ProcessInfo.processInfo.environment[GlobalOptions.serverKey] {
                server = envVar
            } else {
                throw ValidationError("Server address must be provided.")
            }
        }
        
        if user == nil {
            if let envVar = ProcessInfo.processInfo.environment[GlobalOptions.userKey] {
                user = envVar
            } else {
                throw ValidationError("Jamf user must be provided.")
            }
        }
        
        // This is a workaround to dynamically set the logging level based upon the flag state
        ConsoleLogger.verbose = verbose
    }
}
