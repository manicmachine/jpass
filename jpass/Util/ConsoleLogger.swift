//
//  Logger+Extensions.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/11/24.
//
import Foundation

class ConsoleLogger {
    static let shared = ConsoleLogger()
    
    func info(_ message: String, terminator: String = "\n") {
        print(message, terminator: terminator)
    }
    
    func verbose(_ message: String) {
        if GlobalSettings.shared.verbose {
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
