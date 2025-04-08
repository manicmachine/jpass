//
//  Set.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 10/25/24.
//
import ArgumentParser

extension JPass {
    struct Set: AsyncParsableCommand, JpsAuthComputerResolving {
        static let configuration = CommandConfiguration(abstract: "Sets the password of the specified local admin account for the given host(s).", aliases: ["s"])

        @OptionGroup
        var identifierOptions: MultipleIdentifiersOptions
        
        @OptionGroup
        var localAdminOptions: LocalAdminOptions

        @Option(name: [.short, .customLong("pass")], help: "The password to be set.")
        var password: String?
        
        @Flag(name: .shortAndLong, help: "Generate a random 14 to 29 character 3-word phrase for the password in the format <adverb>-<verb>-<noun>.")
        var generate: Bool = false
        
        @OptionGroup
        var globalOptions: GlobalOptions
        
        var localAdmin: String {
            return self.localAdminOptions.localAdmin!
        }

        var jpsService: JpsService?
        var credentialService: CredentialService?
        
        mutating func run() async {
            guard let password = password else {
                JPass.exit(withError: JPassError.InvalidState(error: "Password missing after validation."))
            }

            let idMappings: [String: String]
            do {
                idMappings = try await authenticateAndResolve()
            } catch {
                JPass.exit(withError: error)
            }
            
            guard let jpsService = jpsService else {
                JPass.exit(withError: JPassError.InvalidState(error: "Invalid state: Missing JPS service after authentication."))
            }
            
            // Create sendable variables to avoid concurrency warnings
            let _localAdmin = self.localAdmin
            let _generate = self.generate
            
            await withTaskGroup(of: Void.self) { group in
                for (identifier, managementId) in idMappings {
                    group.addTask {
                        do {
                            let pw = if _generate {
                                PassPhraseGenerator.generatePhrase()
                            } else {
                                password
                            }

                            try await jpsService.setPasswordFor(computer: managementId, user: _localAdmin, password: pw)
                            ConsoleLogger.shared.info("Password successfully set for \(identifier).")
                        } catch {
                            ConsoleLogger.shared.error("Failed to set password for \(identifier): \(error.localizedDescription)")
                        }
                    }
                }
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
            case identifierOptions, globalOptions, localAdminOptions, password, generate
        }
    }
}

