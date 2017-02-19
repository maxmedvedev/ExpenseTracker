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

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var kindTableView: UITableView!
    
    var expenses = [Expense]()
    var kinds = [ExpenseKind]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        guard let loadedExpenses: [Expense] = loadExpenses() else {
            return
        }
        expenses.append(contentsOf: loadedExpenses)

        let loadedKinds: [ExpenseKind] = loadExpenseKinds() ?? ExpenseKind.getDefaultKinds()

        if (!loadedKinds.isEmpty) {
            kinds.append(contentsOf: loadedKinds)
        }

        updateExpenses()

        kindTableView.delegate = self
        kindTableView.dataSource = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    private func getTotal() -> String {
        return expenses.reduce(0) { result, expense in result + expense.value }.description
    }

    var pressCounter = 0

    // MARK: - Actions
    @IBAction func editTable(_ sender: UILongPressGestureRecognizer?) {
        if (sender?.state == .began) {
            kindTableView.setEditing(!kindTableView.isEditing, animated: true)
        }
    }
  
    // MARK: - Navigation

    @IBAction func unwindToMainScene(sender: UIStoryboardSegue) {
        if let c = sender.source as? NewExpenseViewController {

            let formatter = NumberFormatter()
            formatter.decimalSeparator = ","
            let text = c.expenseTextField.text!
            guard let value = formatter.number(from: text)?.doubleValue else {
                return
            }
            let date = c.datePicker.date
            let description = c.descriptionTextField.text ?? ""
            let kind = c.kind!
            let expense = Expense(value: value, date: date, kind: kind, description: description)
            expenses.append(expense)
            save()
            updateExpenses()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard let dest = (segue.destination as? UINavigationController)?.visibleViewController as? NewExpenseViewController else {
            return
        }
        guard let button = sender as? ExpenseKindButton else {
            return
        }

        dest.kind = button.kind
    }

    private func updateExpenses() {
        totalLabel.text = getTotal()
        let rows = max(0, kindTableView.numberOfRows(inSection: 0) - 1)
        for i in 0..<rows {
            (kindTableView.cellForRow(at: IndexPath(row: i, section: 0)) as? ExpenseKindCell)?.updateTotal(expenses)
        }
    }

    private func save() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(expenses, toFile: Expense.ArchiveURL.path) &&
                               NSKeyedArchiver.archiveRootObject(kinds, toFile: ExpenseKind.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Expenses successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save expenses...", log: OSLog.default, type: .error)
        }
    }

    private func loadExpenses() -> [Expense]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Expense.ArchiveURL.path) as? [Expense]
    }

    private func loadExpenseKinds() -> [ExpenseKind]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: ExpenseKind.ArchiveURL.path) as? [ExpenseKind]
    }

    @IBAction func clearExpenses(_ sender: Any) {
        expenses.removeAll()
        kinds.removeAll()
        kinds.append(contentsOf: ExpenseKind.getDefaultKinds())
        save()
        kindTableView.reloadData()
        updateExpenses()
    }

    // MARK: - table

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kinds.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == kinds.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewKindCell", for: indexPath) as? NewKindCell else {
                fatalError()
            }
            
            cell.viewController = self

            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseKindCell", for: indexPath) as? ExpenseKindCell else {
                fatalError()
            }

            cell.initData(kinds[indexPath.row], expenses)

            return cell
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != kinds.count
    }


    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            kinds.remove(at: indexPath.row)
            save()
            kindTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

}

