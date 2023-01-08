//
//  Permissions Manager Extensions.swift
//  
//
//  Created by Roberto D’Angelo on 04/01/23.
//

import Foundation

internal extension String {
    func localized() -> String {
        NSLocalizedString(self, bundle: Bundle.module, comment: "")
    }
}
