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
        if UUID(uuidString: value) != nil {
            .uuid
        } else if Int(value) != nil {
            .int
        } else {
            .string
        }
    }
    
    init?(argument: String) {
        self.value = argument
    }
}
