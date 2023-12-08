//
//  ReceiptImageData+CoreDataProperties.swift
//  MyReceiptKeeper
//
//  Created by Teresa Pan on 2023-11-28.
//
//

import Foundation
import CoreData


extension ReceiptImageData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReceiptImageData> {
        return NSFetchRequest<ReceiptImageData>(entityName: "ReceiptImageData")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var imageData: Data?
    @NSManaged public var expense: ExpenseRecord?

}

extension ReceiptImageData : Identifiable {

}
