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

    var expenses = [Expense]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        guard let loaded: [Expense] = loadExpenses() else { return }
        expenses.append(contentsOf: loaded)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }




    // MARK: - Navigation
    
    @IBAction func unwindToMainScene(sender: UIStoryboardSegue) {
    }

    private func saveExpenses() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(expenses, toFile: Expense.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Expenses successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save expenses...", log: OSLog.default, type: .error)
        }
    }

    private func loadExpenses() -> [Expense]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Expense.ArchiveURL.path) as? [Expense]
    }

}

