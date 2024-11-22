//
//  BaseOptionsAdmin.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/7/24.
//
import ArgumentParser
import Foundation

struct LocalAdminOptions: ParsableArguments {
    static let localAdminKey = "JPASS_LOCAL_ADMIN"
    
    @Option(name: .shortAndLong, help: "Username of the local admin account. Can be set using the environment variable \(LocalAdminOptions.localAdminKey).")
    var localAdmin: String?
    
    mutating func validate() throws {
        if localAdmin == nil {
            if let envVar = ProcessInfo.processInfo.environment[LocalAdminOptions.localAdminKey] {
                localAdmin = envVar
            } else {
                throw ValidationError.init("Local admin username must be provided.")
            }
        }
    }
}
