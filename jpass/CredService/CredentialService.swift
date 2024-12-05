//
//  CredService.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/4/24.
//
import Foundation
import Valet

class CredentialService {
    private let keychain: SecureEnclaveValet
    private let username: String
    private var password: String?
    private var skipCache: Bool
  
    init(for username: String, skipCache: Bool) {
        self.username = username
        self.skipCache = skipCache

        keychain = SecureEnclaveValet.valet(with: Identifier(nonEmpty: "edu.uwec.jpass")!, accessControl: .userPresence)
    }
    
    func getPassword() -> String {
        var password: String? = nil

        if !skipCache {
            ConsoleLogger.shared.info("Checking for cached password for \(self.username).")

            do {
                password = try keychain.string(forKey: username, withPrompt: "Checking for cached password!")
            } catch KeychainError.itemNotFound {
                ConsoleLogger.shared.info("No cached password found.")
            } catch KeychainError.userCancelled {
                ConsoleLogger.shared.info("User dismissed keychain unlock prompt.")
            } catch {
                ConsoleLogger.shared.error("An error has occured while retrieving cached password: \(error).")
            }
        } else {
            flushCreds()
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
    
    // TODO: Cache credentials on a per user per server basis to support users who manage multiple JPS'
    func setPassword(_ password: String) {
        guard !skipCache else { return }

        do {
            try keychain.setString(password, forKey: username)
        } catch {
            ConsoleLogger.shared.error("An error has occured while storing cached password for \(self.username): \(error).")
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

    private func flushCreds() {
        do {
            try keychain.removeAllObjects()
        } catch {
            ConsoleLogger.shared.error("An error has occured while clearing the keychain: \(error).")
        }
    }
    
//    private func keychainIsPresent() -> Bool {
//        do {
//            let userExists = try keychain.containsObject(forKey: JPass.userKey)
//            
//            if userExists {
//                return true
//            } else {
//                return false
//            }
//        } catch {
//            logger.error("An error has occured while checking if keychain is present: \(error)")
//            
//            return false
//        }
//    }
}
