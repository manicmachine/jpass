//
//  History.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 10/25/24.
//
import ArgumentParser
import Foundation
import TextTable

extension JPass {
    struct History: AsyncParsableCommand, JpsAuthComputerResolving {
        static let configuration = CommandConfiguration(abstract: "Retrieves the full history of all local admin passwords for a given host. Includes date created, date last seen, expiration time, and rotational status.", aliases: ["his", "h"])
        
        @OptionGroup
        var identifierOptions: SingleIdentifierOptions

        @Flag(name: .shortAndLong, help: "Map api client ids to client names.")
        var mapClients: Bool = false
        
        @Flag(exclusivity: .exclusive, help: "Determines sort order.")
        var sortOrder: SortOrder = .newestFirst
        
        @Flag(name: .shortAndLong, help: "Adds a relative timestamp to the output.")
        var relative: Bool = false
        
        @OptionGroup
        var globalOptions: GlobalOptions
        
        var credentialService: CredentialService?
        var jpsService: JpsService?
        
        mutating func run() async {
            let managementId: String
            do {
                managementId = try await authenticateAndResolve().first!.value
            } catch {
                JPass.exit(withError: error)
            }
            
            guard let jpsService = jpsService else {
                JPass.exit(withError: JPassError.InvalidState(error: "Invalid state: Missing JPS service after authentication."))
            }
            
            var historyResults: [HistoryEntry]
            do {
                historyResults = try await jpsService.getHistoryFor(computer: managementId)
            } catch {
                ConsoleLogger.shared.error("An error occurred while retrieving the local admin password history for \(identifierOptions.identifier.value): \(error).")
                JPass.exit(withError: ExitCode(1))
            }
            
            if historyResults.isEmpty {
                ConsoleLogger.shared.info("No history entries found for \(identifierOptions.identifier.value).")
                JPass.exit(withError: ExitCode(1))
            }
            
            historyResults = historyResults.filter { $0.eventTime != nil }
            
            if sortOrder == .newestFirst {
                historyResults = historyResults.sorted { $0.eventTime ?? Date(timeIntervalSince1970: 0) > $1.eventTime ?? Date(timeIntervalSince1970: 0) }
            } else {
                historyResults = historyResults.sorted { $0.eventTime ?? Date(timeIntervalSince1970: 0) < $1.eventTime ?? Date(timeIntervalSince1970: 0) }
            }
            
            if mapClients {
                do {
                    let apiIntegrationsResponse = try await jpsService.getApiIntegrations()
                    
                    let apiClients = apiIntegrationsResponse.reduce(into: [String: String]()) { result, client in
                        result[client.clientId] = client.displayName
                    }
                    
                    for i in historyResults.indices {
                        if let id = historyResults[i].viewedBy, let displayName = apiClients[id] {
                            historyResults[i].viewedBy = displayName
                        }
                    }
                } catch {
                    ConsoleLogger.shared.error("An error occurred while retrieving API client information: \(error)")
                }
            }
            
            let dateFormatter = DateFormatter()
            let relativeDateTimeFormatter = RelativeDateTimeFormatter()
            let now = Date()
            
            dateFormatter.dateFormat = GlobalSettings.DATE_FORMAT
            
            
            // Create not-mutating copies of these so we can safely pass them to an escaping closure
            let _relative = relative
            
            let table = TextTable<HistoryEntry> {
                let dateString = $0.eventTime != nil ? dateFormatter.string(from: $0.eventTime!) : "-"
                var columns = [Column(title: "Date", value: dateString)]
                
                if _relative {
                    let relativeDateString: String
                    
                    if let eventTime = $0.eventTime {
                        relativeDateString = relativeDateTimeFormatter.localizedString(fromTimeInterval: eventTime.timeIntervalSince(now))
                    } else {
                        relativeDateString = "-"
                    }
                    
                    columns.append(Column(title: "Relative Date", value: relativeDateString))
                }
                
                columns.append(contentsOf: [Column(title: "Event Type", value: $0.eventType),
                 Column(title: "Username", value: $0.username),
                 Column(title: "Source", value: $0.userSource),
                 Column(title: "Viewed By", value: $0.viewedBy ?? "-")
                ])
                
                return columns
            }
            
            table.print(historyResults, style: Style.psql)
            
            ConsoleLogger.shared.info("\(historyResults.count) history entries found.")
        }
        
        private enum CodingKeys: CodingKey {
            case identifierOptions, globalOptions, mapClients, sortOrder, relative
        }
    }
}
