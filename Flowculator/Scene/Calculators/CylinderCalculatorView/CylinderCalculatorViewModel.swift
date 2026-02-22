//
//  CylinderCalculatorViewModel.swift
//  Flowculator
//
//  Created by Xaver on 06.02.26.
//  Copyright © 2026 Xaver. All rights reserved.
//

import Foundation

// MARK: - Types

protocol CylinderCalculatorViewModelType {
    var inputs: CylinderCalculatorViewModelInputType { get }
    var outputs: CylinderCalculatorViewModelOutputType { get }
}

protocol CylinderCalculatorViewModelInputType {
    func calculate(
        pistonDiameter: String?,
        rodDiameter: String?,
        pressure: String?,
        stroke: String?,
        flowRate: String?
    )
}

protocol CylinderCalculatorViewModelOutputType: AnyObject {
    var onCalculationResult: ((CylinderResults) -> Void)? { get set }
    var onValidationError: ((String, String) -> Void)? { get set }
}

// MARK: - Implementation

class CylinderCalculatorViewModel: CylinderCalculatorViewModelType,
                                   CylinderCalculatorViewModelInputType,
                                   CylinderCalculatorViewModelOutputType {

    // MARK: - Properties

    private let numberFormatter = NumberFormatter()

    // MARK: - Outputs

    var onCalculationResult: ((CylinderResults) -> Void)?
    var onValidationError: ((String, String) -> Void)?

    // MARK: - Initialization

    init() {
        numberFormatter.locale = Locale.current
    }

    // MARK: - Inputs

    func calculate(
        pistonDiameter: String?,
        rodDiameter: String?,
        pressure: String?,
        stroke: String?,
        flowRate: String?
    ) {
        // Validate inputs
        let validation = validateInputs(
            pistonDiameter: pistonDiameter,
            rodDiameter: rodDiameter,
            pressure: pressure,
            stroke: stroke,
            flowRate: flowRate
        )

        guard validation == .valid else {
            if let error = validation.errorMessage {
                onValidationError?(error.title, error.message)
            }
            return
        }

        // Parse inputs
        guard let pistonDiameter = parseDouble(from: pistonDiameter ?? ""),
              let rodDiameter = parseDouble(from: rodDiameter ?? ""),
              let pressure = parseDouble(from: pressure ?? ""),
              let stroke = parseDouble(from: stroke ?? ""),
              let flowRate = parseDouble(from: flowRate ?? "") else {
            return
        }

        // Additional validation: piston must be larger than rod
        guard pistonDiameter > rodDiameter else {
            onValidationError?("Piston is smaller than Pistonrod", "Please correct your Input.")
            return
        }

        let inputs = CylinderInputs(
            pistonDiameter: pistonDiameter,
            rodDiameter: rodDiameter,
            pressure: pressure,
            stroke: stroke,
            flowRate: flowRate
        )

        // Perform calculations
        let results = performCalculations(inputs: inputs)

        // Return results
        onCalculationResult?(results)
    }

    // MARK: - Private Methods

    private func validateInputs(
        pistonDiameter: String?,
        rodDiameter: String?,
        pressure: String?,
        stroke: String?,
        flowRate: String?
    ) -> CylinderValidationResult {
        // Check for empty fields
        guard let piston = pistonDiameter, !piston.isEmpty,
              let rod = rodDiameter, !rod.isEmpty,
              let press = pressure, !press.isEmpty,
              let str = stroke, !str.isEmpty,
              let flow = flowRate, !flow.isEmpty else {
            return .emptyFields
        }

        // Check if inputs are numeric
        if !isNumeric(piston) || !isNumeric(rod) || !isNumeric(press) ||
           !isNumeric(str) || !isNumeric(flow) {
            return .invalidNumbers
        }

        return .valid
    }

    private func isNumeric(_ text: String) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789,.-")
        let textCharacterSet = CharacterSet(charactersIn: text)
        return allowedCharacters.isSuperset(of: textCharacterSet)
    }

    private func parseDouble(from text: String) -> Double? {
        if text.contains(",") {
            return numberFormatter.number(from: text)?.doubleValue
        } else {
            return Double(text)
        }
    }

    private func performCalculations(inputs: CylinderInputs) -> CylinderResults {
        let pistonDiameter = inputs.pistonDiameter
        let rodDiameter = inputs.rodDiameter
        let pressure = inputs.pressure
        let stroke = inputs.stroke
        let flowRate = inputs.flowRate

        // Area calculations (cm²)
        let pistonArea = pistonDiameter * pistonDiameter * Double.pi / 400.0
        let differentialArea = rodDiameter * rodDiameter * Double.pi / 400.0
        let rodSideArea = pistonArea - differentialArea

        // Stroke volume calculations (liters)
        let pistonVolume = pistonArea * stroke / 10000.0
        let rodSideVolume = rodSideArea * stroke / 10000.0
        let differentialVolume = pistonVolume - rodSideVolume

        // Force calculations (kN)
        let pistonForce = pressure * pistonDiameter * pistonDiameter * 0.785 / 10000.0
        let rodSideForce = pressure * ((pistonDiameter * pistonDiameter) - (rodDiameter * rodDiameter)) * 0.785 / 10000.0
        let differentialForce = pistonForce - rodSideForce

        // Stroke time calculations (seconds)
        let pistonTime = pistonArea * stroke * 6.0 / (flowRate * 1000.0)
        let rodSideTime = rodSideArea * stroke * 6.0 / (flowRate * 1000.0)

        // Stroke speed calculations (m/s)
        let pistonSpeed = stroke / (pistonTime * 1000.0)
        let rodSideSpeed = stroke / (rodSideTime * 1000.0)

        // Maximum power calculation (kW)
        let maxPower = pistonForce * (pistonSpeed * 1000.0) / 1000.0

        // Area ratio calculation
        let areaRatio = pistonArea / rodSideArea

        return CylinderResults(
            pistonArea: pistonArea,
            rodSideArea: rodSideArea,
            differentialArea: differentialArea,
            pistonVolume: pistonVolume,
            rodSideVolume: rodSideVolume,
            differentialVolume: differentialVolume,
            pistonForce: pistonForce,
            rodSideForce: rodSideForce,
            differentialForce: differentialForce,
            pistonTime: pistonTime,
            rodSideTime: rodSideTime,
            pistonSpeed: pistonSpeed,
            rodSideSpeed: rodSideSpeed,
            maxPower: maxPower,
            areaRatio: areaRatio
        )
    }

    #if DEBUG
    deinit {
        print("🔴 Deinit: \(#file):\(#line)")
    }
    #endif

    // MARK: - ViewModel Type

    var inputs: CylinderCalculatorViewModelInputType { return self }
    var outputs: CylinderCalculatorViewModelOutputType { return self }
}
