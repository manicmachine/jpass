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
        
        self.credentialService = CredentialService(for: user, skipCache: self.globalOptions.noCache)
        guard let credentialService = self.credentialService else { throw JPassError.InvalidState(error: "Credential Service missing after initialization.")}
        let password = credentialService.getPassword()
        
        self.jpsService = try JpsService(url: server, username: user, password: password)
        try await jpsService!.authenticate()
        credentialService.setPassword(password)
    }
}
