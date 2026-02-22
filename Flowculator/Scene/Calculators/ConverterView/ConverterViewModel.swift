//
//  ConverterViewModel.swift
//  Flowculator
//
//  Created by Xaver on 06.02.26.
//  Copyright © 2026 Xaver. All rights reserved.
//

import Foundation

// MARK: - Types

protocol ConverterViewModelType {
    var inputs: ConverterViewModelInputType { get }
    var outputs: ConverterViewModelOutputType { get }
}

protocol ConverterViewModelInputType {
    /// Performs a conversion by resolving the appropriate unit category from a UI segment tag.
    ///
    /// This is the main entry point called by the view. It validates the input, determines which
    /// unit enum the tag belongs to, and delegates to the corresponding conversion method.
    ///
    /// - Parameters:
    ///   - tag: The raw integer tag from the UI control, mapped to one of the unit enums.
    ///   - value: The user-entered input string.
    func convert(tag: Int, value: String)
}

/// Conforms to AnyObject. That tells the compiler it's a reference type,
/// so mutations through a get-only property work fine.
protocol ConverterViewModelOutputType: AnyObject {
    var onConversionResult: ((Int, ConversionResult) -> Void)? { get set }
    var onValidationError: ((LocalizedError) -> Void)? { get set }
}

// MARK: - Implementation

/// ViewModel responsible for validating user input and performing unit conversions
/// across pressure, temperature, power, length, volume, and liquid volume categories.
class ConverterViewModel: ConverterViewModelType, ConverterViewModelInputType, ConverterViewModelOutputType {

    // MARK: - Properties

    private let numberFormatter = NumberFormatter()

    // MARK: - Outputs

    var onConversionResult: ((Int, ConversionResult) -> Void)?
    var onValidationError: ((LocalizedError) -> Void)?

    // MARK: - Initialization

    init() {
        numberFormatter.locale = Locale.current
    }

    // MARK: - Inputs

    func convert(tag: Int, value: String) {
        let validation = validateInput(value)

        guard validation.isValid else {
            if let error = validation.error {
                onValidationError?(error)
            }
            return
        }

        guard validation == .valid else {
            return
        }

        var result: ConversionResult?

        // Pressure conversions
        if let pressureUnit = PressureUnit(rawValue: tag) {
            result = convertPressure(from: pressureUnit, value: value)
        }

        // Temperature conversions
        if result == nil, let tempUnit = TemperatureUnit(rawValue: tag) {
            result = convertTemperature(from: tempUnit, value: value)
        }

        // Power conversions
        if result == nil, let powerUnit = PowerUnit(rawValue: tag) {
            result = convertPower(from: powerUnit, value: value)
        }

        // Length conversions
        if result == nil, let lengthUnit = LengthUnit(rawValue: tag) {
            result = convertLength(from: lengthUnit, value: value)
        }

        // Volume conversions
        if result == nil, let volumeUnit = VolumeUnit(rawValue: tag) {
            result = convertVolume(from: volumeUnit, value: value)
        }

        // Liquid volume conversions
        if result == nil, let liquidVolumeUnit = LiquidVolumeUnit(rawValue: tag) {
            result = convertLiquidVolume(from: liquidVolumeUnit, value: value)
        }

        if let result = result {
            onConversionResult?(tag, result)
        }
    }

    // MARK: - Private Methods

    /// Validates a raw input string for use in a conversion.
    ///
    /// - Parameter text: The user-entered text to validate.
    ///
    /// - Returns: A ``ConverterValidationResult`` indicating whether the input is usable.
    private func validateInput(_ text: String) -> ConverterValidationResult {
        guard !text.isEmpty else {
            return .empty
        }

        // Minus is a valid input at the first place.
        if text == "-" { return .valid }

        if parseDouble(from: text) != nil {
            return .valid
        } else {
            return .invalidCharacters
        }
    }

    /// Parses a `Double` from a user-entered string, handling locale-specific comma decimal separators.
    ///
    /// - Parameter text: The text to parse.
    ///
    /// - Returns: The parsed value, or `nil` if parsing fails.
    private func parseDouble(from text: String) -> Double? {
        if text.contains(",") {
            return numberFormatter.number(from: text)?.doubleValue
        } else {
            return Double(text)
        }
    }

    /// Converts a pressure value from the given unit to the other two ``PressureUnit``.
    ///
    /// - Parameters:
    ///    - unit: The power unit to convert from.
    ///    - value: Value of the unit to convert.
    ///
    /// - Returns: A conversion Result if the value can be parsed to double.
    func convertPressure(from unit: PressureUnit, value: String) -> ConversionResult? {
        guard let doubleValue = parseDouble(from: value) else { return nil }

        switch unit {
        case .bar:
            let mpa = doubleValue / 10.0
            let psi = mpa * 145.038
            return ConversionResult(firstConvertion: mpa, secondConvertion: psi)

        case .mpa:
            let bar = doubleValue * 10.0
            let psi = doubleValue * 145.038
            return ConversionResult(firstConvertion: bar, secondConvertion: psi)

        case .psi:
            let mpa = doubleValue / 145.038
            let bar = mpa * 10.0
            return ConversionResult(firstConvertion: mpa, secondConvertion: bar)
        }
    }

    /// Converts a temperature value from the given unit to the other two ``TemperatureUnit``.
    ///
    /// - Parameters:
    ///    - unit: The power unit to convert from.
    ///    - value: Value of the unit to convert.
    ///
    /// - Returns: A conversion Result if the value can be parsed to double.
    func convertTemperature(from unit: TemperatureUnit, value: String) -> ConversionResult? {
        guard let doubleValue = parseDouble(from: value) else { return nil }

        switch unit {
        case .celsius:
            let fahrenheit = doubleValue * 9 / 5 + 32
            let kelvin = doubleValue + 273.15
            return ConversionResult(firstConvertion: fahrenheit, secondConvertion: kelvin)

        case .fahrenheit:
            let celsius = 5.0 / 9.0 * (doubleValue - 32)
            let kelvin = celsius + 273.15
            return ConversionResult(firstConvertion: celsius, secondConvertion: kelvin)

        case .kelvin:
            let celsius = doubleValue - 273.15
            let fahrenheit = celsius * 9 / 5 + 32
            return ConversionResult(firstConvertion: celsius, secondConvertion: fahrenheit)
        }
    }

    /// Converts a power value from the given unit to the other two ``PowerUnit``.
    ///
    /// - Parameters:
    ///    - unit: The power unit to convert from.
    ///    - value: Value of the unit to convert.
    ///
    /// - Returns: A conversion Result if the value can be parsed to double.
    func convertPower(from unit: PowerUnit, value: String) -> ConversionResult? {
        guard let doubleValue = parseDouble(from: value) else { return nil }

        switch unit {
        case .kilowatt:
            let kcalh = doubleValue * 1000.0 / 1.163
            let horsePower = doubleValue * 1000.0 / 735.49875
            return ConversionResult(firstConvertion: kcalh, secondConvertion: horsePower)

        case .kilocaloriePerHour:
            let killowatt = doubleValue * 1.163 / 1000.0
            let horsePower = killowatt * 1000.0 / 735.49875
            return ConversionResult(firstConvertion: killowatt, secondConvertion: horsePower)

        case .horsepower:
            let killowatt = doubleValue * 735.49875 / 1000.0
            let kcalh = killowatt * 1000.0 / 1.163
            return ConversionResult(firstConvertion: killowatt, secondConvertion: kcalh)
        }
    }

    /// Converts a length value from the given unit to the other two ``LengthUnit``.
    ///
    /// - Parameters:
    ///    - unit: The unit to convert from.
    ///    - value: Value of the unit to convert.
    ///
    /// - Returns: A conversion Result if the value can be parsed to double.
    func convertLength(from unit: LengthUnit, value: String) -> ConversionResult? {
        guard let doubleValue = parseDouble(from: value) else { return nil }

        switch unit {
        case .millimeter:
            let inch = 1.0 / 2.54 * doubleValue / 10.0
            let feet = inch / 12.0
            return ConversionResult(firstConvertion: inch, secondConvertion: feet)

        case .inch:
            let millimeter = doubleValue * 2.54 * 10.0
            let feet = doubleValue / 12.0
            return ConversionResult(firstConvertion: millimeter, secondConvertion: feet)

        case .feet:
            let inch = doubleValue * 12.0
            let millimeter = inch * 2.54 * 10.0
            return ConversionResult(firstConvertion: inch, secondConvertion: millimeter)
        }
    }

    /// Converts a volume value from the given unit to the other two ``VolumeUnit``.
    ///
    /// - Parameters:
    ///    - unit: The unit to convert from.
    ///    - value: Value of the unit to convert.
    ///
    /// - Returns: A conversion Result if the value can be parsed to double.
    func convertVolume(from unit: VolumeUnit, value: String) -> ConversionResult? {
        guard let doubleValue = parseDouble(from: value) else { return nil }

        switch unit {
        case .cubicCentimeter:
            let feet3 = doubleValue / 28316.846609230495
            let inch3 = doubleValue / 16.38706399858543
            return ConversionResult(firstConvertion: feet3, secondConvertion: inch3)

        case .cubicFeet:
            let inch3 = doubleValue * 1728
            let cm3 = doubleValue * 28316.846609230495
            return ConversionResult(firstConvertion: inch3, secondConvertion: cm3)

        case .cubicInch:
            let feet3 = doubleValue / 1728
            let cm3 = doubleValue * 16.38706399858543
            return ConversionResult(firstConvertion: feet3, secondConvertion: cm3)
        }
    }

    /// Converts a liquid volume value from the given unit to the other two ``LiquidVolumeUnit``.
    ///
    /// - Parameters:
    ///    - unit: The unit to convert from.
    ///    - value: Value of the unit to convert.
    ///
    /// - Returns: A conversion Result if the value can be parsed to double.
    func convertLiquidVolume(from unit: LiquidVolumeUnit, value: String) -> ConversionResult? {
        guard let doubleValue = parseDouble(from: value) else { return nil }

        switch unit {
        case .liter:
            let usGal = doubleValue / 3.7854117891320316
            let impGal = doubleValue / 4.546089999981147
            return ConversionResult(firstConvertion: usGal, secondConvertion: impGal)

        case .usGallon:
            let liter = doubleValue * 3.7854117891320316
            let impGal = doubleValue * 0.8326741857613311
            return ConversionResult(firstConvertion: liter, secondConvertion: impGal)

        case .imperialGallon:
            let liter = doubleValue * 4.546089999981147
            let usGal = doubleValue / 0.8326741857613311
            return ConversionResult(firstConvertion: liter, secondConvertion: usGal)
        }
    }

    #if DEBUG
    deinit {
        print("🔴 Deinit: \(#file):\(#line)")
    }
    #endif

    // MARK: - ViewModel Type

    var inputs: ConverterViewModelInputType { return self }
    var outputs: ConverterViewModelOutputType { return self }
}
