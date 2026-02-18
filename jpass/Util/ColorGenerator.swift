//
//  ColorGenerator.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 2/13/26.
//

import Rainbow

struct ColorGenerator {
    /// Colors an entire string to match the styling of a given character.
    static func colorifyString(_ str: String, matching char: Character) -> String {
        guard str.first != nil else { return str }
        
        let color = getColor(for: char)
        let backgroundColor = getBackgroundColor(for: char)
        
        return str.applyingColor(color).applyingBackgroundColor(backgroundColor)
    }
    
    /// Colors each individual character within a given string to it's assigned styling.
    static func colorifyCharacters(in str: String) -> String {
        var output = String()

        for char in str {
            output += ColorGenerator.colorify(char)
        }
        
        return output
    }
    
    /// Applies the styling for a given character.
    static func colorify(_ char: Character) -> String {
        let textColor = ColorGenerator.getColor(for: char)
        let backgroundColor = ColorGenerator.getBackgroundColor(for: char)
        
        return String(char).applyingColor(textColor).applyingBackgroundColor(backgroundColor)
    }
    
    /// Returns the color assigned for a given character.
    static func getColor(for char: Character) -> NamedColor {
        return if char.isNumber {
            NamedColor.cyan
        } else if char.isSymbol || char.isPunctuation {
            NamedColor.lightRed
        } else if char.isWhitespace {
            NamedColor.lightYellow
        } else {
            NamedColor.default
        }
    }
    
    /// Returns the background coloor assigned for a given character.
    static func getBackgroundColor(for char: Character) -> NamedBackgroundColor {
        return if char.isNumber || char.isSymbol || char.isPunctuation || char.isWhitespace {
            NamedBackgroundColor.black
        } else {
            NamedBackgroundColor.default
        }
    }
}
