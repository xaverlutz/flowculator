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
        case .displacement: return String(localized: "displacement")
        case .flowRate: return String(localized: "flow.rate")
        case .rotationSpeed: return String(localized: "rotation.speed")
        case .outputTorque: return String(localized: "output.torque")
        case .performanceI: return String(localized: "performance.one")
        case .performanceII: return String(localized: "performance.two")
        case .torque: return String(localized: "torque")
        }
    }
}

// MARK: - Input Configuration

struct InputConfiguration {

    /// Placeholder of the first textfield.
    let placeholder1: String

    /// Placeholder of the second textfield.
    let placeholder2: String

    /// Placeholder of the optional third textfield
    let placeholder3: String?

    /// Unit of the first textfiled.
    let unit1: String

    /// Unit of the second textfiled
    let unit2: String

    /// Unit of the optional third textfiled
    let unit3: String?

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

    var errorMessage: (title: String, message: String)? {
        switch self {
        case .emptyFields:
            return (String(localized: "error.empty.fields.title"), String(localized: "error.empty.fields.message"))
        case .invalidNumbers:
            return (String(localized: "error.invalid.numbers.title"), String(localized: "error.correct.input"))
        case .valid:
            return nil
        }
    }
}
