//
//  Expense.swift
//  MyReceiptKeeper
//
//  Created by Teresa Pan on 2023-11-17.
//
import FirebaseDatabase
import FirebaseFirestore

struct Expense: Identifiable {
    var id: String // Firestore document ID
    var amount: Double
    var category: String
    var date: Date
    var description: String?
    var receiptImageID: String // ID of the associated receipt image

    init(id: String = UUID().uuidString, amount: Double, category: String, date: Date, description: String? = nil, receiptImageID: String) {
        self.id = id
        self.amount = amount
        self.category = category
        self.date = date
        self.description = description
        self.receiptImageID = receiptImageID
    }
}
