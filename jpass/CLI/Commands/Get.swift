//
//  Get.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 10/25/24.
//

import ArgumentParser
import Rainbow
import TextTable

extension JPass {
    struct Get: AsyncParsableCommand, JpsAuthComputerResolving {
        static let configuration = CommandConfiguration(
            abstract: "Retrieves the local admin password for a given host.",
            aliases: ["g"]
        )
        
        @OptionGroup
        var identifierOptions: SingleIdentifierOptions
        
        @OptionGroup
        var guidOptions: GuidOptions
        
        @OptionGroup
        var globalOptions: GlobalOptions
        
        @Flag(name: .shortAndLong, help: "Copy password into your clipboard instead of printing to STDOUT.")
        var copy = false
        
        @Flag(name: .shortAndLong, help: "Return the password in an easily communicated NATO phonetic format.")
        var nato: Bool = false
        
        @Flag(name: .long, help: "Disable color output.")
        var noColor: Bool = false
        
        var credentialService: CredentialService?
        var jpsService: JpsService?
        
        var shouldColorify: Bool {
            return !noColor && !copy
        }
        
        mutating func run() async {
            let managementId: String
            do {
                managementId = try await authenticateAndResolve().first!.value
            } catch {
                JPass.exit(withError: error)
            }
            
            guard let jpsService = jpsService else {
                JPass.exit(withError: JPassError.invalidState(error: "Invalid state: Missing JPS service after authentication."))
            }
            
            var password: String?
            do {
                password = try await jpsService.getPasswordFor(computer: managementId, user: guidOptions.localAdmin!, guid: guidOptions.guid)
            } catch {
                JPass.exit(withError: error)
            }
            
            if let password = password {
                var processedPassword = shouldColorify ? ColorGenerator.colorifyCharacters(in: password) : password
                
                if nato {
                    let natoPhrase = NatoPhoneticGenerator.generateCodePhrase(for: password, colored: shouldColorify)
                    processedPassword = "Password: \(processedPassword)\n\n\(natoPhrase)"
                }
                
                if copy {
                    ConsoleLogger.shared.info("Password retrieved and copied to clipboard.")
                    Pasteboard.copy(processedPassword)
                } else {
                    ConsoleLogger.shared.print(processedPassword)
                }
            } else {
                ConsoleLogger.shared.error("No password found for \(identifierOptions.identifier.value)")
                JPass.exit(withError: ExitCode(1))
            }
        }
        
        private enum CodingKeys: CodingKey {
            case identifierOptions, guidOptions, nato, globalOptions, copy, noColor
        }
    }
}
