//
//  ComputerInventoryResponse.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/21/24.
//

import Foundation

struct ComputerInventoryResponse: Codable {
    let totalCount: Int
    let results: [ComputerInventoryEntry]
}

struct ComputerInventoryEntry: Codable {
    let id: String
    let udid: String
    let general: ComputerInventoryGeneral
    let hardware: ComputerInventoryHardware
}

struct ComputerInventoryGeneral: Codable {
    let name: String
    let managementId: String
    let assetTag: String?
}

struct ComputerInventoryHardware: Codable {
    let serialNumber: String
}
