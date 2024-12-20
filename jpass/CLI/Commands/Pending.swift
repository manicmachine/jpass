//
//  Pending.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 10/25/24.
//
import ArgumentParser
import Foundation
import TextTable

extension JPass {
    struct Pending: AsyncParsableCommand, JpsAuthenticating {
        static let configuration = CommandConfiguration(abstract: "Retrieves all devices and usernames pending a password rotation. If a host is provided, results will be filtered to only that device.", aliases: ["pen", "p"])
        
        @Argument(help: "One of the following identifiers: Jamf id, computer name, management id, asset tag, bar code, or serial number.")
        var identifier: JpsIdentifier?
        
        @OptionGroup
        var globalOptions: GlobalOptions
        
        @Flag(name: .shortAndLong, help: "Maps management ids to computer names.")
        var mapComputers: Bool = false

        @Flag(name: .shortAndLong, help: "Outputs results in a compact format.")
        var compact: Bool = false
        
        var credentialService: CredentialService?
        var jpsService: JpsService?
        
        mutating func run() async {
            do {
                try await authenticate()
            } catch {
                JPass.exit(withError: error)
            }

            guard let jpsService = jpsService else {
                JPass.exit(withError: JPassError.InvalidState(error: "Invalid state: Missing JPS service after authentication."))
            }
            
            var pendingResults: PendingResponse
            do {
                pendingResults = try await jpsService.getPendingRotations()
            } catch {
                ConsoleLogger.shared.error("An error occurred while attempting to retrieve pending rotations from the JPS server: \(error)")
                JPass.exit(withError: ExitCode(1))
            }
            
            
            var computers: [String: ComputerInventoryEntry] = [:]

            do {
                if let identifier = identifier {
                    if identifier.type != .uuid {
                        computers = try await jpsService.getComputersByIdentifier(identifier)
                    }
                    
                    pendingResults.results = pendingResults.results.filter {
                        if computers.isEmpty {
                            return $0.user.clientManagementId == identifier.value
                        } else {
                            return computers[$0.user.clientManagementId] != nil
                        }
                    }
                }
            } catch {
                ConsoleLogger.shared.error("An error occurred while attempting to retrieve computers by identifier: \(error)")
                JPass.exit(withError: ExitCode(1))
            }
            
            if mapComputers {
                if !computers.isEmpty {
                    for i in pendingResults.results.indices {
                        let id = pendingResults.results[i].user.clientManagementId
                        if let entry = computers[id] {
                            pendingResults.results[i].user.computerName = entry.general.name
                        }
                    }
                } else {
                    let managementIds = pendingResults.results.map { $0.user.clientManagementId }
                    
                    do {
                        let computerResults = try await jpsService.getComputersByManagementId(managementIds)
                        for i in pendingResults.results.indices {
                            pendingResults.results[i].user.computerName = computerResults[pendingResults.results[i].user.clientManagementId]
                        }
                    } catch {
                        ConsoleLogger.shared.error("An error occurred while attempting to map computers by their management id: \(error)")
                        JPass.exit(withError: ExitCode(1))
                    }
                }
            }

            
            if !pendingResults.results.isEmpty {
                if compact {
                    pendingResults.results.forEach { result in
                        print(result)
                    }
                } else {
                    let escapingMapComputers = mapComputers // Capture this in a let so we can safely pass it along to an escaping closure
                    let table = TextTable<PendingEntry> {
                        var columns = [Column(title: "Date", value: $0.createdDate)]
                        if escapingMapComputers { columns.append(Column(title: "Computer Name", value: $0.user.computerName ?? "-")) }

                        columns.append(contentsOf: [Column(title: "Management ID", value: $0.user.clientManagementId),
                                                    Column(title: "User", value: $0.user.username),
                                                    Column(title: "GUID", value: $0.user.guid),
                                                    Column(title: "Source", value: $0.user.userSource)])
                        
                        return columns
                    }
                    
                    table.print(pendingResults.results, style: Style.psql)
                }
                
                ConsoleLogger.shared.info("\(pendingResults.results.count) pending rotations found.")
            } else {
                if let identifier = identifier {
                    ConsoleLogger.shared.info("No pending rotations were found for \(identifier.value).")
                } else {
                    ConsoleLogger.shared.info("No pending rotations were found.")
                }
                
                JPass.exit(withError: ExitCode(1))
            }
        }
        
        private enum CodingKeys: CodingKey {
            case globalOptions, mapComputers, compact, identifier
        }
    }
}
