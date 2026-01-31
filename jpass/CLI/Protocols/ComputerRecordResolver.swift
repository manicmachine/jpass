//
//  ComputerRecordResolver.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/26/24.
//
import ArgumentParser
import TextTable

protocol ComputerRecordResolver {
    associatedtype IDOptions: IdentifierOption

    var identifierOptions: IDOptions { get set }
    var credentialService: CredentialService? { get set }
    var jpsService: JpsService? { get set }
    
    func resolveManagementId(for: JpsIdentifier) async throws -> String?
}

extension ComputerRecordResolver {
    func resolveManagementId(for identifier: JpsIdentifier) async throws -> String? {
        guard let jpsService = jpsService else {
            throw JPassError.invalidState(error: "Attempted to resolve identifier before JpsService has been initalized.")
        }

        var managementId: String?
        let computers = try await jpsService.getComputersByIdentifier(identifier)
        
        if computers.count > 1 {
            ConsoleLogger.shared.info("Multiple computers found for identifier: \(identifier.value)")
            var results: [String: ComputerInventoryEntry] = [:]
            for (_, computerInventoryEntry) in computers {
                results[computerInventoryEntry.id] = computerInventoryEntry
            }
            
            let table = TextTable<ComputerInventoryEntry> {
                [Column(title: "Jamf ID", value: $0.id),
                 Column(title: "Computer", value: $0.general.name),
                 Column(title: "Serial Number", value: $0.hardware.serialNumber)]
            }
            
            table.print(computers.values, style: Style.psql)
            
            var choice = ""
            while choice.isEmpty {
                print("Enter the Jamf ID of the computer you wish to retrieve: ", terminator: "")
                
                if let input = readLine() {
                    choice = input
                }
                
                if results[choice] != nil {
                    managementId = choice
                } else {
                    print("Invalid option provided.")
                    choice.removeAll()
                }
            }
        } else if computers.count == 1 {
            managementId = computers.first!.key
        } else {
            ConsoleLogger.shared.error("No computers were found with the provided identifier: \(identifier.value)")
        }
        
        if let mId = managementId {
            ConsoleLogger.shared.verbose("Resolved identifier '\(identifier.value)' to management ID '\(mId)'.")
        } else {
            ConsoleLogger.shared.error("Failed to resolve identifier '\(identifier.value)' to a management ID.")
        }

        return managementId
    }
}
