//
//  Pasteboard.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 2/3/26.
//

import AppKit

struct Pasteboard {
    static func copy(_ string: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(string, forType: .string)
    }
}
