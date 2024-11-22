//
//  AuthToken.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 10/31/24.
//

import Foundation

struct AuthToken: Codable {
    let token: String
    let expires: Date
    let issueTime: Date = Date()
    
    init(from decoder: Decoder) throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        token = try values.decode(String.self, forKey: .token)
        expires = dateFormatter.date(from: try values.decode(String.self, forKey: .expires))!
    }
    
    var isExpired: Bool { return self.expires.timeIntervalSince1970 < Date().timeIntervalSince1970 }
}
