//
//  PasswordRequest.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 12/5/24.
//

struct PasswordRequest: Codable {
    let lapsUserPasswordList: [PasswordListItem]
    
    init(username: String, password: String) {
        lapsUserPasswordList = [PasswordListItem(username: username, password: password)]
    }
}

struct PasswordListItem: Codable {
    let username: String
    let password: String
}
