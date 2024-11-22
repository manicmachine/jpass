//
//  JPass.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 10/24/24.
//
import ArgumentParser

// Commands
// jpass get <host> - Get the LAPS password
// jpass set <host> <password> - Set the LAPS password to provided value
// jpass rotate <host> - Retrieve the LAPS password but discard it, prompting a rotation
// jpass audit <host> - Retrieve LAPS audit trail
// jpass history <host> - Retrieve LAPS history
// jpass pending [host] - Retrieve all pending rotations, or just those for a given host


@main
struct JPass: AsyncParsableCommand {    
    static let configuration = CommandConfiguration(
        commandName: "jpass",
        abstract: "Manage local admin passwords on the Jamf Pro server",
        subcommands: [Audit.self, Get.self, History.self, Pending.self, Rotate.self, Set.self],
        defaultSubcommand: Get.self
    )
}
