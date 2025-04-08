//
//  Untitled.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 12/10/24.
//

protocol JpsAuthComputerResolving: JpsAuthenticating, ComputerRecordResolver {
    mutating func authenticateAndResolve() async throws -> [String:String]
}

extension JpsAuthComputerResolving {
    mutating func authenticateAndResolve() async throws -> [String:String] {
        try await authenticate()
        
        ConsoleLogger.shared.verbose("Resolving provided identifier(s) to management ID(s).")
        var managementIdMappings = [String:String](minimumCapacity: self.identifierOptions.identifiers.count)
        
        for id in self.identifierOptions.identifiers {
            var managementId: String?

            if id.type == .uuid {
                managementId = id.value
            } else {
                do {
                    managementId = try await resolveManagementId(for: id)
                } catch {
                    ConsoleLogger.shared.error("Failed to retrieve computer record for given identifier \(id.value): \(error.localizedDescription)")
                    continue
                }
            }
            
            managementIdMappings[id.value] = managementId
        }
        
        let validIds = managementIdMappings.compactMapValues { $0 }

        if validIds.count == 0 {
            throw(JPassError.Error(error: "No valid management IDs found after resolving provided identifiers."))
        } else {
            return validIds
        }
    }
}
