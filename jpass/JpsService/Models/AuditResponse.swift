//
//  AuditResponse.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/27/24.
//

import Foundation

struct AuditResponse: Codable {
    let totalCount: Int
    let results: [PasswordAuditEntry]
}

struct PasswordAuditEntry: Codable {
    let password: String
    let dateLastSeen: Date?
    let expirationTime: Date?
    let audits: [AuditEntry]
}

struct AuditEntry: Codable {
    let dateSeen: Date
    let viewedBy: String
}

struct UnifiedAuditEntry: Codable, CustomStringConvertible {
    let password: String
    let dateLastSeen: Date?
    let expirationTime: Date?
    let dateSeen: Date?
    var viewedBy: String?
    
    init(passwordEntry: PasswordAuditEntry, auditEntry: AuditEntry? = nil) {
        self.password = passwordEntry.password
        self.dateLastSeen = passwordEntry.dateLastSeen
        self.expirationTime = passwordEntry.expirationTime
        
        if let entry = auditEntry {
            self.dateSeen = entry.dateSeen
            self.viewedBy = entry.viewedBy
        } else {
            self.dateSeen = nil
            self.viewedBy = nil
        }
    }
    
    var description: String {
        return "Password: \(self.password) | Expiration Time: \(self.expirationTime?.description ?? "-") | Date Seen: \(self.dateSeen?.description ?? "-") | Viewed By: \(self.viewedBy ?? "-")"
    }
}
