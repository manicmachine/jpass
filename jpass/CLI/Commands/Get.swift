//
//  Get.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 10/25/24.
//
import ArgumentParser

extension JPass {
    struct Get: AsyncParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Retrieves the local admin password for a given host.", aliases: ["g"])
        
        @OptionGroup
        var globalOptions: GlobalOptions
        
        @OptionGroup
        var options: GuidOptions
        
        mutating func run() async {
            print("Get the local admin password!")
        }
    }
}
