//
//  ConverterViewController.swift
//  Flowculator
//
//  Created by Xaver on 13.08.18.
//  Copyright © 2018 Xaver. All rights reserved.
//

import UIKit
import SnapKit

class ConverterViewController: UIViewController { // swiftlint:disable:this type_body_length

    // MARK: - Properties

    private var viewModel: ConverterViewModelType!

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

    // MARK: - Section Cards

    private lazy var pressureCard: UIView = {
        return createSectionCard(
            icon: "gauge.medium",
            title: String(localized: .converterPressure),
            color: UIColor.systemBlue
        )
    }()

    private lazy var temperatureCard: UIView = {
        return createSectionCard(
            icon: "thermometer.medium",
            title: String(localized: .converterTemperature),
            color: UIColor.systemOrange
        )
    }()

    private lazy var powerCard: UIView = {
        return createSectionCard(
            icon: "bolt.fill",
            title: String(localized: .converterPower),
            color: UIColor.systemYellow
        )
    }()

    private lazy var lengthCard: UIView = {
        return createSectionCard(
            icon: "ruler",
            title: String(localized: .converterLength),
            color: UIColor.systemGreen
        )
    }()

    private lazy var spaceCard: UIView = {
        return createSectionCard(
            icon: "cube.fill",
            title: String(localized: .converterVolumeSpace),
            color: UIColor.systemPurple
        )
    }()

    private lazy var liquidCard: UIView = {
        return createSectionCard(
            icon: "drop.fill",
            title: String(localized: .converterLiquidVolume),
            color: UIColor.systemTeal
        )
    }()

    // MARK: - Text Fields

    private lazy var ftBar = createModernTextField(tag: PressureUnit.bar.rawValue, placeholder: "0")
    private lazy var ftMPa = createModernTextField(tag: PressureUnit.mpa.rawValue, placeholder: "0")
    private lazy var ftPsi = createModernTextField(tag: PressureUnit.psi.rawValue, placeholder: "0")

    private lazy var ftCelsius = createModernTextField(tag: TemperatureUnit.celsius.rawValue, placeholder: "0")
    private lazy var ftFahren = createModernTextField(tag: TemperatureUnit.fahrenheit.rawValue, placeholder: "0")
    private lazy var ftKelvin = createModernTextField(tag: TemperatureUnit.kelvin.rawValue, placeholder: "0")

    private lazy var ftKW = createModernTextField(tag: PowerUnit.kilowatt.rawValue, placeholder: "0")
    private lazy var ftKcal = createModernTextField(tag: PowerUnit.kilocaloriePerHour.rawValue, placeholder: "0")
    private lazy var ftPS = createModernTextField(tag: PowerUnit.horsepower.rawValue, placeholder: "0")

    private lazy var ftMM = createModernTextField(tag: LengthUnit.millimeter.rawValue, placeholder: "0")
    private lazy var ftInch = createModernTextField(tag: LengthUnit.inch.rawValue, placeholder: "0")
    private lazy var ftFT = createModernTextField(tag: LengthUnit.feet.rawValue, placeholder: "0")

    private lazy var ftcm = createModernTextField(tag: VolumeUnit.cubicCentimeter.rawValue, placeholder: "0")
    private lazy var ftinch3 = createModernTextField(tag: VolumeUnit.cubicInch.rawValue, placeholder: "0")
    private lazy var ftFT3 = createModernTextField(tag: VolumeUnit.cubicFeet.rawValue, placeholder: "0")

    private lazy var ftLiter = createModernTextField(tag: LiquidVolumeUnit.liter.rawValue, placeholder: "0")
    private lazy var ftLiqgal = createModernTextField(tag: LiquidVolumeUnit.usGallon.rawValue, placeholder: "0")
    private lazy var ftimp = createModernTextField(tag: LiquidVolumeUnit.imperialGallon.rawValue, placeholder: "0")

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = ConverterViewModel()
        bindViewModel()

        setupView()
        setupLayout()

        // Animate cards on load
        animateCardsOnAppear()
    }

    deinit {
        #if DEBUG
        print("🔴 Deinit: \(#file):\(#line)")
        #endif
    }

    // MARK: - Bindings

    private func bindViewModel() {
        viewModel.outputs.onConversionResult = { [weak self] tag, result in
            self?.updateTextFields(for: tag, with: result)
        }

        viewModel.outputs.onValidationError = { [weak self] title, message in
            self?.showModernAlert(title: title, message: message)
        }
    }

    // MARK: - Setup

    private func setupView() {
        view.backgroundColor = UIColor.systemGroupedBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Add section cards
        contentView.addSubview(pressureCard)
        contentView.addSubview(temperatureCard)
        contentView.addSubview(powerCard)
        contentView.addSubview(lengthCard)
        contentView.addSubview(spaceCard)
        contentView.addSubview(liquidCard)

        // Add fields to cards
        setupPressureFields()
        setupTemperatureFields()
        setupPowerFields()
        setupLengthFields()
        setupSpaceFields()
        setupLiquidFields()
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

        let cardSpacing: CGFloat = 16
        let cardPadding: CGFloat = 20

        pressureCard.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(cardPadding)
            make.trailing.equalToSuperview().offset(-cardPadding)
        }

        temperatureCard.snp.makeConstraints { make in
            make.top.equalTo(pressureCard.snp.bottom).offset(cardSpacing)
            make.leading.trailing.equalTo(pressureCard)
        }

        powerCard.snp.makeConstraints { make in
            make.top.equalTo(temperatureCard.snp.bottom).offset(cardSpacing)
            make.leading.trailing.equalTo(pressureCard)
        }

        lengthCard.snp.makeConstraints { make in
            make.top.equalTo(powerCard.snp.bottom).offset(cardSpacing)
            make.leading.trailing.equalTo(pressureCard)
        }

        spaceCard.snp.makeConstraints { make in
            make.top.equalTo(lengthCard.snp.bottom).offset(cardSpacing)
            make.leading.trailing.equalTo(pressureCard)
        }

        liquidCard.snp.makeConstraints { make in
            make.top.equalTo(spaceCard.snp.bottom).offset(cardSpacing)
            make.leading.trailing.equalTo(pressureCard)
            make.bottom.equalToSuperview().offset(-cardSpacing)
        }
    }

    // MARK: - Setup Fields

    private func setupPressureFields() {
        let stack = createFieldsStackView()
        pressureCard.addSubview(stack)

        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(80)
        }

        stack.addArrangedSubview(createFieldContainer(label: "bar", textField: ftBar))
        stack.addArrangedSubview(createFieldContainer(label: "MPa", textField: ftMPa))
        stack.addArrangedSubview(createFieldContainer(label: "psi", textField: ftPsi))
    }

    private func setupTemperatureFields() {
        let stack = createFieldsStackView()
        temperatureCard.addSubview(stack)

        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(80)
        }

        stack.addArrangedSubview(createFieldContainer(label: "°C", textField: ftCelsius))
        stack.addArrangedSubview(createFieldContainer(label: "°F", textField: ftFahren))
        stack.addArrangedSubview(createFieldContainer(label: "K", textField: ftKelvin))
    }

    private func setupPowerFields() {
        let stack = createFieldsStackView()
        powerCard.addSubview(stack)

        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(80)
        }

        stack.addArrangedSubview(createFieldContainer(label: "kW", textField: ftKW))
        stack.addArrangedSubview(createFieldContainer(label: "kcal/h", textField: ftKcal))
        stack.addArrangedSubview(createFieldContainer(label: "PS", textField: ftPS))
    }

    private func setupLengthFields() {
        let stack = createFieldsStackView()
        lengthCard.addSubview(stack)

        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(80)
        }

        stack.addArrangedSubview(createFieldContainer(label: "mm", textField: ftMM))
        stack.addArrangedSubview(createFieldContainer(label: "inch", textField: ftInch))
        stack.addArrangedSubview(createFieldContainer(label: "ft", textField: ftFT))
    }

    private func setupSpaceFields() {
        let stack = createFieldsStackView()
        spaceCard.addSubview(stack)

        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(80)
        }

        stack.addArrangedSubview(createFieldContainer(label: "cm³", textField: ftcm))
        stack.addArrangedSubview(createFieldContainer(label: "inch³", textField: ftinch3))
        stack.addArrangedSubview(createFieldContainer(label: "ft³", textField: ftFT3))
    }

    private func setupLiquidFields() {
        let stack = createFieldsStackView()
        liquidCard.addSubview(stack)

        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(80)
        }

        stack.addArrangedSubview(createFieldContainer(label: "l", textField: ftLiter))
        stack.addArrangedSubview(createFieldContainer(label: "US gal", textField: ftLiqgal))
        stack.addArrangedSubview(createFieldContainer(label: "imp gal", textField: ftimp))
    }

    // MARK: - Factory Methods

    private func createSectionCard(icon: String, title: String, color: UIColor) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor.secondarySystemGroupedBackground
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 8
        card.layer.shadowOpacity = 0.1

        // Icon container with colored background
        let iconContainer = UIView()
        iconContainer.backgroundColor = color.withAlphaComponent(0.15)
        iconContainer.layer.cornerRadius = 12
        card.addSubview(iconContainer)

        iconContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(40)
        }

        // Icon
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconContainer.addSubview(iconView)

        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }

        // Title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        card.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconContainer.snp.trailing).offset(12)
            make.centerY.equalTo(iconContainer)
        }

        return card
    }

    private func createModernTextField(tag: Int, placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.tag = tag
        textField.placeholder = placeholder
        textField.borderStyle = .none
        textField.backgroundColor = UIColor.tertiarySystemGroupedBackground
        textField.layer.cornerRadius = 12
        textField.textAlignment = .center
        textField.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        textField.keyboardType = .numbersAndPunctuation
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        // Add subtle border
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.separator.withAlphaComponent(0.2).cgColor

        return textField
    }

    private func createFieldContainer(label: String, textField: UITextField) -> UIView {
        let container = UIView()

        let labelView = UILabel()
        labelView.text = label
        labelView.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        labelView.textAlignment = .center
        labelView.textColor = .secondaryLabel

        container.addSubview(labelView)
        container.addSubview(textField)

        labelView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }

        textField.snp.makeConstraints { make in
            make.top.equalTo(labelView.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(48)
        }

        return container
    }

    private func createFieldsStackView() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        return stack
    }

    // MARK: - Animations

    private func animateCardsOnAppear() {
        let cards = [pressureCard, temperatureCard, powerCard, lengthCard, spaceCard, liquidCard]

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

    // MARK: - Text Field Actions

    @objc private func textFieldDidChange(_ sender: UITextField) {
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        guard let text = sender.text, !text.isEmpty else {
            return
        }

        viewModel.inputs.convert(tag: sender.tag, value: text)
    }

    // MARK: - UI Updates

    private func updateTextFields(for tag: Int, with result: ConversionResult) {
        if let pressureUnit = PressureUnit(rawValue: tag) {
            updatePressureFields(for: pressureUnit, with: result)
        } else if let tempUnit = TemperatureUnit(rawValue: tag) {
            updateTemperatureFields(for: tempUnit, with: result)
        } else if let powerUnit = PowerUnit(rawValue: tag) {
            updatePowerFields(for: powerUnit, with: result)
        } else if let lengthUnit = LengthUnit(rawValue: tag) {
            updateLengthFields(for: lengthUnit, with: result)
        } else if let volumeUnit = VolumeUnit(rawValue: tag) {
            updateVolumeFields(for: volumeUnit, with: result)
        } else if let liquidVolumeUnit = LiquidVolumeUnit(rawValue: tag) {
            updateLiquidVolumeFields(for: liquidVolumeUnit, with: result)
        }
    }

    private func updatePressureFields(for unit: PressureUnit, with result: ConversionResult) {
        switch unit {
        case .bar:
            ftMPa.text = result.firstConvertion
            ftPsi.text = result.secondConvertion
        case .mpa:
            ftBar.text = result.firstConvertion
            ftPsi.text = result.secondConvertion
        case .psi:
            ftMPa.text = result.firstConvertion
            ftBar.text = result.secondConvertion
        }
    }

    private func updateTemperatureFields(for unit: TemperatureUnit, with result: ConversionResult) {
        switch unit {
        case .celsius:
            ftFahren.text = result.firstConvertion
            ftKelvin.text = result.secondConvertion
        case .fahrenheit:
            ftCelsius.text = result.firstConvertion
            ftKelvin.text = result.secondConvertion
        case .kelvin:
            ftCelsius.text = result.firstConvertion
            ftFahren.text = result.secondConvertion
        }
    }

    private func updatePowerFields(for unit: PowerUnit, with result: ConversionResult) {
        switch unit {
        case .kilowatt:
            ftKcal.text = result.firstConvertion
            ftPS.text = result.secondConvertion
        case .kilocaloriePerHour:
            ftKW.text = result.firstConvertion
            ftPS.text = result.secondConvertion
        case .horsepower:
            ftKW.text = result.firstConvertion
            ftKcal.text = result.secondConvertion
        }
    }

    private func updateLengthFields(for unit: LengthUnit, with result: ConversionResult) {
        switch unit {
        case .millimeter:
            ftInch.text = result.firstConvertion
            ftFT.text = result.secondConvertion
        case .inch:
            ftMM.text = result.firstConvertion
            ftFT.text = result.secondConvertion
        case .feet:
            ftInch.text = result.firstConvertion
            ftMM.text = result.secondConvertion
        }
    }

    private func updateVolumeFields(for unit: VolumeUnit, with result: ConversionResult) {
        switch unit {
        case .cubicCentimeter:
            ftFT3.text = result.firstConvertion
            ftinch3.text = result.secondConvertion
        case .cubicFeet:
            ftinch3.text = result.firstConvertion
            ftcm.text = result.secondConvertion
        case .cubicInch:
            ftFT3.text = result.firstConvertion
            ftcm.text = result.secondConvertion
        }
    }

    private func updateLiquidVolumeFields(for unit: LiquidVolumeUnit, with result: ConversionResult) {
        switch unit {
        case .liter:
            ftLiqgal.text = result.firstConvertion
            ftimp.text = result.secondConvertion
        case .usGallon:
            ftLiter.text = result.firstConvertion
            ftimp.text = result.secondConvertion
        case .imperialGallon:
            ftLiter.text = result.firstConvertion
            ftLiqgal.text = result.secondConvertion
        }
    }

    // MARK: - Modern Alert

    private func showModernAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: .ok), style: .default))
        present(alert, animated: true)
    }
} // swiftlint:disable:this file_length
