//
//  Rotate.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 10/25/24.
//
import ArgumentParser

extension JPass {
    struct Rotate: AsyncParsableCommand, JpsAuthComputerResolving {
        static let configuration = CommandConfiguration(
            abstract: "Securely triggers a password rotation for the given host(s).",
            aliases: ["rot", "r"]
        )
        
        @OptionGroup
        var identifierOptions: MultipleIdentifiersOptions
        
        @OptionGroup
        var guidOptions: GuidOptions
        
        @OptionGroup
        var globalOptions: GlobalOptions
        
        var credentialService: CredentialService?
        var jpsService: JpsService?
        
        mutating func run() async {
            let idMappings: [String: String]
            do {
                idMappings = try await authenticateAndResolve()
            } catch {
                JPass.exit(withError: error)
            }
            
            guard let jpsService = jpsService else {
                JPass.exit(withError: JPassError.invalidState(error: "Invalid state: Missing JPS service after authentication."))
            }

            await withTaskGroup(of: Void.self) { group in
                for (identifier, managementId) in idMappings {
                    group.addTask { [localAdmin = guidOptions.localAdmin!, guid = guidOptions.guid] in
                        do {
                            try await jpsService.rotatePasswordFor(computer: managementId, user: localAdmin, guid: guid)
                            ConsoleLogger.shared.info("Password rotation triggered for \(identifier).")
                        } catch {
                            ConsoleLogger.shared.error("Failed to rotate password for \(identifier): \(error.localizedDescription)")
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
