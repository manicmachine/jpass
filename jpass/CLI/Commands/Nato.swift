//
//  Nato.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 2/3/26.
//

import ArgumentParser

extension JPass {
    struct Nato: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Converts a provided phrase into an easily communicated NATO phonetic format.",
            aliases: ["nat", "n"]
        )
        
        @Argument(help: "The phrase to convert.")
        var phrase: String
        
        @Flag(name: .shortAndLong, help: "Copy phrase into your clipboard instead of printing to STDOUT.")
        var copy = false
        
        @Flag(name: .long, help: "Disable color output.")
        var noColor: Bool = false
        
        var shouldColorify: Bool {
            return !noColor && !copy
        }
        
        func run() {
            let processedPhrase = shouldColorify ? ColorGenerator.colorifyCharacters(in: phrase) : phrase
            let natoPhrase = NatoPhoneticGenerator.generateCodePhrase(for: phrase, colored: shouldColorify)
            let output = "Phrase: \(processedPhrase)\n\n\(natoPhrase)"
            
            if copy {
                ConsoleLogger.shared.info("Phrase copied to clipboard.")
                Pasteboard.copy(output)
            } else {
                ConsoleLogger.shared.print(output)
            }
        }
    }
}
