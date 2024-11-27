//
//  AccountsResponse.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/27/24.
//

struct AccountsResponse: Codable {
    let totalCount: Int
    let results: [AccountsEntry]
}

struct AccountsEntry: Codable, CustomStringConvertible {
    let clientManagementId: String
    let guid: String
    let username: String
    let userSource: String
    
    var description: String {
        return "Username: \(username) | User Source: \(userSource) | GUID: \(guid) | Management ID: \(clientManagementId)"
    }
}
