//
//  OAuthToken.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 1/15/25.
//

import Foundation

struct OAuthToken: Codable {
    let accessToken: String
    let expiresIn: Int
}
