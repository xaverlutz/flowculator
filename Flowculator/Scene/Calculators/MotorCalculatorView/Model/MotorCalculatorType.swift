//
//  MotorCalculatorType.swift
//  Flowculator
//
//  Created by Xaver Lutz on 06.02.26.
//  Copyright © 2026 Xaver. All rights reserved.
//

import Foundation

// MARK: - Calculation Types

enum CalculationType: Int, CaseIterable {
    case displacement = 0
    case flowRate = 1
    case rotationSpeed = 2
    case outputTorque = 3
    case performanceI = 4
    case performanceII = 5
    case torque = 6

    /// Title of the calculation type.
    var title: String {
        switch self {
        case .displacement: return String(localized: .displacement)
        case .flowRate: return String(localized: .flowRate)
        case .rotationSpeed: return String(localized: .rotationSpeed)
        case .outputTorque: return String(localized: .outputTorque)
        case .performanceI: return String(localized: .performanceOne)
        case .performanceII: return String(localized: .performanceTwo)
        case .torque: return String(localized: .torque)
        }
    }
}

// MARK: - Input Configuration

struct InputConfiguration {

    /// Placeholder of the first textfield.
    let firstPlaceholder: String

    /// Placeholder of the second textfield.
    let secondPlaceholder: String

    /// Placeholder of the optional third textfield
    let thirdPlaceholder: String?

    /// Unit of the first textfiled.
    let firstUnit: String

    /// Unit of the second textfiled
    let secondUnit: String

    /// Unit of the optional third textfiled
    let thirdUnit: String?

    /// Unit of the calculation result
    let resultUnit: String

    /// Determines whether a third input is needed.
    let isThirdInputRequired: Bool
}

// MARK: - Validation Result

enum InputValidationResult {
    case valid
    case emptyFields
    case invalidNumbers

    var errorMessage: ValidationError? {
        switch self {
        case .emptyFields:
            return ValidationError(errorDescription: .errorEmptyFieldsTitle, failureReason: .errorEmptyFieldsMessage)
        case .invalidNumbers:
            return ValidationError(errorDescription: .errorInvalidNumbersTitle, failureReason: .errorCorrectInput)
        case .valid:
            return nil
        }
    }
}
