//
//  HTTPURLResponse+IsSuccess.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/7/24.
//
import Foundation

extension HTTPURLResponse {
    var isSuccess: Bool {
        return self.statusCode < 300 && self.statusCode >= 200
    }
}
