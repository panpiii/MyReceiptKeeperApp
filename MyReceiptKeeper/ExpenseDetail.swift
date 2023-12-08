//
//  ExpenseDetail.swift
//  MyReceiptKeeper
//
//  Created by Teresa Pan on 2023-11-28.
//

import SwiftUI

struct ExpenseDetail: View {
    var expense: ExpenseRecord

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // Access imageData using the 'receiptImage' relationship
                if let imageData = expense.receiptImage?.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                }else {
                    Text("No image available")
                }

                Text("Category: \(expense.category ?? "N/A")")
                    .font(.headline)

                Text("Amount: $\(expense.amount, specifier: "%.2f")")
                    .font(.headline)

                if let date = expense.date {
                    Text("Date: \(date.formatted(date: .abbreviated, time: .omitted))")
                        .font(.headline)
                }

                if let description = expense.expensedescription, !description.isEmpty {
                    Text("Description: \(description)")
                        .font(.headline)
                }
            }
            .padding()
        }
        .navigationTitle("Expense Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}


