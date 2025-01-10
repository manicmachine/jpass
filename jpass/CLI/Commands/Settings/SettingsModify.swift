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
        
        @Flag(name: .shortAndLong, help: "Automatically confirm changes.")
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
                let currentSettings = try await jpsService.getLocalAdminPasswordSettings()

                if !hasChanges(currentSettings, autoDeploy, autoRotate, passwordRotationTime, autoRotateExpirationTime) {
                    ConsoleLogger.shared.info("Provided settings are identical to current settings.")
                    ConsoleLogger.shared.info("Current Local Admin Password Settings:")
                    SettingsGet.printSettings(currentSettings)
                    
                    JPass.exit(withError: ExitCode.success)
                } else if !confirm {
                    ConsoleLogger.shared.info("The following changes will be applied:")
                    
                    if let autoDeploy {
                        if currentSettings.autoDeployEnabled != autoDeploy {
                            ConsoleLogger.shared.info("Auto Deploy Enabled: \(currentSettings.autoDeployEnabled) -> \(autoDeploy)")
                        } else {
                            ConsoleLogger.shared.info("Desired Auto Deploy setting (\(autoDeploy)) is already set.")
                        }
                    }
                    
                    if let autoRotate {
                        if currentSettings.autoRotateEnabled != autoRotate {
                            ConsoleLogger.shared.info("Auto Rotate Enabled: \(currentSettings.autoRotateEnabled) -> \(autoRotate)")
                        } else {
                            ConsoleLogger.shared.info("Desired Auto Rotate setting (\(autoRotate)) is already set.")
                        }
                    }
                    
                    if let passwordRotationTime {
                        if currentSettings.passwordRotationTime != passwordRotationTime {
                            ConsoleLogger.shared.info("Password Rotation Time: \(SettingsGet.formatSecondsString(seconds: currentSettings.passwordRotationTime)) -> \(SettingsGet.formatSecondsString(seconds: passwordRotationTime))")
                        } else {
                            ConsoleLogger.shared.info("Desired Password Rotation Time setting (\(passwordRotationTime) is already set.")
                        }
                    }
                    
                    if let autoRotateExpirationTime {
                        if currentSettings.autoRotateExpirationTime != autoRotateExpirationTime {
                            ConsoleLogger.shared.info("Auto Rotate Expiration Time: \(SettingsGet.formatSecondsString(seconds: currentSettings.autoRotateExpirationTime)) -> \(SettingsGet.formatSecondsString(seconds: autoRotateExpirationTime))")
                        } else {
                            ConsoleLogger.shared.info("Desired Auto Rotate Expiration Time setting (\(autoRotateExpirationTime) is already set.")
                        }
                    }

                    var choice = ""
                    while (choice != "y" && choice != "yes") && (choice != "n" && choice != "no") {
                        ConsoleLogger.shared.info("Confirm [y/n]: ", terminator: "")

                        if let input = readLine() {
                            choice = input.lowercased()
                        }
                        
                        if choice == "y" || choice == "yes" {
                            break
                        } else if choice == "n" || choice == "no" {
                            ConsoleLogger.shared.info("Changes cancelled.")
                            JPass.exit(withError: ExitCode.failure)
                        } else {
                            ConsoleLogger.shared.info("Please enter 'y' or 'yes' to confirm or 'n' or 'no' to cancel.")
                        }
                    }
                }
                
                let settings = ModifySettingsRequest(autoDeployEnabled: autoDeploy ?? currentSettings.autoDeployEnabled,
                                                     autoRotateEnabled: autoRotate ?? currentSettings.autoRotateEnabled,
                                                     passwordRotationTime: passwordRotationTime ?? currentSettings.passwordRotationTime,
                                                     autoRotateExpirationTime: autoRotateExpirationTime ?? currentSettings.autoRotateExpirationTime)
    
                try await jpsService.setLocalAdminPasswordSettings(with: settings)
                ConsoleLogger.shared.info("Local admin password settings successfully updated.")
            } catch {
                ConsoleLogger.shared.error("An error occurred while attempting to modify local admin password settings: \(error)")
                JPass.exit(withError: ExitCode(1))
            }
        }
        
        private func hasChanges(_ currentSettings: GetSettingsResponse,_ autoDeploy: Bool?, _ autoRotate: Bool?, _ passwordRotationTime: Int?, _ autoRotateExpirationTime: Int?) -> Bool {
            var hasChanges = false
            
            if let autoDeploy { hasChanges = hasChanges || currentSettings.autoDeployEnabled != autoDeploy }
            if let autoRotate { hasChanges = hasChanges || currentSettings.autoRotateEnabled != autoRotate }
            if let passwordRotationTime { hasChanges = hasChanges || currentSettings.passwordRotationTime != passwordRotationTime }
            if let autoRotateExpirationTime { hasChanges = hasChanges || currentSettings.autoRotateExpirationTime != autoRotateExpirationTime }
            
            return hasChanges
        }
        
        func validate() throws {
            if autoDeploy == nil && autoRotate == nil && passwordRotationTime == nil && autoRotateExpirationTime == nil {
                throw ValidationError("No changes specified. You must specify at least one change.")
            }
        }
        
        private enum CodingKeys: CodingKey {
            case autoDeploy, autoRotate, passwordRotationTime, autoRotateExpirationTime, confirm, globalOptions
        }
    }
}
