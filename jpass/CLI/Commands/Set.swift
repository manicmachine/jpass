//
//  Set.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 10/25/24.
//
import ArgumentParser

extension JPass {
    struct Set: AsyncParsableCommand, JpsAuthComputerResolving {
        static let configuration = CommandConfiguration(abstract: "Sets the local admin password for the specified user on a given host.", aliases: ["s"])

        @OptionGroup
        var identifierOptions: IdentifierOptions
        
        @Option(name: [.short, .customLong("ladmin")], help: "The local admin account whose password will be set.")
        var localAdmin: String

        @Option(name: [.short, .customLong("pass")], help: "The password to be set.")
        var password: String?
        
        @Flag(name: .shortAndLong, help: "Generate a random 3-word phrase for the password.")
        var generate: Bool = false
        
        @OptionGroup
        var globalOptions: GlobalOptions
        
        var jpsService: JpsService?
        var credentialService: CredentialService?
        
        mutating func run() async {
            guard let password = password else {
                JPass.exit(withError: JPassError.InvalidState(error: "Password missing after validation."))
            }

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
                if try await jpsService.setPasswordFor(computer: managementId, user: localAdmin, password: password) {
                    ConsoleLogger.shared.info("Password successfully set to \(password)")
                }
            } catch {
                ConsoleLogger.shared.error("An error occurred while attempting to set the password for \(localAdmin): \(error)")
                JPass.exit(withError: ExitCode(1))
            }
        }
        
        mutating func validate() throws {
            if password == nil {
                if generate {
                    password = PassPhraseGenerator.generatePhrase()
                } else {
                    if let pw = CredentialService.promptForPassword(with: "Password for \(localAdmin): ", hideInput: false) {
                        password = pw
                    } else {
                        ConsoleLogger.shared.error("No password provided. Exiting.")
                        JPass.exit(withError: ExitCode(1))
                    }
                }
            } else if generate {
                throw ValidationError("Both generate and password were provided but only 1 is allowed.")
            }
        }
        
        private enum CodingKeys: CodingKey {
            case identifierOptions, globalOptions, localAdmin, password, generate
        }
    }
}

