//
//  IdentifierOptions.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 11/22/24.
//

import ArgumentParser

struct IdentifierOptions: ParsableCommand {
    @Argument(help: "One of the following identifiers: Jamf id, computer name, management id, asset tag, bar code, or serial number.")
    var identifier: JpsIdentifier
}
