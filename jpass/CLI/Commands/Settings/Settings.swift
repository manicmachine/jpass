//
//  Settings.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 12/20/24.
//

import ArgumentParser
import Foundation
import TextTable

extension JPass {
    struct Settings: AsyncParsableCommand {
        static let configuration = CommandConfiguration(abstract: "View and modify global JPS local admin settings.", subcommands: [SettingsGet.self, SettingsModify.self])
    }
}
