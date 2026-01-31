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
        // swiftlint:disable:next line_length
        static let configuration = CommandConfiguration(abstract: "Retrieves all devices and usernames pending a password rotation. If identifiers are provided, results will be filtered to only those devices.", aliases: ["pen", "p"])
        
        @Argument(help: "One or more of the following identifiers: Jamf id, computer name, management id, asset tag, bar code, or serial number.")
        var identifiers: [JpsIdentifier] = []

        @Flag(name: .shortAndLong, help: "Maps management ids to computer names.")
        var mapComputers: Bool = false
        
        @Flag(exclusivity: .exclusive, help: "Determines sort order.")
        var sortOrder: SortOrder = .oldestFirst
        
        @Flag(name: .shortAndLong, help: "Adds a relative timestamp to the output.")
        var relative: Bool = false
        
        @OptionGroup
        var globalOptions: GlobalOptions
        
        var credentialService: CredentialService?
        var jpsService: JpsService?
        
        mutating func run() async {
            do {
                try await authenticate()
            } catch {
                JPass.exit(withError: error)
            }

            guard let jpsService = jpsService else {
                JPass.exit(withError: JPassError.invalidState(error: "Invalid state: Missing JPS service after authentication."))
            }
            
            var pendingResults: PendingResponse
            do {
                pendingResults = try await jpsService.getPendingRotations()
            } catch {
                ConsoleLogger.shared.error("An error occurred while attempting to retrieve pending rotations from the JPS server: \(error)")
                JPass.exit(withError: ExitCode(1))
            }
            
            var computers = [String: ComputerInventoryEntry]()

            do {
                if !identifiers.isEmpty {
                    for identifier in identifiers where identifier.type != .uuid {
                            computers.merge(try await jpsService.getComputersByIdentifier(identifier)) { (_, new) in
                                new
                        }
                    }
                    
                    pendingResults.results = pendingResults.results.filter { result in
                        // If we don't have any computer records, the user must've provided only management IDs as their identifier(s).
                        // Otherwise, we use the management IDs available in the computer record.
                        if computers.isEmpty {
                            return identifiers.contains { id in
                                result.user.clientManagementId == id.value
                            }
                        } else {
                            return computers[result.user.clientManagementId] != nil
                        }
                    }
                }
            } catch {
                ConsoleLogger.shared.error("An error occurred while attempting to retrieve computers by identifier: \(error)")
                JPass.exit(withError: ExitCode(1))
            }
            
            if mapComputers {
                if !computers.isEmpty {
                    for index in pendingResults.results.indices {
                        let id = pendingResults.results[index].user.clientManagementId
                        if let entry = computers[id] {
                            pendingResults.results[index].user.computerName = entry.general.name
                        }
                    }
                } else {
                    let managementIds = pendingResults.results.map { $0.user.clientManagementId }
                    
                    do {
                        let computerResults = try await jpsService.getComputersByManagementId(managementIds)
                        for index in pendingResults.results.indices {
                            pendingResults.results[index].user.computerName = computerResults[pendingResults.results[index].user.clientManagementId]
                        }
                    } catch {
                        ConsoleLogger.shared.error("An error occurred while attempting to map computers by their management id: \(error)")
                        JPass.exit(withError: ExitCode(1))
                    }
                }
            }
            
            if !pendingResults.results.isEmpty {
                if sortOrder == .newestFirst {
                    pendingResults.results = pendingResults.results.sorted { $0.createdDate > $1.createdDate }
                } else {
                    pendingResults.results = pendingResults.results.sorted { $0.createdDate < $1.createdDate }
                }
                
                let relativeDateTimeFormatter = RelativeDateTimeFormatter()
                let now = Date()
    
                let table = TextTable<PendingEntry> { [mapComputers, relative] in
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = GlobalSettings.dateFormat

                    var columns = [Column(title: "Date", value: dateFormatter.string(from: $0.createdDate))]
                    if relative {
                        columns.append(Column(title: "Relative", value: relativeDateTimeFormatter.localizedString(fromTimeInterval: $0.createdDate.timeIntervalSince(now))))
                    }
                    
                    if mapComputers { columns.append(Column(title: "Computer Name", value: $0.user.computerName ?? "-")) }

                    columns.append(contentsOf: [Column(title: "Management ID", value: $0.user.clientManagementId),
                                                Column(title: "User", value: $0.user.username),
                                                Column(title: "GUID", value: $0.user.guid),
                                                Column(title: "Source", value: $0.user.userSource)])
                    
                    return columns
                }
                
                table.print(pendingResults.results, style: Style.psql)
                
                ConsoleLogger.shared.info("\(pendingResults.results.count) pending rotations found.")
            } else {
                if !identifiers.isEmpty {
                    let identifiersString = identifiers.map { $0.value }.joined(separator: ", ")
                    ConsoleLogger.shared.info("No pending rotations were found for \(identifiersString).")
                } else {
                    ConsoleLogger.shared.info("No pending rotations were found.")
                }
                
                JPass.exit(withError: ExitCode(1))
            }
        }
        
        private enum CodingKeys: CodingKey {
            case globalOptions, mapComputers, identifiers, sortOrder, relative
        }
    }
}
