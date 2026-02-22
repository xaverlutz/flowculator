//
//  CylinderCalculatorViewModelTests.swift
//  FlowculatorTests
//
//  Created by Xaver Lutz on 22.02.26.
//

import XCTest

@testable import Flowculator

final class CylinderCalculatorViewModelTests: XCTestCase {

    var sut: CylinderCalculatorViewModel!

    // MARK: - Test Setup

    override func setUp() {
        super.setUp()
        sut = CylinderCalculatorViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Validation Tests

    func test_calculate_withEmptyFields_firesValidationError() {

        // - Arrange

        var validationFired = false
        sut.outputs.onValidationError = { _ in validationFired = true }

        // - Act

        sut.inputs.calculate(
            pistonDiameter: "",
            rodDiameter: "",
            pressure: "",
            stroke: "",
            flowRate: ""
        )

        // - Assert

        XCTAssertTrue(validationFired)
    }

    func test_calculate_withNilFields_firesValidationError() {

        // - Arrange

        var validationFired = false
        sut.outputs.onValidationError = { _ in validationFired = true }

        // - Act

        sut.inputs.calculate(
            pistonDiameter: nil,
            rodDiameter: nil,
            pressure: nil,
            stroke: nil,
            flowRate: nil
        )

        // - Assert

        XCTAssertTrue(validationFired)
    }

    func test_calculate_withInvalidNumbers_firesValidationError() {

        // - Arrange

        var validationFired = false
        sut.outputs.onValidationError = { _ in validationFired = true }

        // - Act

        sut.inputs.calculate(
            pistonDiameter: "abc",
            rodDiameter: "50",
            pressure: "100",
            stroke: "200",
            flowRate: "20"
        )

        // - Assert

        XCTAssertTrue(validationFired)
    }

    func test_calculate_withRodLargerThanPiston_firesValidationError() {

        // - Arrange

        var errorTitle: String?
        sut.outputs.onValidationError = { error in
            errorTitle = error.errorDescription
        }

        // - Act

        sut.inputs.calculate(
            pistonDiameter: "50",
            rodDiameter: "100",
            pressure: "100",
            stroke: "200",
            flowRate: "20"
        )

        // - Assert

        XCTAssertNotNil(errorTitle)
    }

    func test_calculate_withValidInputs_firesCalculationResult() {

        // - Arrange

        var receivedResult: CylinderResults?
        sut.outputs.onCalculationResult = { result in
            receivedResult = result
        }

        // - Act

        sut.inputs.calculate(
            pistonDiameter: "100",
            rodDiameter: "50",
            pressure: "100",
            stroke: "200",
            flowRate: "20"
        )

        // - Assert

        XCTAssertNotNil(receivedResult)
    }

    func test_calculate_withValidInputs_doesNotFireValidationError() {

        // - Arrange

        var validationFired = false
        sut.outputs.onValidationError = { _ in validationFired = true }

        // - Act

        sut.inputs.calculate(
            pistonDiameter: "100",
            rodDiameter: "50",
            pressure: "100",
            stroke: "200",
            flowRate: "20"
        )

        // - Assert

        XCTAssertFalse(validationFired)
    }

    // MARK: - Area Calculation Tests

    func test_calculate_areas_returnsCorrectValues() {

        // - Arrange

        var receivedResult: CylinderResults?
        sut.outputs.onCalculationResult = { result in
            receivedResult = result
        }

        // - Act

        sut.inputs.calculate(
            pistonDiameter: "100",
            rodDiameter: "50",
            pressure: "100",
            stroke: "200",
            flowRate: "20"
        )

        // - Assert

        XCTAssertNotNil(receivedResult)
        XCTAssertEqual(receivedResult!.pistonArea, 78.54, accuracy: 0.01)
        XCTAssertEqual(receivedResult!.differentialArea, 19.63, accuracy: 0.01)
        XCTAssertEqual(receivedResult!.rodSideArea, 58.90, accuracy: 0.01)
    }

    // MARK: - Volume Calculation Tests

    func test_calculate_volumes_returnsCorrectValues() {

        // - Arrange

        var receivedResult: CylinderResults?
        sut.outputs.onCalculationResult = { result in
            receivedResult = result
        }

        // - Act

        sut.inputs.calculate(
            pistonDiameter: "100",
            rodDiameter: "50",
            pressure: "100",
            stroke: "200",
            flowRate: "20"
        )

        // - Assert

        XCTAssertNotNil(receivedResult)
        XCTAssertEqual(receivedResult!.pistonVolume, 1.57, accuracy: 0.01)
        XCTAssertEqual(receivedResult!.rodSideVolume, 1.18, accuracy: 0.01)
        XCTAssertEqual(receivedResult!.differentialVolume, 0.39, accuracy: 0.01)
    }

    // MARK: - Force Calculation Tests

    func test_calculate_forces_returnsCorrectValues() {

        // - Arrange

        var receivedResult: CylinderResults?
        sut.outputs.onCalculationResult = { result in
            receivedResult = result
        }

        // - Act

        sut.inputs.calculate(
            pistonDiameter: "100",
            rodDiameter: "50",
            pressure: "100",
            stroke: "200",
            flowRate: "20"
        )

        // - Assert

        XCTAssertNotNil(receivedResult)
        XCTAssertEqual(receivedResult!.pistonForce, 78.50, accuracy: 0.01)
        XCTAssertEqual(receivedResult!.rodSideForce, 58.88, accuracy: 0.01)
        XCTAssertEqual(receivedResult!.differentialForce, 19.63, accuracy: 0.01)
    }

    // MARK: - Time Calculation Tests

    func test_calculate_times_returnsCorrectValues() {

        // - Arrange

        var receivedResult: CylinderResults?
        sut.outputs.onCalculationResult = { result in
            receivedResult = result
        }

        // - Act

        sut.inputs.calculate(
            pistonDiameter: "100",
            rodDiameter: "50",
            pressure: "100",
            stroke: "200",
            flowRate: "20"
        )

        // - Assert

        XCTAssertNotNil(receivedResult)
        XCTAssertEqual(receivedResult!.pistonTime, 4.71, accuracy: 0.01)
        XCTAssertEqual(receivedResult!.rodSideTime, 3.53, accuracy: 0.01)
    }

    // MARK: - Speed Calculation Tests

    func test_calculate_speeds_returnsCorrectValues() {

        // - Arrange

        var receivedResult: CylinderResults?
        sut.outputs.onCalculationResult = { result in
            receivedResult = result
        }

        // - Act

        sut.inputs.calculate(
            pistonDiameter: "100",
            rodDiameter: "50",
            pressure: "100",
            stroke: "200",
            flowRate: "20"
        )

        // - Assert

        XCTAssertNotNil(receivedResult)
        XCTAssertEqual(receivedResult!.pistonSpeed, 0.0424, accuracy: 0.001)
        XCTAssertEqual(receivedResult!.rodSideSpeed, 0.0566, accuracy: 0.001)
    }

    // MARK: - Power & Ratio Calculation Tests

    func test_calculate_maxPowerAndAreaRatio_returnsCorrectValues() {

        // - Arrange

        var receivedResult: CylinderResults?
        sut.outputs.onCalculationResult = { result in
            receivedResult = result
        }

        // - Act

        sut.inputs.calculate(
            pistonDiameter: "100",
            rodDiameter: "50",
            pressure: "100",
            stroke: "200",
            flowRate: "20"
        )

        // - Assert

        XCTAssertNotNil(receivedResult)
        XCTAssertEqual(receivedResult!.maxPower, 3.33, accuracy: 0.01)
        XCTAssertEqual(receivedResult!.areaRatio, 1.33, accuracy: 0.01)
    }

    // MARK: - Comma Handling Tests

    func test_calculate_withCommaDecimalSeparator_returnsResult() {

        // - Arrange

        var receivedResult: CylinderResults?
        sut.outputs.onCalculationResult = { result in
            receivedResult = result
        }

        // - Act

        sut.inputs.calculate(
            pistonDiameter: "100,0",
            rodDiameter: "50,0",
            pressure: "100",
            stroke: "200",
            flowRate: "20"
        )

        // - Assert

        XCTAssertNotNil(receivedResult)
    }
}
