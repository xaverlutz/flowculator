//
//  MotorCalculatorViewModelTests.swift
//  FlowculatorTests
//
//  Created by Xaver Lutz on 22.02.26.
//

import XCTest

@testable import Flowculator

class MotorCalculatorViewModelTests: XCTestCase {

    var sut: MotorCalculatorViewModel!

    override func setUp() {
        super.setUp()
        sut = MotorCalculatorViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Displacement Tests

    func testCalculateDisplacement() {
        // Given
        sut.selectCalculationType(.displacement)
        var result: String?

        sut.onCalculationResult = { calculatedResult in
            result = calculatedResult
        }

        // When
        sut.calculate(input1: "10", input2: "1000", input3: nil)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "10.00")
    }

    // MARK: - Flow Rate Tests

    func testCalculateFlowRate() {
        // Given
        sut.selectCalculationType(.flowRate)
        var result: String?

        sut.onCalculationResult = { calculatedResult in
            result = calculatedResult
        }

        // When
        sut.calculate(input1: "10", input2: "1000", input3: nil)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "10.00")
    }

    // MARK: - Rotation Speed Tests

    func testCalculateRotationSpeed() {
        // Given
        sut.selectCalculationType(.rotationSpeed)
        var result: String?

        sut.onCalculationResult = { calculatedResult in
            result = calculatedResult
        }

        // When
        sut.calculate(input1: "10", input2: "10", input3: nil)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "1000.00")
    }

    // MARK: - Output Torque Tests

    func testCalculateOutputTorque() {
        // Given
        sut.selectCalculationType(.outputTorque)
        var result: String?

        sut.onCalculationResult = { calculatedResult in
            result = calculatedResult
        }

        // When
        sut.calculate(input1: "100", input2: "50", input3: "0.9")

        // Then
        XCTAssertNotNil(result)
        // (100 * 50 * 0.9) / 62.83 / 10 = 7.16
        XCTAssertEqual(result, "7.16")
    }

    // MARK: - Performance I Tests

    func testCalculatePerformanceI() {
        // Given
        sut.selectCalculationType(.performanceI)
        var result: String?

        sut.onCalculationResult = { calculatedResult in
            result = calculatedResult
        }

        // When
        sut.calculate(input1: "100", input2: "1000", input3: "0.9")

        // Then
        XCTAssertNotNil(result)
        // 100 * 1000 / 954.9 * 0.9 = 94.25
        XCTAssertEqual(result, "94.25")
    }

    // MARK: - Performance II Tests

    func testCalculatePerformanceII() {
        // Given
        sut.selectCalculationType(.performanceII)
        var result: String?

        sut.onCalculationResult = { calculatedResult in
            result = calculatedResult
        }

        // When
        sut.calculate(input1: "100", input2: "50", input3: "0.9")

        // Then
        XCTAssertNotNil(result)
        // 50 * 100 / 612 * 0.9 = 7.35
        XCTAssertEqual(result, "7.35")
    }

    // MARK: - Torque Tests

    func testCalculateTorque() {
        // Given
        sut.selectCalculationType(.torque)
        var result: String?

        sut.onCalculationResult = { calculatedResult in
            result = calculatedResult
        }

        // When
        sut.calculate(input1: "10", input2: "1000", input3: "0.9")

        // Then
        XCTAssertNotNil(result)
        // 10 * 954.9 * 0.9 / 1000 = 8.59
        XCTAssertEqual(result, "8.59")
    }

    // MARK: - Validation Tests

    func testValidation_EmptyFields() {

        // - Arrange

        var validationFired = false

        sut.selectCalculationType(.displacement)
        sut.onValidationError = { _ in validationFired = true }

        // - Act

        sut.calculate(input1: "", input2: "", input3: nil)

        // - Assert

        XCTAssertTrue(validationFired)
    }

    func testValidation_InvalidNumbers() {

        // - Arrange

        var validationFired = false
        sut.selectCalculationType(.displacement)

        sut.onValidationError = { _ in validationFired = true }

        // - Act

        sut.calculate(input1: "abc", input2: "123", input3: nil)

        // - Assert

        XCTAssertTrue(validationFired)
    }

    // MARK: - Configuration Tests

//    func testConfigurationChange_Displacement() {
//        // Given
//        var config: InputConfiguration?
//
//        sut.onConfigurationChanged = { configuration in
//            config = configuration
//        }
//
//        // When
//        sut.selectCalculationType(.displacement)
//
//        // Then
//        XCTAssertNotNil(config)
//        XCTAssertEqual(config?.unit1, "l/min")
//        XCTAssertEqual(config?.unit2, "RPM")
//        XCTAssertEqual(config?.resultUnit, "cm³/rev")
//        XCTAssertFalse(config?.requiresThirdInput ?? true)
//    }

//    func testConfigurationChange_OutputTorque() {
//        // Given
//        var config: InputConfiguration?
//
//        sut.onConfigurationChanged = { configuration in
//            config = configuration
//        }
//
//        // When
//        sut.selectCalculationType(.outputTorque)
//
//        // Then
//        XCTAssertNotNil(config)
//        XCTAssertEqual(config?.unit1, "bar")
//        XCTAssertEqual(config?.unit2, "cm³/rev")
//        XCTAssertEqual(config?.resultUnit, "daNm")
//        XCTAssertTrue(config?.requiresThirdInput ?? false)
//    }

    // MARK: - Calculation Type Tests

//    func testGetAllCalculationTypes() {
//        // When
//        let types = sut.getAllCalculationTypes()
//
//        // Then
//        XCTAssertEqual(types.count, 7)
//        XCTAssertEqual(types[0], .displacement)
//        XCTAssertEqual(types[6], .torque)
//    }

    func testSelectCalculationType_CallsCallbacks() {
        // Given
        var typeChanged = false
        var configChanged = false

        sut.onCalculationTypeChanged = { _ in
            typeChanged = true
        }

        sut.onConfigurationChanged = { _ in
            configChanged = true
        }

        // When
        sut.selectCalculationType(.flowRate)

        // Then
        XCTAssertTrue(typeChanged)
        XCTAssertTrue(configChanged)
    }

    // MARK: - Comma Handling Tests

    func testCalculate_WithCommaDecimalSeparator() {
        // Given
        sut.selectCalculationType(.displacement)
        var result: String?

        sut.onCalculationResult = { calculatedResult in
            result = calculatedResult
        }

        // When
        sut.calculate(input1: "10,5", input2: "1000", input3: nil)

        // Then
        XCTAssertNotNil(result)
    }
}
