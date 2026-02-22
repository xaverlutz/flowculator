//
//  MotorCalculatorViewModelTests.swift
//  FlowculatorTests
//
//  Created by Xaver Lutz on 22.02.26.
//

import XCTest

@testable import Flowculator

final class MotorCalculatorViewModelTests: XCTestCase {

    var sut: MotorCalculatorViewModel!

    // MARK: - Test Setup

    override func setUp() {
        super.setUp()
        sut = MotorCalculatorViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Validation Tests

    func test_calculate_withEmptyFields_firesValidationError() {

        // - Arrange

        var validationFired = false
        sut.inputs.selectCalculationType(.displacement)
        sut.outputs.onValidationError = { _ in validationFired = true }

        // - Act

        sut.inputs.calculate(input1: "", input2: "", input3: nil)

        // - Assert

        XCTAssertTrue(validationFired)
    }

    func test_calculate_withInvalidNumbers_firesValidationError() {

        // - Arrange

        var validationFired = false
        sut.inputs.selectCalculationType(.displacement)
        sut.outputs.onValidationError = { _ in validationFired = true }

        // - Act

        sut.inputs.calculate(input1: "abc", input2: "123", input3: nil)

        // - Assert

        XCTAssertTrue(validationFired)
    }

    // MARK: - Displacement Tests

    func test_calculate_displacement_returnsCorrectResult() {

        // - Arrange

        sut.inputs.selectCalculationType(.displacement)
        var result: String?
        sut.outputs.onCalculationResult = { calculatedResult in
            result = calculatedResult
        }

        // - Act

        sut.inputs.calculate(input1: "10", input2: "1000", input3: nil)

        // - Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result, "10.00")
    }

    // MARK: - Flow Rate Tests

    func test_calculate_flowRate_returnsCorrectResult() {

        // - Arrange

        sut.inputs.selectCalculationType(.flowRate)
        var result: String?
        sut.outputs.onCalculationResult = { calculatedResult in
            result = calculatedResult
        }

        // - Act

        sut.inputs.calculate(input1: "10", input2: "1000", input3: nil)

        // - Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result, "10.00")
    }

    // MARK: - Rotation Speed Tests

    func test_calculate_rotationSpeed_returnsCorrectResult() {

        // - Arrange

        sut.inputs.selectCalculationType(.rotationSpeed)
        var result: String?
        sut.outputs.onCalculationResult = { calculatedResult in
            result = calculatedResult
        }

        // - Act

        sut.inputs.calculate(input1: "10", input2: "10", input3: nil)

        // - Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result, "1000.00")
    }

    // MARK: - Output Torque Tests

    func test_calculate_outputTorque_returnsCorrectResult() {

        // - Arrange

        sut.inputs.selectCalculationType(.outputTorque)
        var result: String?
        sut.outputs.onCalculationResult = { calculatedResult in
            result = calculatedResult
        }

        // - Act

        sut.inputs.calculate(input1: "100", input2: "50", input3: "0.9")

        // - Assert

        XCTAssertNotNil(result)
        // (100 * 50 * 0.9) / 62.83 / 10 = 7.16
        XCTAssertEqual(result, "7.16")
    }

    // MARK: - Performance I Tests

    func test_calculate_performanceI_returnsCorrectResult() {

        // - Arrange

        sut.inputs.selectCalculationType(.performanceI)
        var result: String?
        sut.outputs.onCalculationResult = { calculatedResult in
            result = calculatedResult
        }

        // - Act

        sut.inputs.calculate(input1: "100", input2: "1000", input3: "0.9")

        // - Assert

        XCTAssertNotNil(result)
        // 100 * 1000 / 954.9 * 0.9 = 94.25
        XCTAssertEqual(result, "94.25")
    }

    // MARK: - Performance II Tests

    func test_calculate_performanceII_returnsCorrectResult() {

        // - Arrange

        sut.inputs.selectCalculationType(.performanceII)
        var result: String?
        sut.outputs.onCalculationResult = { calculatedResult in
            result = calculatedResult
        }

        // - Act

        sut.inputs.calculate(input1: "100", input2: "50", input3: "0.9")

        // - Assert

        XCTAssertNotNil(result)
        // 50 * 100 / 612 * 0.9 = 7.35
        XCTAssertEqual(result, "7.35")
    }

    // MARK: - Torque Tests

    func test_calculate_torque_returnsCorrectResult() {

        // - Arrange

        sut.inputs.selectCalculationType(.torque)
        var result: String?
        sut.outputs.onCalculationResult = { calculatedResult in
            result = calculatedResult
        }

        // - Act

        sut.inputs.calculate(input1: "10", input2: "1000", input3: "0.9")

        // - Assert

        XCTAssertNotNil(result)
        // 10 * 954.9 * 0.9 / 1000 = 8.59
        XCTAssertEqual(result, "8.59")
    }

    // MARK: - Configuration Tests

    func test_selectCalculationType_callsCallbacks() {

        // - Arrange

        var typeChanged = false
        var configChanged = false

        sut.outputs.onCalculationTypeChanged = { _ in
            typeChanged = true
        }

        sut.outputs.onConfigurationChanged = { _ in
            configChanged = true
        }

        // - Act

        sut.inputs.selectCalculationType(.flowRate)

        // - Assert

        XCTAssertTrue(typeChanged)
        XCTAssertTrue(configChanged)
    }

    // MARK: - Comma Handling Tests

    func test_calculate_withCommaDecimalSeparator_returnsResult() {

        // - Arrange

        sut.inputs.selectCalculationType(.displacement)
        var result: String?
        sut.outputs.onCalculationResult = { calculatedResult in
            result = calculatedResult
        }

        // - Act

        sut.inputs.calculate(input1: "10,5", input2: "1000", input3: nil)

        // - Assert

        XCTAssertNotNil(result)
    }
}
