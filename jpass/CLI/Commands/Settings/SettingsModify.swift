//
//  Modify.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 12/20/24.
//

import ArgumentParser

extension JPass.Settings {
    struct SettingsModify: AsyncParsableCommand, JpsAuthenticating {
        static let configuration = CommandConfiguration(commandName: "modify", abstract: "Modifies the global local admin password settings.", aliases: ["mod", "m"])
        
        @Flag(inversion: .prefixedEnableDisable)
        var autoDeploy: Bool?
        
        @Flag(inversion: .prefixedEnableDisable)
        var autoRotate: Bool?
        
        @Option(help: "Set the rotation time for viwed passwords, in seconds.")
        var passwordRotationTime: Int?
        
        @Option(help: "Set the rotation time for unseen passwords, in seconds.")
        var autoRotateExpirationTime: Int?
        
        @Flag(help: "Automatically confirm changes.")
        var confirm: Bool = false
        
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
            
            do {
                let settings = ModifySettingsRequest(autoDeployEnabled: autoDeploy, autoRotateEnabled: autoRotate, passwordRotationTime: passwordRotationTime, autoRotateExpirationTime: autoRotateExpirationTime)
                try await jpsService.setLocalAdminPasswordSettings(with: settings)
                ConsoleLogger.shared.info("Local admin password settings successfully updated.")
            } catch {
                ConsoleLogger.shared.error("An error occurred while attempting to local admin password settings: \(error)")
                JPass.exit(withError: ExitCode(1))
            }
        }
        
        private enum CodingKeys: CodingKey {
            case autoDeploy, autoRotate, passwordRotationTime, autoRotateExpirationTime, confirm, globalOptions
        }
    }
}
