//
//  MotorCalculatorViewModel.swift
//  Flowculator
//
//  Created by Xaver on 06.02.26.
//  Copyright © 2026 Xaver. All rights reserved.
//

import Foundation

// MARK: - Types

protocol MotorCalculatorViewModelType {
    var inputs: MotorCalculatorViewModelInputType { get }
    var outputs: MotorCalculatorViewModelOutputType { get }
}

protocol MotorCalculatorViewModelInputType {
    func selectCalculationType(_ type: CalculationType)
    func calculate(input1: String?, input2: String?, input3: String?)
}

protocol MotorCalculatorViewModelOutputType: AnyObject {
    var onCalculationTypeChanged: ((CalculationType) -> Void)? { get set }
    var onConfigurationChanged: ((InputConfiguration) -> Void)? { get set }
    var onCalculationResult: ((String) -> Void)? { get set }
    var onValidationError: ((LocalizedError) -> Void)? { get set }
}

// MARK: - Implementation

class MotorCalculatorViewModel: MotorCalculatorViewModelType, MotorCalculatorViewModelInputType, MotorCalculatorViewModelOutputType {

    // MARK: - Properties

    private let numberFormatter = NumberFormatter()
    private(set) var currentCalculationType: CalculationType = .displacement

    // MARK: - Outputs

    var onCalculationTypeChanged: ((CalculationType) -> Void)?
    var onConfigurationChanged: ((InputConfiguration) -> Void)?
    var onCalculationResult: ((String) -> Void)?
    var onValidationError: ((LocalizedError) -> Void)?

    // MARK: - Initialization

    init() {
        numberFormatter.locale = Locale.current
    }

    // MARK: - Inputs

    func selectCalculationType(_ type: CalculationType) {
        currentCalculationType = type
        onCalculationTypeChanged?(type)
        onConfigurationChanged?(getConfiguration(for: type))
    }

    func calculate(input1: String?, input2: String?, input3: String?) {
        // Validate inputs
        let validation = validateInputs(
            input1: input1,
            input2: input2,
            input3: input3,
            requiresThirdInput: currentCalculationType.requiresThirdInput
        )

        guard validation == .valid else {
            if let error = validation.errorMessage {
                onValidationError?(error)
            }
            return
        }

        // Parse inputs
        guard let value1 = parseDouble(from: input1 ?? ""),
              let value2 = parseDouble(from: input2 ?? "") else {
            return
        }

        var value3: Double?
        if currentCalculationType.requiresThirdInput {
            value3 = parseDouble(from: input3 ?? "")
        }

        // Perform calculation
        let result = performCalculation(
            for: currentCalculationType,
            input1: value1,
            input2: value2,
            input3: value3
        )

        // Format and return result
        let formattedResult = String(format: "%.2f", result)
        onCalculationResult?(formattedResult)
    }

    // MARK: - Private Methods

    private func validateInputs(input1: String?, input2: String?, input3: String?, requiresThirdInput: Bool) -> InputValidationResult {
        // Check for empty fields
        guard let input1 = input1, !input1.isEmpty,
              let input2 = input2, !input2.isEmpty else {
            return .emptyFields
        }

        if requiresThirdInput {
            guard let input3 = input3, !input3.isEmpty else {
                return .emptyFields
            }

            // Check if all inputs are numeric
            if !isNumeric(input1) || !isNumeric(input2) || !isNumeric(input3) {
                return .invalidNumbers
            }
        } else {
            // Check if inputs are numeric
            if !isNumeric(input1) || !isNumeric(input2) {
                return .invalidNumbers
            }
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

    private func getConfiguration(for type: CalculationType) -> InputConfiguration {
        switch type {
        case .displacement:
            return InputConfiguration(
                firstPlaceholder: String(localized: .flowRate),
                secondPlaceholder: String(localized: .rotationSpeed),
                thirdPlaceholder: nil,
                firstUnit: "l/min",
                secondUnit: "RPM",
                thirdUnit: nil,
                resultUnit: "cm³/rev",
                isThirdInputRequired: false
            )

        case .flowRate:
            return InputConfiguration(
                firstPlaceholder: String(localized: .displacement),
                secondPlaceholder: String(localized: .rotationSpeed),
                thirdPlaceholder: nil,
                firstUnit: "cm³/rev",
                secondUnit: "RPM",
                thirdUnit: nil,
                resultUnit: "l/min",
                isThirdInputRequired: false
            )

        case .rotationSpeed:
            return InputConfiguration(
                firstPlaceholder: String(localized: .displacement),
                secondPlaceholder: String(localized: .flowRate),
                thirdPlaceholder: nil,
                firstUnit: "cm³/rev",
                secondUnit: "l/min",
                thirdUnit: nil,
                resultUnit: "RPM",
                isThirdInputRequired: false
            )

        case .outputTorque:
            return InputConfiguration(
                firstPlaceholder: String(localized: .pressure),
                secondPlaceholder: String(localized: .displacement),
                thirdPlaceholder: String(localized: .efficiency),
                firstUnit: "bar",
                secondUnit: "cm³/rev",
                thirdUnit: "",
                resultUnit: "daNm",
                isThirdInputRequired: true
            )

        case .performanceI:
            return InputConfiguration(
                firstPlaceholder: String(localized: .torque),
                secondPlaceholder: String(localized: .rotationSpeed),
                thirdPlaceholder: String(localized: .efficiency),
                firstUnit: "daNm",
                secondUnit: "RPM",
                thirdUnit: "",
                resultUnit: "kW",
                isThirdInputRequired: true
            )

        case .performanceII:
            return InputConfiguration(
                firstPlaceholder: String(localized: .pressure),
                secondPlaceholder: String(localized: .flowRate),
                thirdPlaceholder: String(localized: .efficiency),
                firstUnit: "bar",
                secondUnit: "l/min",
                thirdUnit: "",
                resultUnit: "kW",
                isThirdInputRequired: true
            )

        case .torque:
            return InputConfiguration(
                firstPlaceholder: String(localized: .performance),
                secondPlaceholder: String(localized: .rotationSpeed),
                thirdPlaceholder: String(localized: .efficiency),
                firstUnit: "kW",
                secondUnit: "RPM",
                thirdUnit: "",
                resultUnit: "daNm",
                isThirdInputRequired: true
            )
        }
    }

    private func performCalculation( // swiftlint:disable:this cyclomatic_complexity
        for type: CalculationType,
        input1: Double,
        input2: Double,
        input3: Double?
    ) -> Double {
        switch type {
        case .displacement:
            // Displacement = Flow Rate / Rotation Speed * 1000
            return input1 / input2 * 1000.0

        case .flowRate:
            // Flow Rate = Displacement * Rotation Speed / 1000
            return input1 * input2 / 1000.0

        case .rotationSpeed:
            // Rotation Speed = Flow Rate / Displacement * 1000
            return input2 / input1 * 1000.0

        case .outputTorque:
            // Output Torque = (Pressure * Displacement * Efficiency) / 62.83 / 10
            guard let efficiency = input3 else { return 0 }
            let intermediate = (input1 * input2 * efficiency) / 62.83
            return intermediate / 10.0

        case .performanceI:
            // Performance I = Torque * Rotation Speed / 954.9 * Efficiency
            guard let efficiency = input3 else { return 0 }
            return input1 * input2 / 954.9 * efficiency

        case .performanceII:
            // Performance II = Flow Rate * Pressure / 612 * Efficiency
            guard let efficiency = input3 else { return 0 }
            return input2 * input1 / 612.0 * efficiency

        case .torque:
            // Torque = Performance * 954.9 * Efficiency / Rotation Speed
            guard let efficiency = input3 else { return 0 }
            return input1 * 954.9 * efficiency / input2
        }
    }

    #if DEBUG
    deinit {
        print("🔴 Deinit: \(#file):\(#line)")
    }
    #endif

    // MARK: - ViewModel Type

    var inputs: MotorCalculatorViewModelInputType { return self }
    var outputs: MotorCalculatorViewModelOutputType { return self }
}

// MARK: - CalculationType Extension

extension CalculationType {
    var requiresThirdInput: Bool {
        switch self {
        case .displacement, .flowRate, .rotationSpeed:
            return false
        case .outputTorque, .performanceI, .performanceII, .torque:
            return true
        }
    }
}
