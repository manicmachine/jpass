//
//  Logger+Extensions.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/11/24.
//
import Foundation

class ConsoleLogger {
    static let shared = ConsoleLogger()
    static var verbose = false
    
    func info(_ message: String) {
        print(message)
    }
    
    func debug(_ message: String) {
        if ConsoleLogger.verbose {
            print(message)
        }
    }
    
    func error(_ message: String) {
        do {
            try FileHandle.standardError.write(contentsOf: "\(message)\n".data(using: .utf8)!)
        } catch {
            print("Error writing to standard error: \(error)")
            exit(1)
        }
    }
}
