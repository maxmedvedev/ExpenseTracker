//
//  Expense.swift
//  ExpensesTracker
//
//  Created by Max Medvedev on 28/01/2017.
//  Copyright © 2017 medvedev. All rights reserved.
//

import Foundation
import os.log

class Expense: NSObject, NSCoding {
    let value: Double
    let date: Date?
    let kind: Int
    let descr:String?

    init(value: Double, date: Date?, kind: Int, description: String?) {
        self.value = value
        self.date = date
        self.kind = kind
        self.descr = description
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(value, forKey: Keys.value)
        aCoder.encode(date, forKey: Keys.date)
        aCoder.encode(kind, forKey: Keys.kind)
        aCoder.encode(descr, forKey: Keys.descr)
    }
    
    required convenience init?(coder: NSCoder) {
        let value = coder.decodeDouble(forKey: Keys.value)
        let date = coder.decodeObject(forKey: Keys.date) as? Date
        let kind = coder.decodeInteger(forKey: Keys.kind)
        let description = coder.decodeObject(forKey: Keys.descr) as? String

        self.init(value:value, date: date, kind: kind, description: description)
    }

    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("expenses")
    
    private struct Keys {
        static let value = "value"
        static let date = "date"
        static let kind = "kind"
        static let descr = "descr"
    }
}
