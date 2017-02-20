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

    @IBOutlet weak var totalLabel: MoneyLabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var clearButton: UIButton!    
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    
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

        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    private func getTotal() -> Double {
        return expenses.reduce(0) { result, expense in result + expense.value }
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
        totalLabel.setAmount(x: getTotal())
        let rows = kinds.count
        for i in 0..<rows {
            getExpenseKindCell(at: i)?.updateTotal(expenses)
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
        tableView.reloadData()
        updateExpenses()
    }

    // MARK: - table

    @IBAction func editTable(_ sender: UILongPressGestureRecognizer?) {
        if (sender?.state == .began) {
            let isEditing = !tableView.isEditing
            tableView.setEditing(isEditing, animated: true)
            tableView.beginUpdates()
            let paths = [IndexPath(row: kinds.count, section: 0)]
            if (isEditing) {
                tableView.insertRows(at: paths, with: .automatic)
            } else {
                tableView.deleteRows(at: paths, with: .automatic)
            }
            tableView.endUpdates()

            clearButton.isHidden = !isEditing
            for i in 0..<kinds.count {
                getExpenseKindCell(at:i)?.totalLabel.isHidden = isEditing
            }
        }
    }

    private func getCell(at i: Int)-> Any? {
        return tableView.cellForRow(at: IndexPath(row: i, section: 0))
    }

    private func getExpenseKindCell(at i: Int) -> ExpenseKindCell? {
        return getCell(at:i) as? ExpenseKindCell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.isEditing ? kinds.count + 1: kinds.count
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
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - keyboard
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func keyboardWillShow(_ notification: NSNotification) {
        guard let cell = getCell(at: kinds.count) as? NewKindCell,
              let info = notification.userInfo,
              let keyboardHeight = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
                else {
            return
        }

        let textField = cell.textField!
        let textFieldFrame = textField.frame
        let textFieldLowestPoint = self.view.convert(textFieldFrame.origin, from: textField).y + textFieldFrame.height
        let totalHeight = self.view.frame.height

        let diff = totalHeight - textFieldLowestPoint - keyboardHeight

        if (diff < 0) {
            self.view.frame.origin.y = diff-20
        }
    }

    func keyboardWillHide(_ sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
}

