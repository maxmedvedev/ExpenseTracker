//
// Created by Max Medvedev on 19/02/2017.
// Copyright (c) 2017 medvedev. All rights reserved.
//

import Foundation
import UIKit

class ExpenseKindCell: UITableViewCell {
    @IBOutlet weak var totalLabel: MoneyLabel!
    @IBOutlet weak var button: ExpenseKindButton!

    var kind: ExpenseKind!

    func initData(_ kind: ExpenseKind, _ expenses: [Expense]) {
        self.kind = kind
        button.setTitle(kind.name, for: .normal)
        button.kind = kind.index

        updateTotal(expenses)
    }

    func updateTotal(_ expenses: [Expense]) {
        let total = expenses.reduce(0) { result, expense in expense.kind == self.kind.index ? result + expense.value : result }
        totalLabel.setAmount(x: total)
    }
}

class ExpenseKindButton : UIButton {
    var kind: Int!
}
