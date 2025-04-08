//
//  Audit.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 10/25/24.
//
import ArgumentParser
import Foundation
import TextTable

extension JPass {
    struct Audit: AsyncParsableCommand, JpsAuthComputerResolving {
        static let configuration = CommandConfiguration(abstract: "Retrieves the full history of all local admin passwords for a given host. Includes the password, who viewed it, and when it was viewed.", aliases: ["aud", "a"])
        
        @OptionGroup
        var identifierOptions: SingleIdentifierOptions
        
        @OptionGroup
        var guidOptions: GuidOptions
        
        @Flag(name: .shortAndLong, help: "Map api client ids to client names.")
        var mapClients: Bool = false
        
        @Flag(exclusivity: .exclusive, help: "Determines sort order.")
        var sortOrder: SortOrder = .recentFirst
        
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
            
            let auditResponse: [PasswordAuditEntry]
            do {
                auditResponse = try await jpsService.getAuditFor(computer: managementId, user: guidOptions.localAdmin!, guid: guidOptions.guid)
            } catch {
                ConsoleLogger.shared.error("An error occurred while retrieving the audit log for \(identifierOptions.identifier.value): \(error).")
                JPass.exit(withError: ExitCode(1))
            }
            
            if auditResponse.isEmpty {
                ConsoleLogger.shared.info("No audit log entries found for \(identifierOptions.identifier.value).")
                JPass.exit(withError: ExitCode(1))
            }

            var unifiedAuditEntries: [UnifiedAuditEntry] = []
            auditResponse.forEach{ passwordAuditEntry in
                if passwordAuditEntry.audits.isEmpty {
                    unifiedAuditEntries.append(UnifiedAuditEntry(passwordEntry: passwordAuditEntry, auditEntry: nil))
                } else {
                    passwordAuditEntry.audits.forEach { auditEntry in
                        unifiedAuditEntries.append(UnifiedAuditEntry(passwordEntry: passwordAuditEntry, auditEntry: auditEntry))
                    }
                }
            }
            
            if sortOrder == .recentFirst {
                unifiedAuditEntries = unifiedAuditEntries.sorted { $0.expirationTime ?? Date(timeIntervalSince1970: 0) > $1.expirationTime ?? Date(timeIntervalSince1970: 0) }
            } else {
                unifiedAuditEntries = unifiedAuditEntries.sorted { $0.expirationTime ?? Date(timeIntervalSince1970: 0) < $1.expirationTime ?? Date(timeIntervalSince1970: 0) }
            }
            
            if mapClients {
                do {
                    let apiIntegrationsResponse = try await jpsService.getApiIntegrations()
                    
                    let apiClients = apiIntegrationsResponse.reduce(into: [String: String]()) { result, client in
                        result[client.clientId] = client.displayName
                    }
                    
                    for i in unifiedAuditEntries.indices {
                        if let id = unifiedAuditEntries[i].viewedBy, let displayName = apiClients[id] {
                            unifiedAuditEntries[i].viewedBy = displayName
                        }
                    }
                } catch {
                    ConsoleLogger.shared.error("An error occurred while retrieving API client information: \(error)")
                }
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = GlobalSettings.DATE_FORMAT

            let table = TextTable<UnifiedAuditEntry> {
                let expirationString = $0.expirationTime != nil ? dateFormatter.string(from: $0.expirationTime!) : "-"
                let dateSeenString = $0.dateSeen != nil ? dateFormatter.string(from: $0.dateSeen!) : "-"
                
                return [Column(title: "Password", value: $0.password),
                        Column(title: "Date Seen", value: dateSeenString),
                        Column(title: "Expiration Time", value: expirationString),
                        Column(title: "Viewed By", value: $0.viewedBy ?? "-")]
            }
            
            table.print(unifiedAuditEntries, style: Style.psql)

            ConsoleLogger.shared.info("\(unifiedAuditEntries.count) audit log entries found.")
        }
        
        private enum CodingKeys: CodingKey {
            case identifierOptions, guidOptions, globalOptions, mapClients, sortOrder
        }
    }
}

