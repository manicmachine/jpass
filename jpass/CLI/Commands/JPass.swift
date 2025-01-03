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
        subcommands: [Accounts.self, Audit.self, Get.self, History.self, Pending.self, Rotate.self, Set.self, Settings.self],
        defaultSubcommand: Get.self
    )
}
