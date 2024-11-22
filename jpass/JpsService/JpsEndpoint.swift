//
//  JpsEndpoint.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 10/31/24.
//

enum JpsEndpoint: String {
    // Authentication
    case authenticate = "/api/v1/auth/token"
    case revokeToken = "/api/v1/auth/invalidate-token"
    
    // Computers
    case computerInventory = "/api/v1/computers-inventory?section=GENERAL&section=HARDWARE"
    
    // Local admin password management
    case localAdminPendingRotations = "/api/v2/local-admin-password/pending-rotations"
    case localAdminAudit = "/api/v2/local-admin-password/{managementId}/account/{username}/audit"
    case localAdminAuditGuid = "/api/v2/local-admin-password/{managementId}/account/{username}/{guid}/audit"
    case localAdminHistory = "/api/v2/local-admin-password/{managementId}/account/{username}/history"
    case localAdminHistoryGuid = "/api/v2/local-admin-password/{managementId}/account/{username}/{guid}/history"
    case localAdminGet = "/api/v2/local-admin-password/{managementId}/account/{username}/password"
    case localAdminGetGuid = "/api/v2/local-admin-password/{managementId}/account/{username}/{guid}/password"
    case localAdminSet = "/api/v2/local-admin-password/{managementId}/set-password"
    

    func build(baseUrl: String, params: [String: String]? = nil) -> String {
        var url = baseUrl + self.rawValue
        
        if let params {
            params.forEach { param in
                url = url.replacingOccurrences(of: "{\(param.key)}", with: param.value)
            }
        }
        
        return url
    }
}
