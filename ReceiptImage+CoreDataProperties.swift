//
//  ReceiptImage+CoreDataProperties.swift
//  MyReceiptKeeper
//
//  Created by Teresa Pan on 2023-11-27.
//
//

import Foundation
import CoreData


extension ReceiptImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReceiptImage> {
        return NSFetchRequest<ReceiptImage>(entityName: "ReceiptImage")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var imageData: Data?
    @NSManaged public var expense: Expense?

}

extension ReceiptImage : Identifiable {

}
