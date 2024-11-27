//
//  PendingEntry.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/12/24.
//

import Foundation

struct PendingResponse: Codable {
    let totalCount: Int
    var results: [PendingEntry]
}

struct PendingEntry: Codable, CustomStringConvertible {
    var user: User
    let createdDate: Date
    
    private enum CodingKeys: String, CodingKey {
        case user = "lapsUser"
        case createdDate
    }
    
    var description: String {
        return "Date: \(createdDate.description) | Computer: \(user.computerName == nil ? user.clientManagementId : user.computerName!) | User: \(user.username) | GUID: \(user.guid) | Source: \(user.userSource)"
    }
}
