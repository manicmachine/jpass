////
////  JpsService.swift
////  jpass
////
////  Created by Oliphant, Corey Dean on 10/31/24.
////
import OSLog

class JpsService {
    static let jpsPageSizeKey = "JPASS_PAGE_SIZE"
    static let defaultPageSize = 25
    static let schemePattern = try! Regex(#"^.*://"#)
    static let baseUrlPattern = try! Regex(#"^(?:https?:\/\/)?([^\/:]+)"#)
    static let portPattern = try! Regex(#"([^\/:]+)[0-9]{1,5}$"#)

    private let serverUrl: String
    private var jpsToken: AuthToken?
    
    private var pageSize: Int {
        if let envVar = Int(ProcessInfo.processInfo.environment[JpsService.jpsPageSizeKey] ?? "") {
            return envVar
        } else {
            return JpsService.defaultPageSize
        }
    }
    
    var baseUrl: String {
        return String(try! JpsService.baseUrlPattern.firstMatch(in: self.serverUrl)![1].value as! Substring)
    }
    
    var port: String {
        return String(try! JpsService.portPattern.firstMatch(in: self.serverUrl)![0].value as! Substring)
    }
    
    init(url: String) throws {
        do {
            self.serverUrl = try JpsService.parseJpsUrl(url)
        } catch {
            throw JPassError.Error(error: "Failed to initialize JPS Service: \(error)")
        }
    }
    
    static private func parseJpsUrl(_ url: String) throws -> String {
        var mutableUrl = url

        guard let _ = URL(string: url) else {
            throw JpsError.InvalidURL
        }
        
        // Make sure we're using HTTPS
        if let match = try schemePattern.firstMatch(in: mutableUrl) {
            if match.0 != "https://" {
                ConsoleLogger.shared.debug("Insecure or unsupported scheme provided, \(match.0). Converting scheme to HTTPS.")
                mutableUrl = mutableUrl.replacingOccurrences(of: match.0, with: "https://")
            }
        } else {
            ConsoleLogger.shared.debug("No scheme detected in provided URL, utilizing HTTPS scheme.")
            mutableUrl = "https://\(mutableUrl)"
        }
        
        // Add port if necessary
        if try portPattern.firstMatch(in: mutableUrl) == nil {
            let port = url.contains("jamfcloud") ? "443" : "8443"
            
            ConsoleLogger.shared.debug("No port specified in provided URL, adding default port \(port).")
            mutableUrl = "\(mutableUrl):\(port)"
        }
        
        return mutableUrl
    }
    
    private func makeJpsCall(to url: URL, with method: URLRequest.Method, headers: [String: String]? = nil, body: Encodable? = nil) async throws -> (Data, HTTPURLResponse) {
        
        var reqHeaders = Dictionary<String, String>()
        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue.uppercased()
        
        if let body = body {
            req.httpBody = try JSONEncoder().encode(body)
        }
        
        // Set provided headers
        if let headers {
            reqHeaders.merge(headers) { (_, new) in new }
        }
        
        // Set key headers if they're not already set
        if reqHeaders["Accept"] == nil {
            reqHeaders["Accept"] = "application/json"
        }
        
        if let _ = body, reqHeaders["Content-Type"] == nil {
            reqHeaders["Content-Type"] = "application/json"
        }
        
        if reqHeaders["Authorization"] == nil, let token = jpsToken?.token {
            reqHeaders["Authorization"] = "Bearer \(token)"
        } else if reqHeaders["Authorization"] == nil && jpsToken == nil {
            ConsoleLogger.shared.error("No authorization header set by caller and no auth token available.")
            
            throw JpsError.InvalidCredentials
        }
        
        req.allHTTPHeaderFields = reqHeaders
        let sendableReq = req // Swift concurrency requires variables captured by async tasks to be constants.
        let (data, response) = try await URLSession.shared.data(for: sendableReq)
        
        return (data, (response as! HTTPURLResponse))
    }
    
    func authenticate(username: String, password: String) async throws {
        func getBasicAuthString(username: String, password: String) -> String? {
            return "\(username):\(password)".data(using: .utf8)?.base64EncodedString()
        }

        ConsoleLogger.shared.debug("Authenticating to \(self.serverUrl).")

        guard let url = URL(string: JpsEndpoint.authenticate.build(baseUrl: self.serverUrl)) else {
            throw JpsError.InvalidURL
        }

        guard let authString = getBasicAuthString(username: username, password: password) else {
            throw JpsError.InvalidCredentials
        }

        let (data, response) = try await makeJpsCall(to: url, with: .post, headers: ["Authorization": "Basic \(authString)"])
        
        if !response.isSuccess {
            throw JpsError.mapResponseCodeToError(for: response.statusCode)
        }
        
        ConsoleLogger.shared.debug("Authentication successful.")

        self.jpsToken = try JSONDecoder().decode(AuthToken.self, from: data)
    }
    
    func getPendingRotations() async throws -> PendingResponse {
        ConsoleLogger.shared.debug("Retrieving pending rotations.")
        
        guard let url = URL(string: JpsEndpoint.localAdminPendingRotations.build(baseUrl: self.serverUrl)) else {
            throw JpsError.InvalidURL
        }
        
        let (data, response) = try await makeJpsCall(to: url, with: .get)
        
        if !response.isSuccess {
            throw JpsError.mapResponseCodeToError(for: response.statusCode)
        }
        
        let decoder = JSONDecoder.Iso8601()
        return try decoder.decode(PendingResponse.self, from: data)
    }
    
    func getComputersByManagementId(_ managementIds: [String]) async throws -> [String: String] {
        return try await withThrowingTaskGroup(of: [String: String].self, returning: [String : String].self) { taskGroup in
            var results: [String: String] = [:]
            managementIds.chunked(into: self.pageSize).forEach { ids in
                let rsql = "&filter=general.managementId=in=(\(ids.joined(separator: ",")))"
                guard let url = URL(string: JpsEndpoint.computerInventory.build(baseUrl: self.serverUrl)  + rsql) else {
                    return
                }
                
                taskGroup.addTask {
                    let (data, response) = try await self.makeJpsCall(to: url, with: .get)
                    
                    if !response.isSuccess {
                        throw JpsError.mapResponseCodeToError(for: response.statusCode)
                    }
                    
                    let computerResponse = try JSONDecoder().decode(ComputerInventoryResponse.self, from: data)
                    return Dictionary(uniqueKeysWithValues: computerResponse.results.map {
                        ($0.general.managementId, $0.general.name)
                    })
                }
            }
            
            while let mapping = try await taskGroup.next() {
                results.merge(mapping) { (_, new) in new }
            }

            return results
        }
    }
    
    func getComputersByIdentifier(_ identifier: JpsIdentifier) async throws -> [String: ComputerInventoryEntry] {
        var rsql = "&filter="
        
        switch identifier.type {
            case .uuid:
                rsql += "general.managementId==\"\(identifier.value)\""
            case .int:
                rsql += "id==\"\(identifier.value)\","
                fallthrough
            case .string:
                rsql += "general.name==\"\(identifier.value)\",general.assetTag==\"\(identifier.value)\",general.barcode1==\"\(identifier.value)\",general.barcode2==\"\(identifier.value)\",hardware.serialNumber==\"\(identifier.value)\""
        }
        
        guard let url = URL(string: JpsEndpoint.computerInventory.build(baseUrl: self.serverUrl)  + rsql) else {
            return [:]
        }
        
        let (data, response) = try await self.makeJpsCall(to: url, with: .get)
        
        if !response.isSuccess {
            throw JpsError.mapResponseCodeToError(for: response.statusCode)
        }
        
        let computerResponse = try JSONDecoder().decode(ComputerInventoryResponse.self, from: data)
        return Dictionary(uniqueKeysWithValues: computerResponse.results.map { ($0.general.managementId, $0) })
    }
    
    func getPasswordFor(computer managementId: String, user: String, guid: String? = nil) async throws -> String? {
        var params = ["managementId": managementId, "username": user]
        if let guid { params["guid"] = guid }
        
        guard let url = URL(string: guid != nil ? JpsEndpoint.localAdminGetGuid.build(baseUrl: self.serverUrl, params: params) : JpsEndpoint.localAdminGet.build(baseUrl: self.serverUrl, params: params)) else {
            throw JPassError.InvalidState(error: "Failed to initialize GET password URL")
        }

        let (data, response) = try await self.makeJpsCall(to: url, with: .get)
        
        if !response.isSuccess {
            throw JpsError.mapResponseCodeToError(for: response.statusCode)
        }
        
        let passwordResponse = try JSONDecoder().decode(PasswordResponse.self, from: data)
        return passwordResponse.password
    }
    
    func getHistoryFor(computer managementId: String) async throws -> [HistoryEntry] {
        guard let url = URL(string: JpsEndpoint.localAdminHistory.build(baseUrl: self.serverUrl, params: ["managementId": managementId])) else {
            throw JPassError.InvalidState(error: "Failed to initialize GET history URL")
        }
        
        let (data, response) = try await self.makeJpsCall(to: url, with: .get)
        
        if !response.isSuccess {
            throw JpsError.mapResponseCodeToError(for: response.statusCode)
        }
        
        let decoder = JSONDecoder.Iso8601()
        return try decoder.decode(HistoryResponse.self, from: data).results
    }
    
    func getAccountsFor(computer managementId: String) async throws -> [AccountsEntry] {
        guard let url = URL(string: JpsEndpoint.localAdminAccounts.build(baseUrl: self.serverUrl, params: ["managementId": managementId])) else {
            throw JPassError.InvalidState(error: "Failed to initialize GET accounts URL")
        }
        
        let (data, response) = try await self.makeJpsCall(to: url, with: .get)
        
        if !response.isSuccess {
            throw JpsError.mapResponseCodeToError(for: response.statusCode)
        }
        
        let accountsResponse = try JSONDecoder().decode(AccountsResponse.self, from: data)
        return accountsResponse.results
    }
    
    func getAuditFor(computer managementId: String, user: String, guid: String?) async throws -> [PasswordAuditEntry] {
        var params = ["managementId": managementId, "username": user]
        if let guid = guid { params["guid"] = guid }
        
        guard let url = URL(string: guid != nil ? JpsEndpoint.localAdminAuditGuid.build(baseUrl: self.serverUrl, params: params) : JpsEndpoint.localAdminAudit.build(baseUrl: self.serverUrl, params: params)) else {
            throw JPassError.InvalidState(error: "Failed to initialize GET audit URL")
        }
        
        let (data, response) = try await self.makeJpsCall(to: url, with: .get)
        
        if !response.isSuccess {
            throw JpsError.mapResponseCodeToError(for: response.statusCode)
        }
        
        let decoder = JSONDecoder.Iso8601()
        return try decoder.decode(AuditResponse.self, from: data).results
    }
    
    func setPasswordFor(computer managementId: String, user: String, password: String) async throws {
        guard let url = URL(string: JpsEndpoint.localAdminSet.build(baseUrl: self.serverUrl, params: ["managementId": managementId])) else {
            throw JPassError.InvalidState(error: "Failed to initialize SET password URL")
        }
        
        let body = PasswordRequest(username: user, password: password)
        let (_, response) = try await makeJpsCall(to: url, with: .put, body: body)
        
        if !response.isSuccess {
            throw JpsError.mapResponseCodeToError(for: response.statusCode)
        }
    }
    
    func getLocalAdminPasswordSettings() async throws -> GetSettingsResponse {
        guard let url = URL(string: JpsEndpoint.localAdminSettings.build(baseUrl: self.serverUrl)) else {
            throw JPassError.InvalidState(error: "Failed to initialize GET local admin password settings URL")
        }
        
        let (data, response) = try await self.makeJpsCall(to: url, with: .get)
        
        if !response.isSuccess {
            throw JpsError.mapResponseCodeToError(for: response.statusCode)
        }
        
        return try JSONDecoder().decode(GetSettingsResponse.self, from: data)
    }
    
    func setLocalAdminPasswordSettings(with settings: ModifySettingsRequest) async throws {
        guard let url = URL(string: JpsEndpoint.localAdminSettings.build(baseUrl: self.serverUrl)) else {
            throw JPassError.InvalidState(error: "Failed to initialize SET local admin password settings URL")
        }
        
        let (_, response) = try await makeJpsCall(to: url, with: .put, body: settings)
        
        if !response.isSuccess {
            throw JpsError.mapResponseCodeToError(for: response.statusCode)
        }
    }
    
    func getApiIntegrations() async throws -> [ApiIntegrationsEntry] {
        guard let url = URL(string: JpsEndpoint.apiIntegrations.build(baseUrl: self.serverUrl)) else {
            throw JPassError.InvalidState(error: "Failed to initialize GET api integrations URL")
        }
        
        var page = 0
        var retrievedResults: [ApiIntegrationsEntry] = []
        
        while true {
            let pagedUrl = url.appending(queryItems: [URLQueryItem(name: "page", value: String(page)), URLQueryItem(name: "page-size", value: String(self.pageSize))])
            let (data, response) = try await makeJpsCall(to: pagedUrl, with: .get)
            
            if !response.isSuccess {
                throw JpsError.mapResponseCodeToError(for: response.statusCode)
            }
            
            let decodedData = try JSONDecoder().decode(ApiIntegrationsResponse.self, from: data)
            retrievedResults.append(contentsOf: decodedData.results)
            
            if retrievedResults.count >= decodedData.totalCount {
                break
            } else {
                page += 1
            }
        }
        
        return retrievedResults
    }
}
