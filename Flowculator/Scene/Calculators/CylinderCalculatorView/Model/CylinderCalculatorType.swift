//
//  CylinderCalculatorType.swift
//  Flowculator
//
//  Created by Xaver Lutz on 06.02.26.
//  Copyright © 2026 Xaver. All rights reserved.
//

import Foundation

// MARK: - Input Data

struct CylinderInputs {
    let pistonDiameter: Double
    let rodDiameter: Double
    let pressure: Double
    let stroke: Double
    let flowRate: Double
}

// MARK: - Calculation Results

struct CylinderResults {

    // - Areas (Fläche) in cm²

    let pistonArea: Double
    let rodSideArea: Double
    let differentialArea: Double

    // - Stroke volumes (Hubvolumen) in liters

    let pistonVolume: Double
    let rodSideVolume: Double
    let differentialVolume: Double

    // - Forces (Kraft) in kN

    let pistonForce: Double
    let rodSideForce: Double
    let differentialForce: Double

    // - Stroke times (Hubzeit) in seconds

    let pistonTime: Double
    let rodSideTime: Double

    // - Stroke speeds (Hubgeschwindigkeit) in m/s

    let pistonSpeed: Double
    let rodSideSpeed: Double

    // - Maximum power (Maximale Leistung) in kW

    let maxPower: Double

    // - Area ratio (Flächenverhältnis)

    let areaRatio: Double
}

// MARK: - Validation Result

enum CylinderValidationResult {
    case valid
    case emptyFields
    case invalidNumbers
    case rodLargerThanPiston

    var errorMessage: LocalizedError? {
        switch self {
        case .emptyFields:
            return ValidationError(errorDescription: .errorEmptyFieldsTitle, failureReason: .errorEmptyFieldsMessage)
        case .invalidNumbers:
            return ValidationError(errorDescription: .errorInvalidNumbersTitle, failureReason: .errorCorrectInput)
        case .rodLargerThanPiston:
            return ValidationError(errorDescription: .errorPistonSmallerTitle, failureReason: .errorCorrectInput)
        case .valid:
            return nil
        }
    }
}
