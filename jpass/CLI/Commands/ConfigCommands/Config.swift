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
    struct Config: AsyncParsableCommand {
        static let configuration = CommandConfiguration(abstract: "View and modify the global JPS local admin configuration.", subcommands: [ConfigGet.self, ConfigModify.self], aliases: ["con", "c"])
    }
}
