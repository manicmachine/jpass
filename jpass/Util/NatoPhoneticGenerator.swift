//
//  NatoPhonetic.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 1/9/25.
//

struct NatoPhoneticGenerator {
    static func generateCodePhrase(for str: String) -> String {
        var phrase = ""

        for char in str {
            phrase += "\(char): \(getCodeWord(for: char))\n"
        }
        
        return phrase
    }
    
    static private func getCodeWord(for c: Character) -> String {
        let str = String(c)
        var result = ""
        
        if c.isLetter {
            result = c.isLowercase ? "Lower " : "Upper "
        }
        
        switch c.lowercased() {
            case "a": result += "Alpha"
            case "b": result += "Bravo"
            case "c": result += "Charlie"
            case "d": result += "Delta"
            case "e": result += "Echo"
            case "f": result += "Foxtrot"
            case "g": result += "Golf"
            case "h": result += "Hotel"
            case "i": result += "India"
            case "j": result += "Juliett"
            case "k": result += "Kilo"
            case "l": result += "Lima"
            case "m": result += "Mike"
            case "n": result += "November"
            case "o": result += "Oscar"
            case "p": result += "Papa"
            case "q": result += "Quebec"
            case "r": result += "Romeo"
            case "s": result += "Sierra"
            case "t": result += "Tango"
            case "u": result += "Uniform"
            case "v": result += "Victor"
            case "w": result += "Whiskey"
            case "x": result += "X-ray"
            case "y": result += "Yankee"
            case "z": result += "Zulu"
            default:
                if let _ = Int(str) {
                    switch c {
                        case "0":
                            return "Zero"
                        case "1":
                            return "One"
                        case "2":
                            return "Two"
                        case "3":
                            return "Three"
                        case "4":
                            return "Four"
                        case "5":
                            return "Five"
                        case "6":
                            return "Six"
                        case "7":
                            return "Seven"
                        case "8":
                            return "Eight"
                        case "9":
                            return "Nine"
                        default:
                            return str
                    }
                } else {
                    switch c {
                        case "-":
                            return "Dash"
                        case ".":
                            return "Period"
                        case ",":
                            return "Comma"
                        case "/":
                            return "Forward-Slash"
                        case "\\":
                            return "Back-Slash"
                        case "*":
                            return "Asterisk"
                        case "?":
                            return "Question-Mark"
                        case "!":
                            return "Exclamation-Mark"
                        case "@":
                            return "At-Symbol"
                        case "~":
                            return "Tilde"
                        case "#":
                            return "Hashtag"
                        case "$":
                            return "Dollar-Sign"
                        case "%":
                            return "Percent"
                        case "^":
                            return "Caret"
                        case "&":
                            return "Ampersand"
                        case "(":
                            return "Left-Parenthesis"
                        case ")":
                            return "Right-Parenthesis"
                        case "{":
                            return "Left-Brace"
                        case "}":
                            return "Right-Brace"
                        case "[":
                            return "Left-Bracket"
                        case "]":
                            return "Right-Bracket"
                        case "+":
                            return "Plus"
                        case "_":
                            return "Underscore"
                        case "<":
                            return "Less-Than"
                        case ">":
                            return "Greater-Than"
                        case "=":
                            return "Equal"
                        case ":":
                            return "Colon"
                        case ";":
                            return "Semi-Colon"
                        case "|":
                            return "Vertical-Bar"
                        case "\"":
                            return "Quotation-Mark"
                        case "'":
                            return "Apostrophe"
                        case "`":
                            return "Grave-Accent"
                        default:
                            return str
                    }
                }
        }
        
        return result
    }
}
