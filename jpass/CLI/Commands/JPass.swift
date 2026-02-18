//
//  JPass.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 10/24/24.
//
import ArgumentParser

@main
struct JPass: AsyncParsableCommand {
    static let version = "1.1.0"
    
    static let configuration = CommandConfiguration(
        commandName: "jpass",
        abstract: "Manage local admin passwords on the Jamf Pro server",
        version: version,
        subcommands: [Accounts.self, Audit.self, Config.self, Generate.self, Get.self, History.self, Nato.self, Pending.self, Rotate.self, Set.self],
        defaultSubcommand: Get.self
    )
}
