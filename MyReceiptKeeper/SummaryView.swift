//
//  SummaryView.swift
//  MyReceiptKeeper
//
//  Created by Teresa Pan on 2023-10-31.
//

import SwiftUI
import CoreData

struct SummaryView: View {
    @State private var expenseDataPoints: [ExpenseDataPoint] = []
    @State private var totalExpense: Double = 0.0
    @State private var expenses: [ExpenseRecord] = []
    @State private var monthYear: String = ""
    @Environment(\.managedObjectContext) private var viewContext

    var showFullSummary: Bool = false

    var body: some View {
        VStack {
            if showFullSummary {
                Text(monthYear)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("Total Expense: $\(totalExpense, specifier: "%.2f")")
                    .font(.title)

                legendView

                List(expenses, id: \.self) { expense in
                    NavigationLink(destination: ExpenseDetail(expense: expense)) {
                        VStack(alignment: .leading) {
                            Text("\(expense.date?.formatted(date: .abbreviated, time: .omitted) ?? "")")
                                .fontWeight(.bold)
                            Text("\(expense.category ?? "") - $\(expense.amount, specifier: "%.2f") \(expense.expensedescription ?? "")")
                        }
                    }
                }
            }

            donutChartView
        }
        .navigationBarTitle("Summary", displayMode: .inline)
        .onAppear {
            setCurrentMonthYear()
            fetchExpensesForMonth()
        }
    }

    private var donutChartView: some View {
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
    }

    private var legendView: some View {
        HStack {
            ForEach(expenseDataPoints) { dataPoint in
                HStack {
                    Rectangle()
                        .fill(dataPoint.color)
                        .frame(width: 20, height: 20)
                    Text("\(dataPoint.category): $\(dataPoint.amount, specifier: "%.2f")")
                }
            }
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
            self.expenses = fetchedExpenses
            calculateAnglesAndColors()
        } catch {
            print("Error fetching expenses: \(error)")
        }
    }

    private func calculateAnglesAndColors() {
        var startAngle = Angle(degrees: 0)
        let colors: [Color] = [.red, .green, .blue, .orange, .purple, .yellow] 

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

struct DonutSegmentShape: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var innerRadiusRatio: CGFloat = 0.5

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let innerRadius = radius * innerRadiusRatio

        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.addArc(center: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
        path.closeSubpath()

        return path
    }
}

struct ExpenseDataPoint: Identifiable {
    let id = UUID()
    var category: String
    var amount: Double
    var startAngle: Angle = .zero
    var endAngle: Angle = .zero
    var color: Color = .clear
}

// Preview code
struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView(showFullSummary: true)
    }
}






