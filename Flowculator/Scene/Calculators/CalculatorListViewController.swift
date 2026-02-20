//
//  CalculatorListViewController.swift
//  Flowculator
//
//  Created by Xaver Lutz on 20.02.26.
//

import UIKit

class CalculatorListViewController: UITableViewController {

    // MARK: - Model

    private struct Calculator {
        let title: String
        let icon: String
        let color: UIColor
        let makeViewController: () -> UIViewController
    }

    private lazy var calculators: [Calculator] = [
        Calculator(
            title: String(localized: .unitConverter),
            icon: "arrow.left.arrow.right",
            color: .systemBlue,
            makeViewController: { ConverterViewController() }
        ),
        Calculator(
            title: String(localized: .hydraulicCylinder),
            icon: "cylinder",
            color: .systemOrange,
            makeViewController: { CylinderCalculatorViewController() }
        ),
        Calculator(
            title: String(localized: .hydraulicMotor),
            icon: "gear",
            color: .systemGreen,
            makeViewController: { MotorCalculatorViewController() }
        )
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Flowculator"
        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CalculatorCell")
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calculators.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalculatorCell", for: indexPath)
        let calculator = calculators[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = calculator.title
        content.image = UIImage(systemName: calculator.icon)
        content.imageProperties.tintColor = calculator.color
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let calculator = calculators[indexPath.row]
        let viewController = calculator.makeViewController()
        viewController.title = calculator.title
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension String {
    
}
