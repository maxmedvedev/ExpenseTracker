//
// Created by Max Medvedev on 19/02/2017.
// Copyright © 2017 medvedev. All rights reserved.
//

import UIKit

class NewKindCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!

    weak var viewController: ViewController!

    @IBAction func createNewKind(_ sender: UITextField) {
        guard let text = textField.text else {
            return
        }

        let count = viewController.kinds.count
        let newKind = ExpenseKind(name: text, index: count)

        viewController.kinds.append(newKind)

        let table = viewController.tableView!
        table.beginUpdates()
        table.insertRows(at: [IndexPath(row: count, section: 0)], with: .automatic)
        table.endUpdates()
        
        textField.text = ""
        textField.resignFirstResponder()
    }
}
