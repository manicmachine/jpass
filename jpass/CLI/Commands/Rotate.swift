//
//  Rotate.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 10/25/24.
//
import ArgumentParser

extension JPass {
    struct Rotate: AsyncParsableCommand, JpsAuthComputerResolving {
        static let configuration = CommandConfiguration(abstract: "Triggers a password rotation for the given host(s).", aliases: ["rot", "r"])
        
        @OptionGroup
        var identifierOptions: MultipleIdentifiersOptions
        
        @OptionGroup
        var guidOptions: GuidOptions
        
        @OptionGroup
        var globalOptions: GlobalOptions
        
        var credentialService: CredentialService?
        var jpsService: JpsService?
        
        mutating func run() async {
            let managementIds: [String]
            do {
                managementIds = try await authenticateAndResolve()
            } catch {
                JPass.exit(withError: error)
            }
            
            guard let jpsService = jpsService else {
                JPass.exit(withError: JPassError.InvalidState(error: "Invalid state: Missing JPS service after authentication."))
            }

            // Create sendable variables to avoid concurrency warnings
            let _localAdmin = guidOptions.localAdmin!
            let _guid = guidOptions.guid

            await withTaskGroup(of: Void.self) { group in
                for managementId in managementIds {
                    group.addTask {
                        do {
                            try await jpsService.rotatePasswordFor(computer: managementId, user: _localAdmin, guid: _guid)
                            ConsoleLogger.shared.info("Password rotation triggered for \(managementId).")
                        } catch {
                            ConsoleLogger.shared.error("Failed to rotate password for \(managementId): \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        
        private enum CodingKeys: CodingKey {
            case identifierOptions, guidOptions, globalOptions 
        }
    }
}
