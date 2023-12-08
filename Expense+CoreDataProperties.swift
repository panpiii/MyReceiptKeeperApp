//
//  Expense+CoreDataProperties.swift
//  MyReceiptKeeper
//
//  Created by Teresa Pan on 2023-11-27.
//
//

import Foundation
import CoreData


extension Expense {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expense> {
        return NSFetchRequest<Expense>(entityName: "Expense")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var amount: Double
    @NSManaged public var category: String?
    @NSManaged public var date: Date?
    @NSManaged public var expensedescription: String?
    @NSManaged public var receiptImage: ReceiptImage?

}

extension Expense : Identifiable {

}
