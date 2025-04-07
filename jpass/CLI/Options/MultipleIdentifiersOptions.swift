//
//  MultipleIdentifiersOptions.swift
//  jpass
//
//  Created by Oliphant, Corey Dean on 4/7/25.
//

import ArgumentParser

struct MultipleIdentifiersOptions: IdentifierOption {
    @Argument(help: "One or more of the following identifiers: Jamf id, computer name, management id, asset tag, bar code, or serial number.")
    var identifiers: [JpsIdentifier]
}
