//
//  MotorCalculatorViewController.swift
//  Flowculator
//
//  Created by Xaver on 19.11.18.
//  Copyright © 2018 Xaver. All rights reserved.
//

import UIKit
import SnapKit

class MotorCalculatorViewController: UIViewController { // swiftlint:disable:this type_body_length

    // MARK: - Properties

    private var viewModel: MotorCalculatorViewModelType

    // MARK: - Life Cycle

    init(viewModel: MotorCalculatorViewModelType) {
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

    // MARK: - Calculation Type Selector

    private lazy var selectorCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.secondarySystemGroupedBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        return view
    }()

    private lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()

    // MARK: - Input Card

    private lazy var inputCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.secondarySystemGroupedBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        return view
    }()

    private lazy var calculationTitleLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: .displacement)
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = UIColor.systemOrange
        return label
    }()

    // MARK: - Input Fields

    private lazy var firstInputContainer: UIView = {
        return createInputContainer()
    }()

    private lazy var input1TextField: UITextField = {
        let textField = createTextField(placeholder: String(localized: .flowRate))
        return textField
    }()

    private lazy var unit1Label: UILabel = {
        let label = createUnitLabel(text: "l/min")
        return label
    }()

    private lazy var input2Container: UIView = {
        return createInputContainer()
    }()

    private lazy var input2TextField: UITextField = {
        let textField = createTextField(placeholder: String(localized: .rotationSpeed))
        return textField
    }()

    private lazy var unit2Label: UILabel = {
        let label = createUnitLabel(text: "RPM")
        return label
    }()

    private lazy var input3Container: UIView = {
        return createInputContainer()
    }()

    private lazy var input3TextField: UITextField = {
        let textField = createTextField(placeholder: "")
        textField.isEnabled = false
        textField.backgroundColor = UIColor.tertiarySystemGroupedBackground.withAlphaComponent(0.5)
        return textField
    }()

    private lazy var unit3Label: UILabel = {
        let label = createUnitLabel(text: "")
        return label
    }()

    // MARK: - Result Section

    private lazy var resultContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.tertiarySystemGroupedBackground
        view.layer.cornerRadius = 12
        return view
    }()

    private lazy var resultEqualsLabel: UILabel = {
        let label = UILabel()
        label.text = "="
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.textColor = .label
        return label
    }()

    private lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 24, weight: .semibold)
        label.textColor = UIColor.blue
        label.textAlignment = .right
        return label
    }()

    private lazy var resultUnitLabel: UILabel = {
        let label = UILabel()
        label.text = "cm³/rev"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.blue
        return label
    }()

    // MARK: - Calculate Button

    private lazy var calculateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(String(localized: .calculate), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor.blue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 14
        button.layer.shadowColor = UIColor.blue.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 8)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        button.addTarget(self, action: #selector(calculateTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = false

        setupView()
        setupLayout()
        setupKeyboardHandling()
        bindViewModel()

        // Set initial configuration
        viewModel.inputs.selectCalculationType(.displacement)

        animateCardsOnAppear()
    }

    // MARK: - Setup

    private func setupView() {
        view.backgroundColor = UIColor.systemGroupedBackground
        title = String(localized: .hydraulicMotor)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(selectorCard)
        selectorCard.addSubview(pickerView)

        contentView.addSubview(inputCard)
        inputCard.addSubview(calculationTitleLabel)

        // Add input containers
        inputCard.addSubview(firstInputContainer)
        setupInputContainer(firstInputContainer, textField: input1TextField, unitLabel: unit1Label)

        inputCard.addSubview(input2Container)
        setupInputContainer(input2Container, textField: input2TextField, unitLabel: unit2Label)

        inputCard.addSubview(input3Container)
        setupInputContainer(input3Container, textField: input3TextField, unitLabel: unit3Label)

        // Result section
        inputCard.addSubview(resultContainer)
        resultContainer.addSubview(resultEqualsLabel)
        resultContainer.addSubview(resultLabel)
        resultContainer.addSubview(resultUnitLabel)

        contentView.addSubview(calculateButton)
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

        selectorCard.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(180)
        }

        pickerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }

        inputCard.snp.makeConstraints { make in
            make.top.equalTo(selectorCard.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        calculationTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        firstInputContainer.snp.makeConstraints { make in
            make.top.equalTo(calculationTitleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(56)
        }

        input2Container.snp.makeConstraints { make in
            make.top.equalTo(firstInputContainer.snp.bottom).offset(12)
            make.leading.trailing.equalTo(firstInputContainer)
            make.height.equalTo(56)
        }

        input3Container.snp.makeConstraints { make in
            make.top.equalTo(input2Container.snp.bottom).offset(12)
            make.leading.trailing.equalTo(firstInputContainer)
            make.height.equalTo(56)
        }

        resultContainer.snp.makeConstraints { make in
            make.top.equalTo(input3Container.snp.bottom).offset(20)
            make.leading.trailing.equalTo(firstInputContainer)
            make.height.equalTo(60)
            make.bottom.equalToSuperview().offset(-20)
        }

        resultEqualsLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        resultLabel.snp.makeConstraints { make in
            make.leading.equalTo(resultEqualsLabel.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }

        resultUnitLabel.snp.makeConstraints { make in
            make.leading.equalTo(resultLabel.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

        calculateButton.snp.makeConstraints { make in
            make.top.equalTo(inputCard.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-40)
        }
    }

    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        // Add toolbar to text fields
        let toolbar = createKeyboardToolbar()
        input1TextField.inputAccessoryView = toolbar
        input2TextField.inputAccessoryView = toolbar
        input3TextField.inputAccessoryView = toolbar
    }

    // MARK: - ViewModel Binding

    private func bindViewModel() {
        viewModel.outputs.onCalculationTypeChanged = { [weak self] type in
            self?.calculationTitleLabel.text = type.title
        }

        viewModel.outputs.onConfigurationChanged = { [weak self] config in
            self?.updateConfiguration(config)
        }

        viewModel.outputs.onCalculationResult = { [weak self] result in
            self?.resultLabel.text = result
        }

        viewModel.outputs.onValidationError = { [weak self] error in
            self?.showAlert(with: error)
        }
    }

    // MARK: - Factory Methods

    private func createInputContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.tertiarySystemGroupedBackground
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.separator.withAlphaComponent(0.2).cgColor
        return container
    }

    private func setupInputContainer(_ container: UIView, textField: UITextField, unitLabel: UILabel) {
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
    }

    private func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        textField.textColor = .label
        textField.keyboardType = .decimalPad
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .clear
        return textField
    }

    private func createUnitLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor.blue
        label.textAlignment = .right
        return label
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

    // MARK: - Configuration Update

    private func updateConfiguration(_ config: InputConfiguration) {
        // Update placeholders
        input1TextField.placeholder = config.firstPlaceholder
        input2TextField.placeholder = config.secondPlaceholder
        input3TextField.placeholder = config.thirdPlaceholder ?? ""

        // Update units
        unit1Label.text = config.firstUnit
        unit2Label.text = config.secondUnit
        unit3Label.text = config.thirdUnit ?? ""
        resultUnitLabel.text = config.resultUnit

        // Enable/disable third input
        input3TextField.isEnabled = config.isThirdInputRequired
        input3TextField.backgroundColor = config.isThirdInputRequired ?
            UIColor.tertiarySystemGroupedBackground :
            UIColor.tertiarySystemGroupedBackground.withAlphaComponent(0.5)

        // Clear inputs and result
        input1TextField.text = nil
        input2TextField.text = nil
        input3TextField.text = nil
        resultLabel.text = ""
    }

    // MARK: - Actions

    @objc private func calculateTapped() {
        dismissKeyboard()

        viewModel.inputs.calculate(
            input1: input1TextField.text,
            input2: input2TextField.text,
            input3: input3TextField.text
        )

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }

    @objc private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }

    private func showAlert(with error: LocalizedError) {
        let alert = UIAlertController(title: error.errorDescription, message: error.failureReason, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: .ok), style: .default))
        present(alert, animated: true)
    }

    // MARK: - Cleanup

    deinit {
        NotificationCenter.default.removeObserver(self)

        #if DEBUG
        print("🔴 Deinit: \(#file):\(#line)")
        #endif
    }

    // MARK: - Animation

    private func animateCardsOnAppear() {
        let cards = [selectorCard, inputCard, calculateButton]

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

// MARK: - UIPickerViewDelegate & DataSource

extension MotorCalculatorViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CalculationType.allCases.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CalculationType.allCases[row].title
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let type = CalculationType.allCases[row]
        viewModel.inputs.selectCalculationType(type)
    }
} // swiftlint:disable:this file_length
