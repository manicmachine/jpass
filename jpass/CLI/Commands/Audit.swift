//
//  Audit.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 10/25/24.
//
import ArgumentParser

extension JPass {
    struct Audit: AsyncParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Retrieves the full history of all local admin passwords for a given host. Includes the password, who viewed it, and when it was viewed.", aliases: ["aud", "a"])
        
        @OptionGroup
        var globalOptions: GlobalOptions
        
        @OptionGroup
        var options: GuidOptions
        
        mutating func run() async {
            print("Audit the local admin password!")
        }
    }
}
