//
//  GetSettingsResponse.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 12/20/24.
//

struct GetSettingsResponse: Codable {
    let autoDeployEnabled: Bool
    let passwordRotationTime: Int
    let autoRotateEnabled: Bool
    let autoRotateExpirationTime: Int
}
