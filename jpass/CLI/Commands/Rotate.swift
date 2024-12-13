//
//  Rotate.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 10/25/24.
//
import ArgumentParser

extension JPass {
    struct Rotate: AsyncParsableCommand, JpsAuthenticating, ComputerRecordResolver {
        static let configuration = CommandConfiguration(abstract: "Triggers a password rotation for the specified host.", aliases: ["rot", "r"])
        
        @OptionGroup
        var identifierOptions: IdentifierOptions
        
        @OptionGroup
        var guidOptions: GuidOptions
        
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
                JPass.exit(withError: JPassError.InvalidState(error: "Invalid state: Missing JPS service after authentication."))
            }
            
            var managementId = ""
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
            
            guard managementId.isEmpty == false else {
                JPass.exit(withError: JPassError.InvalidState(error: "No management ID available to query against."))
            }
            
            do {
                if let _ = try await jpsService.getPasswordFor(computer: managementId, user: guidOptions.localAdmin!, guid: guidOptions.guid) {
                    ConsoleLogger.shared.info("Password rotation triggered for \(identifierOptions.identifier.value).")
                } else {
                    ConsoleLogger.shared.error("No password found for \(identifierOptions.identifier.value). Rotation may not have been triggered.")
                    JPass.exit(withError: ExitCode(1))
                }
            } catch {
                JPass.exit(withError: error)
            }
        }
        
        private enum CodingKeys: CodingKey {
            case identifierOptions, guidOptions, globalOptions 
        }
    }
}
