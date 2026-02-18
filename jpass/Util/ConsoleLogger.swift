//
//  Logger+Extensions.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/11/24.
//
import Foundation

class ConsoleLogger {
    static let shared = ConsoleLogger()
    
    /// Prints the message to the console.
    func print(_ message: String, terminator: String = "\n") {
        Swift.print(message, terminator: terminator)
    }
    
    /// Prints info level messages to the console.
    ///
    /// In future releases, this may also append the message to a log. However,
    /// for the time being info simply prints the message - thus the duplicate with `ConsoleLogger.print`
    func info(_ message: String, terminator: String = "\n") {
        Swift.print(message, terminator: terminator)
    }
    
    /// If the verbose logging is enabled, this will print the message to the console.
    ///
    /// In future releases, this may also append the message to a log.
    func verbose(_ message: String) {
        if GlobalSettings.shared.verbose {
            Swift.print(message)
        }
    }
    
    /// Prints message to STDERR.
    ///
    /// If a filehandle to STDERR can't be obtained, the message will be printed to STDOUT instead.
    ///
    /// In future releases, this may also append the message to a log.
    func error(_ message: String) {
        do {
            try FileHandle.standardError.write(contentsOf: Data("\(message)\n".utf8))
        } catch {
            Swift.print(error)
        }
    }
}
