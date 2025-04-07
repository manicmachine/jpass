//
//  Untitled.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 12/10/24.
//

protocol JpsAuthComputerResolving: JpsAuthenticating, ComputerRecordResolver {
    mutating func authenticateAndResolve() async throws -> [String]
}

extension JpsAuthComputerResolving {
    mutating func authenticateAndResolve() async throws -> [String] {
        try await authenticate()
        
        var managementIds = [String?](repeating: nil, count: self.identifierOptions.identifiers.count)
        for (index, id) in self.identifierOptions.identifiers.enumerated() {
            var managementId: String?

            if id.type == .uuid {
                managementId = id.value
            } else {
                do {
                    managementId = try await resolveManagementId(from: id)
                } catch {
                    ConsoleLogger.shared.error("Failed to retrieve computer record for given identifier \(id.value): \(error.localizedDescription)")
                    continue
                }
            }
            
            managementIds[index] = managementId
        }
        
        let validIds = managementIds.compactMap { $0 }

        if validIds.count == 0 {
            throw(JPassError.Error(error: "No valid management IDs found after resolving provided identifiers."))
        } else {
            return validIds
        }
    }
}
