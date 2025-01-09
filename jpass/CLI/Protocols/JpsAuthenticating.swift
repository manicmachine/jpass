//
//  JamfService.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/20/24.
//

import os

protocol JpsAuthenticating {
    var globalOptions: GlobalOptions { get set }

    var credentialService: CredentialService? { get set }
    var jpsService: JpsService? { get set }
    
    mutating func authenticate() async throws
}

extension JpsAuthenticating {
    mutating func authenticate() async throws {
        guard let user = globalOptions.user, let server = globalOptions.server else {
            throw JPassError.InvalidState(error: "Missing user or server after argument validation.")
        }
        
        self.jpsService = try JpsService(url: server)
        guard let jpsService = self.jpsService else {
            throw JPassError.InvalidState(error: "Jps Service missing after initialization.")
        }
        
        self.credentialService = CredentialService(for: user, on: jpsService.baseUrl, using: jpsService.port, skipCache: self.globalOptions.noCache)
        guard let credentialService = self.credentialService else { throw JPassError.InvalidState(error: "Credential Service missing after initialization.")}
        
        // This loop accounts for when the cached credentials provided by CredentialService are no longer valid (JPS returns 401).
        // In which case we then delete the existing cache and prompt for new credentials.
        while true {
            let password = credentialService.getPassword()
            
            do {
                try await jpsService.authenticate(username: user, password: password)
                break
            } catch JpsError.Unauthorized {
                if credentialService.passwordFromCache {
                    ConsoleLogger.shared.error("Cached credentials resulted in 401 from the JPS. Deleting existing cache and prompting for new credentials.")
                    credentialService.deleteCredentials()
                } else {
                    throw JpsError.Unauthorized
                }
            }
        }

        try credentialService.cacheCredentials()
    }
}
