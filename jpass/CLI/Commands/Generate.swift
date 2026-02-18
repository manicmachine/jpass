//
//  Generate.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 2/3/26.
//

import ArgumentParser

extension JPass {
    struct Generate: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Generate a random 14 to 29 character 3-word phrase in the format <adverb>-<verb>-<noun>.",
            aliases: ["gen", "e"]
        )
        
        @Flag(name: .shortAndLong, help: "Copy phrase into your clipboard instead of printing to STDOUT.")
        var copy = false
        
        func run() {
            let phrase = PassPhraseGenerator.generatePhrase()
            
            if copy {
                Pasteboard.copy(phrase)
                ConsoleLogger.shared.info("Phrase copied to clipboard.")
            } else {
                ConsoleLogger.shared.print(phrase)
            }
        }
    }
}
