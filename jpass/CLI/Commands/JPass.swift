//
//  JPass.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 10/24/24.
//
import ArgumentParser

@main
struct JPass: AsyncParsableCommand {    
    static let configuration = CommandConfiguration(
        commandName: "jpass",
        abstract: "Manage local admin passwords on the Jamf Pro server",
        version: "1.1.0",
        subcommands: [Accounts.self, Audit.self, Config.self, Get.self, History.self, Pending.self, Rotate.self, Set.self],
        defaultSubcommand: Get.self
    )
}
