//
// Created by Max Medvedev on 18/02/2017.
// Copyright (c) 2017 medvedev. All rights reserved.
//

import Foundation

class ExpenseKind: NSObject, NSCoding {
    static let food = 0
    static let cafe = 1
    static let sports = 2
    static let transport = 3
    static let medicine = 4

    let name: String
    let index: Int

    init(name: String, index: Int) {
        self.name = name
        self.index = index
    }

    convenience required init?(coder: NSCoder) {
        let index = coder.decodeInteger(forKey: Keys.index)
        guard let name: String = coder.decodeObject(forKey: Keys.name) as? String else { return nil }

        self.init(name: name, index: index)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: Keys.name)
        aCoder.encode(index, forKey: Keys.index)
    }

    static func getDefaultKinds() -> [ExpenseKind] {
        return [ExpenseKind(name: "Food", index: 0),
                ExpenseKind(name: "Eating out", index: 1),
                ExpenseKind(name: "Sports", index: 2),
                ExpenseKind(name: "Car", index: 3),
                ExpenseKind(name: "Medicine", index: 4)
        ]
    }

    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("expenseKinds")

    private struct Keys {
        static let name = "name"
        static let index = "index"
    }
}
