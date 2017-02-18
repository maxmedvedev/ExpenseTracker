//
//  ViewController.swift
//  ExpensesTracker
//
//  Created by Max Medvedev on 23/12/2016.
//  Copyright © 2016 medvedev. All rights reserved.
//

import UIKit
import QuartzCore
import os.log

class ViewController: UIViewController {

    @IBOutlet weak var foodButton: UIButton!
    @IBOutlet weak var cafeButton: UIButton!
    @IBOutlet weak var sportsButton: UIButton!
    @IBOutlet weak var transportButton: UIButton!
    @IBOutlet weak var medicineButton: UIButton!

    @IBOutlet weak var totalLabel: UILabel!
    
    var expenses = [Expense]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        guard let loaded: [Expense] = loadExpenses() else {
            return
        }
        expenses.append(contentsOf: loaded)

        updateTotalLabel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    private func getTotal() -> String {
        return expenses.reduce(0) { result, expense in result + expense.value }.description
    }

    // MARK: - Navigation

    @IBAction func unwindToMainScene(sender: UIStoryboardSegue) {
        if let c = sender.source as? NewExpenseViewController {

            guard let value = Double(c.expenseTextField.text!) else {
                return
            }
            let date = c.datePicker.date
            let description = c.descriptionTextField.text ?? ""
            let kind = 0 //todo implement different kinds
            let expense = Expense(value: value, date: date, kind: kind, description: description)
            expenses.append(expense)
            saveExpenses()
            updateTotalLabel()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard let dest = (segue.destination as? UINavigationController)?.visibleViewController as? NewExpenseViewController else {
            return
        }
        guard let button = sender as? UIButton else {
            return
        }

        switch button {
        case foodButton: dest.setKind(ExpenseKind.food)
        case cafeButton: dest.setKind(ExpenseKind.cafe)
        case sportsButton: dest.setKind(ExpenseKind.sports)
        case transportButton: dest.setKind(ExpenseKind.transport)
        case medicineButton: dest.setKind(ExpenseKind.medicine)
        default: fatalError("unknown kind")
        }
    }

    private func updateTotalLabel() {
        totalLabel.text = getTotal()
    }

    private func saveExpenses() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(expenses, toFile: Expense.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Expenses successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save expenses...", log: OSLog.default, type: .error)
        }
    }

    private func loadExpenses() -> [Expense]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Expense.ArchiveURL.path) as? [Expense]
    }

    @IBAction func clearExpenses(_ sender: Any) {
        expenses.removeAll()
        saveExpenses()
        updateTotalLabel()
    }
}

