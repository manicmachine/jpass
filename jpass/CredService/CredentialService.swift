//
//  CredService.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/4/24.
//
import Foundation

class CredentialService {
    private let username: String
    private let server: String
    private let port: String
    private var skipCache: Bool
    private var password: String?
    var passwordFromCache: Bool = false
    
  
    init(for username: String, on server: String, using port: String, skipCache: Bool) {
        self.username = username
        self.server = server
        self.port = port
        self.skipCache = skipCache
    }
    
    func getPassword() -> String {
       if !skipCache {
            ConsoleLogger.shared.debug("Checking for cached credentials for \(self.username)@\(server):\(port).")

            // Check if cached password is present
           let keychainAcl = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, .userPresence, nil)
           
            var item: CFTypeRef?
            let searchQuery: [String: Any] = [
                kSecClass as String: kSecClassInternetPassword,
                kSecAttrAccessControl as String: keychainAcl!,
                kSecAttrAccount as String: username,
                kSecAttrServer as String: server,
                kSecAttrPort as String: port,
                kSecUseDataProtectionKeychain as String: false,
                kSecReturnAttributes as String: true,
                kSecReturnData as String: true
            ]

            let status = SecItemCopyMatching(searchQuery as CFDictionary, &item)
            if status == errSecSuccess {
                // Credentials located
                if let keychainValues = item as? [String: Any], let passwordData = keychainValues[kSecValueData as String] as? Data {
                    ConsoleLogger.shared.debug("Cached credentials located.")
                    passwordFromCache = true
                    password = String(data: passwordData, encoding: .utf8)
                } else {
                    ConsoleLogger.shared.error("Unexpected value returned from keychain.")
                }
            } else if status == errSecItemNotFound {
                ConsoleLogger.shared.debug("No cached credentials located in keychain.")
            } else {
                let statusMessage = SecCopyErrorMessageString(status, nil)!
                ConsoleLogger.shared.debug("Error encountered while attempting to retrieve cached credentials: \(statusMessage)")
            }
        } else {
            ConsoleLogger.shared.debug("Skip cache enabled, skipping keychain lookup.")
        }
        if password == nil {
            if let pw = CredentialService.promptForPassword(with: "\(username)'s password: ") {
                password = pw
            }
        }

        guard let password = password, !password.isEmpty else {
            ConsoleLogger.shared.error("No password provided. Exiting.")
            exit(1)
        }
        
        return password
    }
    
    func cacheCredentials() throws {
        if passwordFromCache {
            // Current password is from cache so nothing needs to be done here.
            return
        } else if skipCache {
            ConsoleLogger.shared.debug("Skip cache enabled, credentials not stored.")
            return
        }

        ConsoleLogger.shared.debug("Caching credentials in local keychain.")

        do {
            guard let password = password else {
                throw JPassError.InvalidState(error: "Attempted to cache password when none is set.")
            }

            var error: Unmanaged<CFError>?
            guard let keychainAcl = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, .userPresence, &error) else {
                throw JPassError.Error(error: "Failed to create keychain ACL: \(error?.takeUnretainedValue().localizedDescription ?? "Unknown error")")
            }
            
            // Check if keychain item already exists
            let baseQuery: [String: Any] = [
                kSecClass as String: kSecClassInternetPassword,
                kSecAttrAccessControl as String: keychainAcl,
                kSecAttrLabel as String: "JPass: \(server):\(port)",
                kSecAttrAccount as String: username,
                kSecAttrServer as String: server,
                kSecAttrPort as String: port,
                kSecUseDataProtectionKeychain as String: false
            ]

            let searchQuery: [String: Any] = baseQuery.merging([kSecReturnAttributes as String: false, kSecReturnData as String: false]) { (_, new) in new }
            var status = SecItemCopyMatching(searchQuery as CFDictionary, nil)
            
            if status == errSecItemNotFound {
                // No item exists, so let's insert one
                let keychainItem: [String: Any] = baseQuery.merging([kSecValueData as String: password.data(using: String.Encoding.utf8)!]) { (_, new) in new }
                
                status = SecItemAdd(keychainItem as CFDictionary, nil)
            } else if status == errSecSuccess {
                // Item found, so let's update it
                let attributes: [String: Any] = [kSecValueData as String: password.data(using: String.Encoding.utf8)!]

                status = SecItemUpdate(baseQuery as CFDictionary, attributes as CFDictionary)
            }
            
            if status != errSecSuccess {
                let statusMessage = SecCopyErrorMessageString(status, nil)!
                ConsoleLogger.shared.error("Failed to store password in keychain: \(statusMessage)")
                throw JPassError.Error(error: "Failed to store password in keychain: \(statusMessage)")
            }
            
            ConsoleLogger.shared.debug("Credentials successfully cached.")
        } catch {
            ConsoleLogger.shared.error("An error has occured while storing cached password for \(self.username): \(error).")
        }
    }
    
    func deleteCredentials() {
        // Reset class variables
        password = nil
        passwordFromCache = false
        
        // Delete credentials from local keychain
        password = nil
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: username,
            kSecAttrServer as String: server,
            kSecAttrPort as String: port,
            kSecUseDataProtectionKeychain as String: false
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            let statusMessage = SecCopyErrorMessageString(status, nil)!
            ConsoleLogger.shared.error("An error has occured while deleting cached credentials: \(statusMessage). You may need to delete them manually via Keychain Access.")
        } else {
            ConsoleLogger.shared.debug("Cached credentials deleted successfully.")
        }
    }
    
    static func promptForPassword(with message: String, hideInput: Bool = true) -> String? {
        var password: String? = nil
        if hideInput {
            if let pw = getpass(message) {
                password = String(cString: pw)
            }
        } else {
            print(message, terminator: "")
            password = readLine()
        }

        return password
    }
}
