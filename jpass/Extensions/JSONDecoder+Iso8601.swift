//
//  JSONDecoder+ISODateDecder.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/27/24.
//

import Foundation

extension JSONDecoder {
    static func Iso8601() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]  // Ensures handling of milliseconds

            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            guard let date = isoFormatter.date(from: dateString) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format")
            }
            return date
        }
        
        return decoder
    }
}
