//
//  PassPhraseWordLoader.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 12/5/24.
//
import Foundation

struct PassPhraseGenerator {
    static func generatePhrase() -> String {
        let adverb = Words.adverbs.randomElement()!
        let verb = Words.verbs.randomElement()!
        let noun = Words.nouns.randomElement()!
        
        return "\(adverb)-\(verb)-\(noun)"
    }
}
 
