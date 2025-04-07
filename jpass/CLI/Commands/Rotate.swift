//
//  Rotate.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 10/25/24.
//
import ArgumentParser

extension JPass {
    struct Rotate: AsyncParsableCommand, JpsAuthComputerResolving {
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
            let managementId: String
            do {
                managementId = try await authenticateAndResolve()
            } catch {
                JPass.exit(withError: error)
            }
            
            guard let jpsService = jpsService else {
                JPass.exit(withError: JPassError.InvalidState(error: "Invalid state: Missing JPS service after authentication."))
            }
            
            do {
                try await jpsService.rotatePasswordFor(computer: managementId, user: guidOptions.localAdmin!, guid: guidOptions.guid)
            } catch {
                JPass.exit(withError: error)
            }
        }
        
        private enum CodingKeys: CodingKey {
            case identifierOptions, guidOptions, globalOptions 
        }
    }
}
