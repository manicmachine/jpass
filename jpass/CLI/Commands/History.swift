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
    struct History: AsyncParsableCommand, JpsAuthenticating, ComputerRecordResolver {
        static let configuration = CommandConfiguration(abstract: "Retrieves the full history of all local admin passwords for a given host. Includes date created, date last seen, expiration time, and rotational status.", aliases: ["his", "h"])
        
        @OptionGroup
        var identifierOption: IdentifierOptions
        
        @OptionGroup
        var globalOptions: GlobalOptions
        
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
            
            let managementId: String
            if identifierOption.identifier.type != .uuid {
                do {
                    managementId = try await resolve(from: identifierOption.identifier)
                } catch {
                    ConsoleLogger.shared.error("Failed to retrieve computer record for given identifier \(identifierOption.identifier.value)")
                    JPass.exit(withError: error)
                }
            } else {
                managementId = identifierOption.identifier.value
            }
            
            var historyResults: [HistoryEntry]
            do {
                historyResults = try await jpsService.getHistoryFor(computer: managementId)
            } catch {
                ConsoleLogger.shared.error("An error occurred retrieving the local admin password history for \(identifierOption.identifier.value): \(error).")
                JPass.exit(withError: ExitCode(1))
            }
            
            if historyResults.isEmpty {
                ConsoleLogger.shared.info("No history entries found for \(identifierOption.identifier.value).")
                JPass.exit(withError: ExitCode(1))
            }
            
            historyResults = historyResults.filter { $0.eventTime != nil }
            historyResults = historyResults.sorted { $0.eventTime! < $1.eventTime! }
            
            if compact {
                historyResults.forEach {
                    print($0)
                }
            } else {
                let table = TextTable<HistoryEntry> {
                    [Column(title: "Date", value: $0.eventTime ?? "-"),
                     Column(title: "Event Type", value: $0.eventType),
                     Column(title: "Username", value: $0.username),
                     Column(title: "Source", value: $0.userSource),
                     Column(title: "Viewed By", value: $0.viewedBy ?? "-")
                    ]
                }
                
                table.print(historyResults, style: Style.psql)
                ConsoleLogger.shared.info("\(historyResults.count) history entries found.")
            }
        }
        
        private enum CodingKeys: CodingKey {
            case identifierOption, globalOptions, compact
        }
    }
}
