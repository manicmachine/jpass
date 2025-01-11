//
//  HistoryResponse.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/27/24.
//

import Foundation

struct HistoryResponse: Codable {
    let totalCount: Int
    let results: [HistoryEntry]
}

struct HistoryEntry: Codable , CustomStringConvertible {
    let username: String
    let userSource: String
    let eventType: String
    let eventTime: Date?
    var viewedBy: String?
    
    var description: String {
        return "Date: \(eventTime?.description ?? "-") | Event Type: \(eventType) | Username: \(username) | Source: \(userSource) | Viewed By: \(viewedBy ?? "-")"
    }
}
