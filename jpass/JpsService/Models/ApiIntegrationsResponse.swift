//
//  ApiIngreationsResponse.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 1/9/25.
//

struct ApiIntegrationsResponse: Codable {
    let totalCount: Int
    let results: [ApiIntegrationsEntry]
}

struct ApiIntegrationsEntry: Codable {
    let displayName: String
    let clientId: String
}
