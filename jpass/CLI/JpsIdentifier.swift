//
//  Identifier.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 10/25/24.
//
import ArgumentParser
import Foundation

struct JpsIdentifier: ExpressibleByArgument {
    enum IdType {
        case string, int, uuid
    }
    
    let value: String
    var type: IdType {
        if let _ = UUID(uuidString: value) {
            .uuid
        } else if let _ = Int(value) {
            .int
        } else {
            .string
        }
    }
    
    init?(argument: String) {
        self.value = argument
    }
}
