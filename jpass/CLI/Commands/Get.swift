//
//  Get.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 10/25/24.
//
import AppKit
import ArgumentParser
import TextTable

extension JPass {
    struct Get: AsyncParsableCommand, JpsAuthComputerResolving {
        static let configuration = CommandConfiguration(abstract: "Retrieves the local admin password for a given host.", aliases: ["g"])
        
        @OptionGroup
        var identifierOptions: SingleIdentifierOptions
        
        @OptionGroup
        var guidOptions: GuidOptions
        
        @OptionGroup
        var globalOptions: GlobalOptions
        
        @Flag(name: .shortAndLong, help: "Copies the password into your clipboard instead of printing to STDOUT.")
        var copy = false
        
        @Flag(name: .shortAndLong, help: "Returns the password in an easily communicated NATO phonetic format.")
        var nato: Bool = false
        
        var credentialService: CredentialService?
        var jpsService: JpsService?
        
        mutating func run() async {
            let managementId: String
            do {
                managementId = try await authenticateAndResolve().first!
            } catch {
                JPass.exit(withError: error)
            }
            
            guard let jpsService = jpsService else {
                JPass.exit(withError: JPassError.InvalidState(error: "Invalid state: Missing JPS service after authentication."))
            }
            
            var password: String?
            do {
                password = try await jpsService.getPasswordFor(computer: managementId, user: guidOptions.localAdmin!, guid: guidOptions.guid)
            } catch {
                JPass.exit(withError: error)
            }
            
            if var password = password {
                if nato {
                    password = "Password: \(password)\n\n\(NatoPhoneticGenerator.generateCodePhrase(for: password))"
                }
                
                if copy {
                    ConsoleLogger.shared.info("Password retrieved and copied to clipboard.")
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(password, forType: .string)
                } else {
                    print(password)
                }
            } else {
                ConsoleLogger.shared.error("No password found for \(identifierOptions.identifier.value)")
                JPass.exit(withError: ExitCode(1))
            }
        }
        
        private enum CodingKeys: CodingKey {
            case identifierOptions, guidOptions, nato, globalOptions, copy
        }
    }
}
