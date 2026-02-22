//
//  ValidationError.swift
//  Flowculator
//
//  Created by Xaver Lutz on 22.02.26.
//

import Foundation

struct ValidationError: LocalizedError {

    // MARK: - Properties

    /// Title of the error
    let errorDescription: String?

    /// Failure reason or tip to resolve the error
    let failureReason: String?

    // MARK: - Life Cycle

    init(errorDescription: LocalizedStringResource, failureReason: LocalizedStringResource) {
        self.errorDescription = String(localized: errorDescription)
        self.failureReason = String(localized: failureReason)
    }
}
