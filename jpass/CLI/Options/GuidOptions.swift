//
//  BaseOptionsGuid.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 10/25/24.
//
import ArgumentParser
import Foundation

struct GuidOptions: ParsableArguments {
    @OptionGroup
    private var localAdminOptions: LocalAdminOptions
    
    var localAdmin: String? {
        return localAdminOptions.localAdmin
    }
    
    @Option(name: .shortAndLong, help: "GUID of the local admin account. Requires local admin to be provided.")
    var guid: String?
    
    mutating func validate() throws {
        if let guid = guid, UUID(uuidString: guid) == nil {
            throw ValidationError("Invalid 'guid' value provided, must be a valid UUID.")
        }
        
        if let _ = guid, localAdmin == nil {
            throw ValidationError("The 'guid' option requires 'user' to be provided.")
        }
    }
}
