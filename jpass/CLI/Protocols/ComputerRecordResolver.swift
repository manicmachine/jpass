//
//  ComputerRecordResolver.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/26/24.
//
import ArgumentParser
import TextTable

protocol ComputerRecordResolver {
    var identifierOption: IdentifierOptions { get set }
    var credentialService: CredentialService? { get set }
    var jpsService: JpsService? { get set }
    
    func resolve(from: JpsIdentifier) async throws -> String
}


extension ComputerRecordResolver {
    func resolve(from: JpsIdentifier) async throws -> String {
        var managementId = ""
        let computers = try await jpsService!.getComputersByIdentifier(identifierOption.identifier)
        
        if computers.count > 1 {
            ConsoleLogger.shared.info("Multiple computers found for identifier: \(identifierOption.identifier.value)")
            var results = Dictionary<String, ComputerInventoryEntry>()
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
                
                if let _ = results[choice] {
                    managementId = choice
                } else {
                    print("Invalid option provided.")
                    choice.removeAll()
                }
            }
        } else if computers.count == 1 {
            managementId = computers.first!.key
        } else {
            ConsoleLogger.shared.error("No computers were found with the provided identifier: \(identifierOption.identifier.value)")
            JPass.exit(withError: ExitCode(1))
        }
        
        return managementId
    }
}
