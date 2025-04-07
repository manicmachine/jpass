//
//  IdentifierOptions.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 4/7/25.
//

import ArgumentParser

protocol IdentifierOption: ParsableArguments {
    var identifiers: [JpsIdentifier] { get }
}
