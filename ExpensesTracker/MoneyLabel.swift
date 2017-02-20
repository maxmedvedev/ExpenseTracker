//
// Created by Max Medvedev on 20/02/2017.
// Copyright (c) 2017 medvedev. All rights reserved.
//

import UIKit

class MoneyLabel: UILabel {
    func setAmount(x: Double) {
        let price = NSNumber(value: x)

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency

        formatter.locale = Locale(identifier: "ru_RU")
        self.text = formatter.string(from: price) // $123"
    }
}
