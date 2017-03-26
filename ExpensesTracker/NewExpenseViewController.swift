//
//  ExpenseViewController.swift
//  ExpensesTracker
//
//  Created by Max Medvedev on 08/01/2017.
//  Copyright © 2017 medvedev. All rights reserved.
//

import UIKit

class NewExpenseViewController: UIViewController {
    @IBOutlet weak var saveButton: UIBarButtonItem!

    @IBOutlet weak var expenseTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var descriptionTextField: UITextField!

    var kind: Int!

    private var expense: Expense?

    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view.

        expenseTextField.becomeFirstResponder()

    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func save(_ sender: Any) {

    }

    func setKind(_ kind: Int) {
        self.kind = kind
    }
}
