//
//  ConverterType.swift
//  Flowculator
//
//  Created by Xaver Lutz on 06.02.26.
//  Copyright © 2026 Xaver. All rights reserved.
//

import Foundation

// MARK: - Conversion Categories

/// Represents the available categories of unit conversions.
enum ConversionCategory {
    case pressure
    case temperature
    case power
    case length
    case volume
    case liquidVolume
}

// MARK: - Unit Types

/// Pressure units with raw values matching their UI segment indices.
enum PressureUnit: Int {
    case bar = 0
    case mpa = 1
    case psi = 2
}

/// Temperature units with raw values matching their UI segment indices.
enum TemperatureUnit: Int {
    case celsius = 3
    case fahrenheit = 4
    case kelvin = 5
}

/// Power units with raw values matching their UI segment indices.
enum PowerUnit: Int {
    case kilowatt = 6
    case kilocaloriePerHour = 7
    case horsepower = 8
}

/// Length units with raw values matching their UI segment indices.
enum LengthUnit: Int {
    case millimeter = 9
    case inch = 10
    case feet = 11
}

/// Volume units with raw values matching their UI segment indices.
enum VolumeUnit: Int {
    case cubicCentimeter = 12
    case cubicInch = 13
    case cubicFeet = 14
}

/// Liquid volume units with raw values matching their UI segment indices.
enum LiquidVolumeUnit: Int {
    case liter = 15
    case usGallon = 16
    case imperialGallon = 17
}

// MARK: - Validation Result

/// Represents the result of validating user input for conversion fields.
enum ValidationResult {
    case valid
    case empty
    case invalidCharacters
    case commaFirst

    /// Whether the input is acceptable (either valid or simply empty).
    var isValid: Bool {
        return self == .valid || self == .empty
    }

    /// Returns a localized error title and message for invalid states, or `nil` if valid.
    var errorMessage: (title: String, message: String)? {
        switch self {
        case .invalidCharacters:
            return (String(localized: "error.illegal.characters.title"), String(localized: "error.correct.input"))
        case .commaFirst:
            return (String(localized: "error.comma.first.title"), String(localized: "error.correct.input"))
        default:
            return nil
        }
    }
}

// MARK: - Conversion Result

/// Holds the formatted string results of a unit conversion.
struct ConversionResult {
    let firstConvertion: String
    let secondConvertion: String

    /// Creates a conversion result by formatting the given numeric values.
    ///
    /// - Parameters:
    ///   - firstConvertion: The first converted value.
    ///   - secondConvertion: The second converted value.
    ///   - format: The printf-style format string (defaults to two decimal places).
    init(firstConvertion: Double, secondConvertion: Double, format: String = "%.2f") {
        self.firstConvertion = String(format: format, firstConvertion)
        self.secondConvertion = String(format: format, secondConvertion)
    }
}
