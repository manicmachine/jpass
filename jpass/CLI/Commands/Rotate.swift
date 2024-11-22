//
//  Rotate.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 10/25/24.
//
import ArgumentParser

extension JPass {
    struct Rotate: AsyncParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Triggers a password rotation for the specified host.", aliases: ["rot", "r"])
        
        @OptionGroup
        var GlobalOptions: GlobalOptions
        
        @OptionGroup
        var options: GuidOptions
        
        mutating func run() async {
            print("Trigger password rotation!")
        }
    }
}
