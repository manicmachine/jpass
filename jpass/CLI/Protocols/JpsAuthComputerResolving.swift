//
//  Untitled.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 12/10/24.
//

protocol JpsAuthComputerResolving: JpsAuthenticating, ComputerRecordResolver {
    mutating func authenticateAndResolve() async throws -> String
}

extension JpsAuthComputerResolving {
    mutating func authenticateAndResolve() async throws -> String {
        try await authenticate()
        
        let managementId: String
        if identifierOptions.identifier.type != .uuid {
            do {
                managementId = try await resolve(from: identifierOptions.identifier)
            } catch {
                ConsoleLogger.shared.error("Failed to retrieve computer record for given identifier \(identifierOptions.identifier.value)")
                JPass.exit(withError: error)
            }
        } else {
            managementId = identifierOptions.identifier.value
        }
        
        return managementId
    }
}
