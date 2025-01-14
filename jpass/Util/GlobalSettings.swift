//
//  GlobalSettings.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 1/13/25.
//

class GlobalSettings {
    static let shared = GlobalSettings()
    static let DATE_FORMAT: String = "yyyy-MM-dd HH:mm:ss z"
    
    var verbose = false
}
