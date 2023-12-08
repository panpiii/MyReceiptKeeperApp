//
//  AddExpenseView.swift
//  MyReceiptKeeper
//
//  Created by Teresa Pan on 2023-10-31.
//

import SwiftUI
import CoreData

struct AddExpenseView: View {
    @Binding var amount: String
    @Binding var receiptImage: UIImage?
    @State private var showImagePicker: Bool = false
    @State private var useCamera: Bool = false
    @State private var category: String = ""
    @State private var date: Date = Date()
    @State private var description: String = ""
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            Form {
                amountSection
                receiptImageSection
                categorySection
                dateSection
                memoSection
                okButton
            }
            .navigationTitle("Add New Expense")
            .onTapGesture {
                hideKeyboard()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private var amountSection: some View {
        Section(header: Text("Amount")) {
            TextField("Enter amount", text: $amount)
                .keyboardType(.decimalPad)
                .onChange(of: amount) { newValue in
                    print("Amount entered: \(newValue)")
                }
        }
    }

    private var receiptImageSection: some View {
        Section(header: Text("Receipt Image")) {
            if let image = receiptImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                takePictureButton
            }
        }
    }

    private var takePictureButton: some View {
        Button(action: {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.useCamera = true
                self.showImagePicker = true
            } else {
                self.alertTitle = "Camera Unavailable"
                self.alertMessage = "This device does not support camera functionality."
                self.showAlert = true
            }
        }) {
            Text("Take Picture")
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: self.$receiptImage, sourceType: self.useCamera ? .camera : .photoLibrary)
        }
    }

    private var categorySection: some View {
        Section(header: Text("Category")) {
            Picker("Select a category", selection: $category) {
                ForEach(["Grocery", "Eating Out", "Entertainment", "Transportation", "Electric & Hydro", "Gas", "Communications", "Shopping", "Medical", "Other"], id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .onChange(of: category) { newValue in
                print("Category selected: \(newValue)")
            }
        }
    }

    private var dateSection: some View {
        Section(header: Text("Date")) {
            DatePicker("Date", selection: $date, displayedComponents: .date)
        }
    }

    private var memoSection: some View {
        Section(header: Text("Description")) {
            TextField("Add a description...", text: $description)
        }
    }

    private var okButton: some View {
        Button("OK") {
            print("OK button pressed")
            uploadReceiptImage()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(10)
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func uploadReceiptImage() {
        // Save the expense data using Core Data
        let newExpense = ExpenseRecord(context: viewContext)
        newExpense.id = UUID()
        newExpense.amount = Double(amount) ?? 0.0
        newExpense.category = category
        newExpense.date = date
        newExpense.expensedescription = description

        // Only save image data if an image is present
        if let imageData = receiptImage?.jpegData(compressionQuality: 0.8) {
            let newReceiptImage = ReceiptImageData(context: viewContext)
            newReceiptImage.id = UUID()
            newReceiptImage.imageData = imageData
            newReceiptImage.expense = newExpense  // Relationship name 'expense'
        }

        do {
            try viewContext.save()
            alertTitle = "Success"
            alertMessage = "Expense added successfully"
            showAlert = true
            resetForm()
        } catch {
            alertTitle = "Error"
            alertMessage = "Error saving expense: \(error.localizedDescription)"
            showAlert = true
        }
    }


    private func resetForm() {
        amount = ""
        category = ""
        date = Date()
        description = ""
        receiptImage = nil
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        AddExpenseView(amount: .constant("100.00"), receiptImage: .constant(UIImage(systemName: "photo")))
    }
}






