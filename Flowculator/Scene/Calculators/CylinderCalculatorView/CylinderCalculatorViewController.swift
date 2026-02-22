//
//  CylinderCalculatorViewController.swift
//  Flowculator
//
//  Created by Xaver on 10.08.18.
//  Copyright © 2018 Xaver. All rights reserved.
//

import UIKit
import SnapKit

class CylinderCalculatorViewController: UIViewController { // swiftlint:disable:this type_body_length

    // MARK: - Properties

    private var viewModel: CylinderCalculatorViewModelType

    // MARK: - Life Cycle

    init(viewModel: CylinderCalculatorViewModelType) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()

    // MARK: - Input Card

    private lazy var inputCard: UIView = {
        return createCard()
    }()

    private lazy var pistonDiameterField = createInputRow(placeholder: String(localized: .cylinderPistonDiameter), unit: "mm")
    private lazy var rodDiameterField = createInputRow(placeholder: String(localized: .cylinderRodDiameter), unit: "mm")
    private lazy var pressureField = createInputRow(placeholder: String(localized: .cylinderWorkingPressure), unit: "bar")
    private lazy var strokeField = createInputRow(placeholder: String(localized: .cylinderStroke), unit: "mm")
    private lazy var flowRateField = createInputRow(placeholder: String(localized: .flowRate), unit: "l/min")

    // MARK: - Calculate Button

    private lazy var calculateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(String(localized: .calculate), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor.blue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 14
        button.layer.shadowColor = UIColor.blue.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        button.addTarget(self, action: #selector(calculateTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Results Card

    private lazy var resultsCard: UIView = {
        return createCard()
    }()

    private lazy var resultsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    // Result section views
    private var areaSection: ResultSectionView!
    private var volumeSection: ResultSectionView!
    private var forceSection: ResultSectionView!
    private var timeSection: ResultSectionView!
    private var speedSection: ResultSectionView!
    private var powerSection: ResultSectionView!
    private var ratioSection: ResultSectionView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = false

        setupView()
        setupLayout()
        setupKeyboardHandling()
        bindViewModel()
        createResultSections()

        animateCardsOnAppear()
    }

    // MARK: - Setup

    private func setupView() {
        view.backgroundColor = UIColor.systemGroupedBackground
        title = String(localized: .hydraulicCylinder)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Add input card
        contentView.addSubview(inputCard)
        inputCard.addSubview(pistonDiameterField.container)
        inputCard.addSubview(rodDiameterField.container)
        inputCard.addSubview(pressureField.container)
        inputCard.addSubview(strokeField.container)
        inputCard.addSubview(flowRateField.container)

        contentView.addSubview(calculateButton)

        // Add results card
        contentView.addSubview(resultsCard)
        resultsCard.addSubview(resultsStackView)
    }

    private func setupLayout() {
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        inputCard.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        pistonDiameterField.container.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(56)
        }

        rodDiameterField.container.snp.makeConstraints { make in
            make.top.equalTo(pistonDiameterField.container.snp.bottom).offset(12)
            make.leading.trailing.equalTo(pistonDiameterField.container)
            make.height.equalTo(56)
        }

        pressureField.container.snp.makeConstraints { make in
            make.top.equalTo(rodDiameterField.container.snp.bottom).offset(12)
            make.leading.trailing.equalTo(pistonDiameterField.container)
            make.height.equalTo(56)
        }

        strokeField.container.snp.makeConstraints { make in
            make.top.equalTo(pressureField.container.snp.bottom).offset(12)
            make.leading.trailing.equalTo(pistonDiameterField.container)
            make.height.equalTo(56)
        }

        flowRateField.container.snp.makeConstraints { make in
            make.top.equalTo(strokeField.container.snp.bottom).offset(12)
            make.leading.trailing.equalTo(pistonDiameterField.container)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-20)
        }

        // Calculate button
        calculateButton.snp.makeConstraints { make in
            make.top.equalTo(inputCard.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(56)
        }

        // Results card
        resultsCard.snp.makeConstraints { make in
            make.top.equalTo(calculateButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-40)
        }

        resultsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }

    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        // Add toolbar to text fields
        let toolbar = createKeyboardToolbar()
        pistonDiameterField.textField.inputAccessoryView = toolbar
        rodDiameterField.textField.inputAccessoryView = toolbar
        pressureField.textField.inputAccessoryView = toolbar
        strokeField.textField.inputAccessoryView = toolbar
        flowRateField.textField.inputAccessoryView = toolbar
    }

    private func createResultSections() {
        let pistonSide = String(localized: .cylinderPistonSide)
        let rodSide = String(localized: .cylinderRodSide)

        // Area section
        areaSection = ResultSectionView(
            title: String(localized: .cylinderArea),
            unit: "cm²",
            pistonLabel: pistonSide,
            rodLabel: rodSide,
            showDifferential: true
        )
        resultsStackView.addArrangedSubview(areaSection)

        // Volume section
        volumeSection = ResultSectionView(
            title: String(localized: .cylinderStrokeVolume),
            unit: "l",
            pistonLabel: pistonSide,
            rodLabel: rodSide,
            showDifferential: true
        )
        resultsStackView.addArrangedSubview(volumeSection)

        // Force section
        forceSection = ResultSectionView(
            title: String(localized: .cylinderForce),
            unit: "kN",
            pistonLabel: pistonSide,
            rodLabel: rodSide,
            showDifferential: true
        )
        resultsStackView.addArrangedSubview(forceSection)

        // Time section
        timeSection = ResultSectionView(
            title: String(localized: .cylinderStrokeTime),
            unit: "s",
            pistonLabel: pistonSide,
            rodLabel: rodSide,
            showDifferential: false
        )
        resultsStackView.addArrangedSubview(timeSection)

        // Speed section
        speedSection = ResultSectionView(
            title: String(localized: .cylinderStrokeSpeed),
            unit: "m/s",
            pistonLabel: pistonSide,
            rodLabel: rodSide,
            showDifferential: false
        )
        resultsStackView.addArrangedSubview(speedSection)

        // Power section
        powerSection = ResultSectionView(
            title: String(localized: .cylinderMaxPower),
            unit: "kW",
            pistonLabel: pistonSide,
            rodLabel: nil,
            showDifferential: false
        )
        resultsStackView.addArrangedSubview(powerSection)

        // Ratio section
        ratioSection = ResultSectionView(
            title: String(localized: .cylinderAreaRatio),
            unit: "",
            pistonLabel: pistonSide,
            rodLabel: nil,
            showDifferential: false
        )
        resultsStackView.addArrangedSubview(ratioSection)
    }

    // MARK: - ViewModel Binding

    private func bindViewModel() {
        viewModel.outputs.onCalculationResult = { [weak self] results in
            self?.updateResults(results)
        }

        viewModel.outputs.onValidationError = { [weak self] error in
            self?.showAlert(with: error)
        }
    }

    // MARK: - Factory Methods

    private func createCard() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.secondarySystemGroupedBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        return view
    }

    private func createInputRow(
        placeholder: String,
        unit: String
    ) -> (container: UIView, textField: UITextField, unitLabel: UILabel) {
        let container = UIView()
        container.backgroundColor = UIColor.tertiarySystemGroupedBackground
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.separator.withAlphaComponent(0.2).cgColor

        let textField = UITextField()
        textField.placeholder = placeholder
        textField.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        textField.textColor = .label
        textField.keyboardType = .decimalPad
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .clear

        let unitLabel = UILabel()
        unitLabel.text = unit
        unitLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        unitLabel.textColor = UIColor.blue
        unitLabel.textAlignment = .right

        container.addSubview(textField)
        container.addSubview(unitLabel)

        textField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(unitLabel.snp.leading).offset(-12)
        }

        unitLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(60)
        }

        return (container, textField, unitLabel)
    }

    private func createKeyboardToolbar() -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        toolbar.tintColor = UIColor.blue

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(
            title: String(localized: .calculate),
            style: .prominent,
            target: self,
            action: #selector(calculateTapped)
        )
        let cancelButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.down"),
            style: .plain,
            target: self,
            action: #selector(dismissKeyboard)
        )

        toolbar.items = [cancelButton, flexSpace, doneButton]
        toolbar.sizeToFit()

        return toolbar
    }

    // MARK: - Update Results

    private func updateResults(_ results: CylinderResults) {
        areaSection.updateValues(
            piston: results.pistonArea,
            rod: results.rodSideArea,
            differential: results.differentialArea
        )

        volumeSection.updateValues(
            piston: results.pistonVolume,
            rod: results.rodSideVolume,
            differential: results.differentialVolume
        )

        forceSection.updateValues(
            piston: results.pistonForce,
            rod: results.rodSideForce,
            differential: results.differentialForce
        )

        timeSection.updateValues(
            piston: results.pistonTime,
            rod: results.rodSideTime,
            differential: nil
        )

        speedSection.updateValues(
            piston: results.pistonSpeed,
            rod: results.rodSideSpeed,
            differential: nil
        )

        powerSection.updateValues(
            piston: results.maxPower,
            rod: nil,
            differential: nil
        )

        ratioSection.updateValues(
            piston: results.areaRatio,
            rod: nil,
            differential: nil
        )
    }

    // MARK: - Actions

    @objc private func calculateTapped() {
        dismissKeyboard()

        viewModel.inputs.calculate(
            pistonDiameter: pistonDiameterField.textField.text,
            rodDiameter: rodDiameterField.textField.text,
            pressure: pressureField.textField.text,
            stroke: strokeField.textField.text,
            flowRate: flowRateField.textField.text
        )

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func showAlert(with error: LocalizedError) {
        let alert = UIAlertController(title: error.errorDescription, message: error.failureReason, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: .ok), style: .default))
        present(alert, animated: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)

        #if DEBUG
        print("🔴 Deinit: \(#file):\(#line)")
        #endif
    }

    // MARK: - Animation

    private func animateCardsOnAppear() {
        let cards = [inputCard, calculateButton, resultsCard]

        cards.enumerated().forEach { index, card in
            card.alpha = 0
            card.transform = CGAffineTransform(translationX: 0, y: 20)

            UIView.animate(
                withDuration: 0.5,
                delay: Double(index) * 0.1,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: .curveEaseOut
            ) {
                card.alpha = 1
                card.transform = .identity
            }
        }
    }
}

// MARK: - Result Section View

class ResultSectionView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let pistonHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.systemOrange
        label.textAlignment = .center
        return label
    }()

    private let rodHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.systemOrange
        label.textAlignment = .center
        return label
    }()

    private let differentialHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: .cylinderDifferential)
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.systemOrange
        label.textAlignment = .center
        return label
    }()

    private let pistonValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0.0"
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .regular)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private let rodValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0.0"
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .regular)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private let differentialValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0.0"
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .regular)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private let unitLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor.blue
        label.textAlignment = .right
        return label
    }()

    init(title: String, unit: String, pistonLabel: String, rodLabel: String?, showDifferential: Bool) {
        super.init(frame: .zero)

        titleLabel.text = title
        unitLabel.text = unit
        pistonHeaderLabel.text = pistonLabel
        rodHeaderLabel.text = rodLabel

        setupView(showRod: rodLabel != nil, showDifferential: showDifferential)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(showRod: Bool, showDifferential: Bool) {
        addSubview(titleLabel)
        addSubview(pistonHeaderLabel)
        addSubview(pistonValueLabel)
        addSubview(unitLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }

        pistonHeaderLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview()
            make.width.equalTo(showRod || showDifferential ? 100 : 120)
        }

        pistonValueLabel.snp.makeConstraints { make in
            make.top.equalTo(pistonHeaderLabel.snp.bottom).offset(4)
            make.leading.trailing.equalTo(pistonHeaderLabel)
            make.bottom.equalToSuperview()
        }

        if showRod {
            addSubview(rodHeaderLabel)
            addSubview(rodValueLabel)

            rodHeaderLabel.snp.makeConstraints { make in
                make.top.equalTo(pistonHeaderLabel)
                make.leading.equalTo(pistonHeaderLabel.snp.trailing).offset(8)
                make.width.equalTo(pistonHeaderLabel)
            }

            rodValueLabel.snp.makeConstraints { make in
                make.top.equalTo(rodHeaderLabel.snp.bottom).offset(4)
                make.leading.trailing.equalTo(rodHeaderLabel)
            }
        }

        if showDifferential {
            addSubview(differentialHeaderLabel)
            addSubview(differentialValueLabel)

            differentialHeaderLabel.snp.makeConstraints { make in
                make.top.equalTo(pistonHeaderLabel)
                make.leading.equalTo((showRod ? rodHeaderLabel : pistonHeaderLabel).snp.trailing).offset(8)
                make.width.equalTo(pistonHeaderLabel)
            }

            differentialValueLabel.snp.makeConstraints { make in
                make.top.equalTo(differentialHeaderLabel.snp.bottom).offset(4)
                make.leading.trailing.equalTo(differentialHeaderLabel)
            }
        }

        unitLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(pistonValueLabel)
        }
    }

    func updateValues(piston: Double, rod: Double?, differential: Double?) {
        pistonValueLabel.text = String(format: "%.2f", piston)

        if let rod = rod {
            rodValueLabel.text = String(format: "%.2f", rod)
        }

        if let differential = differential {
            differentialValueLabel.text = String(format: "%.2f", differential)
        }
    }
} // swiftlint:disable:this file_length
