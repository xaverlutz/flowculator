//
//  ConverterViewModelTests.swift
//  LoesiSwiftTests
//
//  Created by Xaver Lutz on 05.02.26.
//  Copyright © 2026 LöSi Gmbh. All rights reserved.
//

import XCTest

@testable import Flowculator

final class ConverterViewModelTests: XCTestCase {

    var sut: ConverterViewModel!

    // MARK: - Test Setup

    override func setUp() {
        super.setUp()
        sut = ConverterViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Validation Tests

    func test_convert_withEmptyString_doesNotFireCallbacks() {

        // - Arrange

        let tag = PressureUnit.bar.rawValue
        var conversionFired = false
        var validationFired = false
        sut.outputs.onConversionResult = { _, _ in conversionFired = true }
        sut.outputs.onValidationError = { _ in validationFired = true }

        // - Act

        sut.inputs.convert(tag: tag, value: "")

        // - Assert

        XCTAssertFalse(conversionFired)
        XCTAssertFalse(validationFired)
    }

    func test_convert_withMinus_doesNotFireCallbacks() {

        // - Arrange

        let tag = PressureUnit.bar.rawValue
        var conversionFired = false
        var validationFired = false
        sut.outputs.onConversionResult = { _, _ in conversionFired = true }
        sut.outputs.onValidationError = { _ in validationFired = true }

        // - Act

        sut.inputs.convert(tag: tag, value: "-")

        // - Assert

        XCTAssertFalse(conversionFired)
        XCTAssertFalse(validationFired)
    }

    func test_convert_withCommaFirst_firesValidationError() {

        // - Arrange

        let tag = PressureUnit.bar.rawValue
        var errorTitle: String?
        var errorMessage: String?
        sut.outputs.onValidationError = { error in
            errorTitle = error.errorDescription
            errorMessage = error.failureReason
        }

        // - Act

        sut.inputs.convert(tag: tag, value: ",")

        // - Assert

        XCTAssertNotNil(errorTitle)
        XCTAssertNotNil(errorMessage)
    }

    func test_convert_withInvalidCharacters_firesValidationError() {

        // - Arrange

        let tag = PressureUnit.bar.rawValue
        var errorTitle: String?
        var errorMessage: String?
        sut.outputs.onValidationError = { error in
            errorTitle = error.errorDescription
            errorMessage = error.failureReason
        }

        // - Act

        sut.inputs.convert(tag: tag, value: "123abc")

        // - Assert

        XCTAssertNotNil(errorTitle)
        XCTAssertNotNil(errorMessage)
    }

    func test_convert_withValidNumber_firesConversionResult() {

        // - Arrange

        let tag = PressureUnit.bar.rawValue
        var receivedResult: ConversionResult?
        sut.outputs.onConversionResult = { _, result in
            receivedResult = result
        }

        // - Act

        sut.inputs.convert(tag: tag, value: "123.45")

        // - Assert

        XCTAssertNotNil(receivedResult)
    }

    // MARK: - Pressure Conversion Tests

    func test_convert_pressure_fromBar_toMPaAndPsi() {

        // - Arrange

        let input = "10"

        // - Act

        let result = sut.convertPressure(from: .bar, value: input)

        // - Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.firstConvertion, "1.00") // MPa
        XCTAssertEqual(result?.secondConvertion, "145.04") // PSI
    }

    func test_convertPressure_fromMPa_toBarAndPsi() {

        // - Arrange

        let input = "1"

        // - Act

        let result = sut.convertPressure(from: .mpa, value: input)

        // - Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.firstConvertion, "10.00") // Bar
        XCTAssertEqual(result?.secondConvertion, "145.04") // PSI
    }

    func test_convert_pressure_fromPsi_toMPaAndBar() {

        // - Arrange

        let input = "145.038"

        // - Act

        let result = sut.convertPressure(from: .psi, value: input)

        // - Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.firstConvertion, "1.00") // MPa
        XCTAssertEqual(result?.secondConvertion, "10.00") // Bar
    }

    // MARK: - Temperature Conversion Tests

    func test_convert_temperature_fromCelsius_toFahrenheitAndKelvin() {

        // - Arrange

        let input = "0"

        // - Act

        let result = sut.convertTemperature(from: .celsius, value: input)

        // - Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.firstConvertion, "32.00") // Fahrenheit
        XCTAssertEqual(result?.secondConvertion, "273.15") // Kelvin
    }

    func test_convert_temperature_fromFahrenheit_toCelsiusAndKelvin() {

        // - Arrange

        let input = "32"

        // - Act

        let result = sut.convertTemperature(from: .fahrenheit, value: input)

        // - Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.firstConvertion, "0.00") // Celsius
        XCTAssertEqual(result?.secondConvertion, "273.15") // Kelvin
    }

    func test_convert_temperature_fromKelvin_toCelsiusAndFahrenheit() {

        // - Arrange

        let input = "273.15"

        // - Act

        let result = sut.convertTemperature(from: .kelvin, value: input)

        // - Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.firstConvertion, "0.00") // Celsius
        XCTAssertEqual(result?.secondConvertion, "32.00") // Fahrenheit
    }

    // MARK: - Power Conversion Tests

    func test_convert_power_FromKilowatt_ToKcalAndHP() {

        // - Arrange

        let input = "1"

        // - Act

        let result = sut.convertPower(from: .kilowatt, value: input)

        // - Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.firstConvertion, "859.85") // kcal/h
        XCTAssertEqual(result?.secondConvertion, "1.36") // HP
    }

    // MARK: - Length Conversion Tests

    func test_convert_length_fromMillimeter_toInchAndFeet() {

        // - Arrange

        let input = "25.4"

        // - Act

        let result = sut.convertLength(from: .millimeter, value: input)

        // - Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.firstConvertion, "1.00") // Inch
        XCTAssertEqual(result?.secondConvertion, "0.08") // Feet
    }

    func test_convert_length_fromInch_toMillimeterAndFeet() {

        // - Arrange

        let input = "1"

        // - Act

        let result = sut.convertLength(from: .inch, value: input)

        // - Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.firstConvertion, "25.40") // Millimeter
        XCTAssertEqual(result?.secondConvertion, "0.08") // Feet
    }

    func test_convert_length_fromFeet_toInchAndMillimeter() {

        // - Arrange

        let input = "1"

        // - Act

        let result = sut.convertLength(from: .feet, value: input)

        // - Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.firstConvertion, "12.00") // Inch
        XCTAssertEqual(result?.secondConvertion, "304.80") // Millimeter
    }

    // MARK: - Volume Conversion Tests

    func test_onvert_volume_fromCubicCentimeter_toCubicFeetAndInch() {

        // - Arrange

        let input = "1000"

        // - Act

        let result = sut.convertVolume(from: .cubicCentimeter, value: input)

        // - Assert

        XCTAssertNotNil(result)
        XCTAssertNotNil(result?.firstConvertion) // Cubic feet
        XCTAssertNotNil(result?.secondConvertion) // Cubic inch
    }

    // MARK: - Liquid Volume Conversion Tests

    func test_convert_liquidVolume_FromLiter_ToUSGalAndImperialGal() {

        // - Arrange

        let input = "3.78541"

        // - Act

        let result = sut.convertLiquidVolume(from: .liter, value: input)

        // - Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.firstConvertion, "1.00") // US Gallon
    }

    func test_convert_liquidVolume_FromUSGallon_ToLiterAndImperialGal() {

        // - Arrange

        let input = "1"

        // - Act

        let result = sut.convertLiquidVolume(from: .usGallon, value: input)

        // - Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.firstConvertion, "3.79") // Liter
        XCTAssertEqual(result?.secondConvertion, "0.83") // Imperial Gallon
    }

    // MARK: - Input/Output Convert Tests

    func test_convert_validInput_firesConversionResult() {

        // - Arrange

        let tag = PressureUnit.bar.rawValue
        var receivedTag: Int?
        var receivedResult: ConversionResult?
        sut.outputs.onConversionResult = { tag, result in
            receivedTag = tag
            receivedResult = result
        }

        // - Act

        sut.inputs.convert(tag: tag, value: "10")

        // - Assert

        XCTAssertEqual(receivedTag, tag)
        XCTAssertNotNil(receivedResult)
    }

    func test_convert_withInvalidInput_firesValidationError() {

        // - Arrange

        let tag = PressureUnit.bar.rawValue
        var receivedTitle: String?
        var receivedMessage: String?
        sut.outputs.onValidationError = { error in
            receivedTitle = error.errorDescription
            receivedMessage = error.failureReason
        }

        // - Act

        sut.inputs.convert(tag: tag, value: "abc")

        // - Assert

        XCTAssertNotNil(receivedTitle)
        XCTAssertNotNil(receivedMessage)
    }

    func test_convert_withEmptyInput_doesNotFireAnyCallback() {

        // - Arrange

        let tag = PressureUnit.bar.rawValue
        var conversionFired = false
        var validationFired = false
        sut.outputs.onConversionResult = { _, _ in conversionFired = true }
        sut.outputs.onValidationError = { _ in validationFired = true }

        // - Act

        sut.inputs.convert(tag: tag, value: "")

        // - Assert

        XCTAssertFalse(conversionFired)
        XCTAssertFalse(validationFired)
    }
}
