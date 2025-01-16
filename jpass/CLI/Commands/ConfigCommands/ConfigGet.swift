//
//  Get.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 12/20/24.
//

import ArgumentParser
import TextTable

extension JPass.Config {
    struct ConfigGet: AsyncParsableCommand, JpsAuthenticating {
        static let configuration = CommandConfiguration(commandName: "get", abstract: "Retrieves the current global local admin password configuration.", aliases: ["g"])
        
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
            
            let settingsResponse: GetSettingsResponse
            do {
                settingsResponse = try await jpsService.getLocalAdminPasswordSettings()
            } catch {
                ConsoleLogger.shared.error("An error occurred while attempting to retrieve the local admin password settings: \(error)")
                JPass.exit(withError: ExitCode(1))
            }
            
            Self.printSettings(settingsResponse)
        }
        
        static func printSettings(_ settings: GetSettingsResponse) {
            let table = TextTable<GetSettingsResponse> {
                [Column(title: "Auto Deploy Enabled", value: $0.autoDeployEnabled),
                 Column(title: "Auto Rotate Enabled", value: $0.autoRotateEnabled),
                 Column(title: "Password Rotation Time", value: Self.formatSecondsString(seconds: $0.passwordRotationTime)),
                 Column(title: "Auto Rotate Expiration Time", value: Self.formatSecondsString(seconds: $0.autoRotateExpirationTime))
                ]
            }
            
            table.print([settings], style: Style.psql)
        }
        
        static func formatSecondsString(seconds: Int) -> String {
            let dSeconds = Double(seconds)
            let secondsPerMin = 60.0
            let secondsPerHour = 3600.0
            let secondsPerDay = 86400.0
            
            let str = "\(seconds)s"
            var additionalStr: String?
            
            if dSeconds > secondsPerDay {
                let dayStr = String(format: "%.2f", dSeconds/secondsPerDay)
                additionalStr = " (\(dayStr) days)"
            } else if dSeconds > secondsPerHour {
                let hourStr = String(format: "%.2f", dSeconds/secondsPerHour)
                additionalStr = " (\(hourStr) hours)"
            } else if dSeconds > secondsPerMin {
                let minStr = String(format: "%.2f", dSeconds/secondsPerMin)
                additionalStr = " (\(minStr) minutes)"
            }
            
            if let additionalStr = additionalStr {
                return str + additionalStr
            } else {
                return str
            }
        }
        
        private enum CodingKeys: CodingKey {
            case globalOptions
        }
    }
}
