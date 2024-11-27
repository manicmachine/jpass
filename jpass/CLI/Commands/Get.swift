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
    struct Get: AsyncParsableCommand, JpsAuthenticating, ComputerRecordResolver {
        static let configuration = CommandConfiguration(abstract: "Retrieves the local admin password for a given host.", aliases: ["g"])
        
        @OptionGroup
        var identifierOption: IdentifierOptions
        
        @OptionGroup
        var guidOptions: GuidOptions
        
        @OptionGroup
        var globalOptions: GlobalOptions
        
        @Flag(name: .shortAndLong, help: "Copies the password into your clipboard instead of printing to STDOUT.")
        var copy = false
        
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
            if identifierOption.identifier.type != .uuid {
                do {
                    managementId = try await resolve(from: identifierOption.identifier)
                } catch {
                    ConsoleLogger.shared.error("Failed to retrieve computer record for given identifier \(identifierOption.identifier.value)")
                    JPass.exit(withError: error)
                }
            } else {
                managementId = identifierOption.identifier.value
            }
            
            guard managementId.isEmpty == false else {
                JPass.exit(withError: JPassError.InvalidState(error: "No management ID available to query against."))
            }
            
            var password: String?
            do {
                password = try await jpsService.getPasswordFor(computer: managementId, user: guidOptions.localAdmin!, guid: guidOptions.guid)
            } catch {
                JPass.exit(withError: error)
            }
            
            if let password = password {
                if copy {
                    ConsoleLogger.shared.info("Password retrieved and copied to clipboard.")
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(password, forType: .string)
                } else {
                    print(password)
                }
            } else {
                ConsoleLogger.shared.error("No password found for \(identifierOption.identifier.value)")
                JPass.exit(withError: ExitCode(1))
            }
        }
        
        private enum CodingKeys: CodingKey {
            case globalOptions, identifierOption, guidOptions, copy
        }
    }
}
