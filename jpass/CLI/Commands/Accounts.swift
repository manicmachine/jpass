//
//  Accounts.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/27/24.
//

import ArgumentParser
import TextTable

extension JPass {
    struct Accounts: AsyncParsableCommand, JpsAuthenticating, ComputerRecordResolver {
        static let configuration = CommandConfiguration(abstract: "Retrieves all LAPS capable accounts for a given host.", aliases: ["acc", "a"])

        @OptionGroup
        var identifierOptions: IdentifierOptions
        
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
            
            let accountsResults: [AccountsEntry]
            do {
                accountsResults = try await jpsService.getAccountsFor(computer: managementId)
            } catch {
                ConsoleLogger.shared.error("An error occurred retrieving the local admin accounts for \(identifierOptions.identifier.value): \(error).")
                JPass.exit(withError: ExitCode(1))
            }
            
            if accountsResults.isEmpty {
                ConsoleLogger.shared.info("No local admin accounts found for \(identifierOptions.identifier.value).")
                JPass.exit(withError: ExitCode(1))
            }
            
            if compact {
                accountsResults.forEach {
                    print($0)
                }
            } else {
                let table = TextTable<AccountsEntry> {
                    [Column(title: "Username", value: $0.username),
                     Column(title: "User Source", value: $0.userSource),
                     Column(title: "GUID", value: $0.guid),
                     Column(title: "Management ID", value: $0.clientManagementId)
                    ]
                }
                
                table.print(accountsResults, style: Style.psql)
                ConsoleLogger.shared.info("\(accountsResults.count) local admin accounts found.")
            }
        }
        
        private enum CodingKeys: CodingKey {
            case identifierOptions, globalOptions, compact
        }
    }
}
