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

        let newKind = ExpenseKind(name: text, index: findNewIndex(viewController.kinds))

        viewController.kinds.append(newKind)

        let table = viewController.tableView!
        table.beginUpdates()
        table.insertRows(at: [IndexPath(row: viewController.kinds.count, section: 0)], with: .automatic)
        table.endUpdates()

        textField.text = ""
        textField.resignFirstResponder()
    }

    private func findNewIndex(_ kinds: [ExpenseKind]) -> Int {
        var set = Set<Int>()
        kinds.forEach { set.insert($0.index) }

        var result = 0

        while true {
            if !set.contains(result) { return result }
            result += 1
        }
    }
}
