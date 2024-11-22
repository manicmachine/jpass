//
//  History.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 10/25/24.
//
import ArgumentParser

extension JPass {
    struct History: AsyncParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Retrieves the full history of all local admin passwords for a given host. Includes date created, date last seen, expiration time, and rotational status.", aliases: ["his", "h"])
        
        @OptionGroup
        var globalOptions: GlobalOptions
        
        @OptionGroup
        var options: GuidOptions
        
        mutating func run() async {
            print("Check the local admim password history!")
        }
    }
}
