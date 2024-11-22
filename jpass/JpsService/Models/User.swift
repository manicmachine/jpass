//
//  User.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/12/24.
//

struct User: Codable {
    let clientManagementId: String
    let guid: String
    let username: String
    let userSource: String
    
    // Populated when user passes --map-computers
    var computerName: String?
}
