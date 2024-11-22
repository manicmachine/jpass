//
//  Set.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 10/25/24.
//
import ArgumentParser

extension JPass {
    struct Set: AsyncParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Sets the local admin password for the specified user on a given host.", aliases: ["s"])

        @OptionGroup
        var globalOptions: GlobalOptions

        @Option(name: .shortAndLong, help: "The password to be set.")
        var password: String
        
        mutating func run() async {
            print("Set the local admin password!")
        }
    }
}
