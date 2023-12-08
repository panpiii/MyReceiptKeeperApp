//
//  ExpenseRecord+CoreDataProperties.swift
//  MyReceiptKeeper
//
//  Created by Teresa Pan on 2023-11-28.
//
//

import Foundation
import CoreData


extension ExpenseRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExpenseRecord> {
        return NSFetchRequest<ExpenseRecord>(entityName: "ExpenseRecord")
    }

    @NSManaged public var amount: Double
    @NSManaged public var category: String?
    @NSManaged public var date: Date?
    @NSManaged public var expensedescription: String?
    @NSManaged public var id: UUID?
    @NSManaged public var receiptImage: ReceiptImageData?

}

extension ExpenseRecord : Identifiable {

}
