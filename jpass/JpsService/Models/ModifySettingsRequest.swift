//
//  ModifySettingsRequest.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 12/23/24.
//

struct ModifySettingsRequest: Codable {
    let autoDeployEnabled: Bool?
    let autoRotateEnabled: Bool?
    let passwordRotationTime: Int?
    let autoRotateExpirationTime: Int?
}
