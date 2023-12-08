//
//  ContentView.swift
//  MyReceiptKeeper
//
//  Created by Teresa Pan on 2023-10-31.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var monthYear: String = ""
    @State private var totalExpense: Double = 0.0
    @State private var expenseDataPoints: [ExpenseDataPoint] = []
    @State private var showingAddExpenseView = false
    @State private var amount: String = ""
    @State private var receiptImage: UIImage? = nil
    @State private var showFullSummary = false

    var body: some View {
        NavigationView {
            VStack {
                Text(monthYear)
                    .font(.title)
                    .onAppear {
                        setCurrentMonthYear()
                        fetchExpensesForMonth()
                    }
                ZStack {
                    if !expenseDataPoints.isEmpty {
                        ForEach(expenseDataPoints) { dataPoint in
                            DonutSegmentShape(startAngle: dataPoint.startAngle, endAngle: dataPoint.endAngle)
                                .fill(dataPoint.color)
                        }
                    } else {
                        Text("Loading data...")
                    }
                }
                .frame(width: 300, height: 300)
                .padding()

                Text("Total Expense: $\(totalExpense, specifier: "%.2f")")
                    .font(.title2)

                NavigationLink(destination: ScanReceiptView()) {
                    Text("Scan Receipts")
                }
                .buttonStyle(.borderedProminent)

                NavigationLink(destination: AddExpenseView(amount: $amount, receiptImage: $receiptImage)) {
                    Text("Add Expense")
                }
                .buttonStyle(.borderedProminent)

                Button("Summary") {
                    showFullSummary = true
                }
                .padding()
                .frame(height: 40)
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .sheet(isPresented: $showFullSummary) {
                    SummaryView(showFullSummary: true)
                }
            }
            .navigationTitle("Home")
        }
    }

    private func setCurrentMonthYear() {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        monthYear = dateFormatter.string(from: currentDate)
    }

    private func fetchExpensesForMonth() {
        let request: NSFetchRequest<ExpenseRecord> = ExpenseRecord.fetchRequest()
       
        do {
            let fetchedExpenses = try viewContext.fetch(request)
            var newExpenseData: [String: Double] = [:]
            totalExpense = 0.0

            for expense in fetchedExpenses {
                totalExpense += expense.amount
                newExpenseData[expense.category ?? "", default: 0] += expense.amount
            }

            self.expenseDataPoints = newExpenseData.map { (category, amount) in
                ExpenseDataPoint(category: category, amount: amount)
            }
            calculateAnglesAndColors()
        } catch {
            print("Error fetching expenses: \(error)")
        }
    }

    private func calculateAnglesAndColors() {
        var startAngle = Angle(degrees: 0)
        let colors: [Color] = [.red, .green, .blue, .orange, .purple, .yellow] // Add more colors as needed

        for (index, _) in expenseDataPoints.enumerated() {
            let proportion = expenseDataPoints[index].amount / totalExpense
            let angle = proportion * 360.0
            let endAngle = startAngle + Angle(degrees: angle)

            expenseDataPoints[index].startAngle = startAngle
            expenseDataPoints[index].endAngle = endAngle
            expenseDataPoints[index].color = colors[index % colors.count]

            startAngle = endAngle
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




