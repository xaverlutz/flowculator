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
    let pistonDiameter: Double      // Kolben Ø (mm)
    let rodDiameter: Double          // Kolbenstange Ø (mm)
    let pressure: Double             // Arbeitsdruck (bar)
    let stroke: Double               // Hub (mm)
    let flowRate: Double             // Ölstrom (l/min)
}

// MARK: - Calculation Results

struct CylinderResults {
    // Areas (Fläche) in cm²
    let pistonArea: Double           // Kolbenseite
    let rodSideArea: Double          // Stangenseite
    let differentialArea: Double     // Differential

    // Stroke volumes (Hubvolumen) in liters
    let pistonVolume: Double         // Kolbenseite
    let rodSideVolume: Double        // Stangenseite
    let differentialVolume: Double   // Differential

    // Forces (Kraft) in kN
    let pistonForce: Double          // Kolbenseite
    let rodSideForce: Double         // Stangenseite
    let differentialForce: Double    // Differential

    // Stroke times (Hubzeit) in seconds
    let pistonTime: Double           // Kolbenseite
    let rodSideTime: Double          // Stangenseite

    // Stroke speeds (Hubgeschwindigkeit) in m/s
    let pistonSpeed: Double          // Kolbenseite
    let rodSideSpeed: Double         // Stangenseite

    // Maximum power (Maximale Leistung) in kW
    let maxPower: Double             // Kolbenseite

    // Area ratio (Flächenverhältnis)
    let areaRatio: Double            // Kolbenseite/Stangenseite
}

// MARK: - Validation Result

enum CylinderValidationResult {
    case valid
    case emptyFields
    case invalidNumbers
    case rodLargerThanPiston

    var errorMessage: (title: String, message: String)? {
        switch self {
        case .emptyFields:
            return (String(localized: "error.empty.fields.title"), String(localized: "error.empty.fields.message"))
        case .invalidNumbers:
            return (String(localized: "error.invalid.numbers.title"), String(localized: "error.correct.input"))
        case .rodLargerThanPiston:
            return (String(localized: "error.piston.smaller.title"), String(localized: "error.correct.input"))
        case .valid:
            return nil
        }
    }
}
