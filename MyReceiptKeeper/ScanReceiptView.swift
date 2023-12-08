//
//  ScanReceiptView.swift
//  MyReceiptKeeper
//
//  Created by Teresa Pan on 2023-10-31.
//

import SwiftUI
import Vision

struct ScanReceiptView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showImagePicker: Bool = false
    @State private var uiImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var recognizedText: String = ""
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var isTotalAmountCorrect: Bool = false
    @State private var showAddExpenseView: Bool = false
    @State private var recognizedAmount: String = ""
    @State private var fullRecognizedText: String = ""
    @State private var debugText: String = "" // New state variable for debugging text

    var body: some View {
        VStack {
            Text("Remember: Take the photo in good lighting and ensure the background is clear.")
                .font(.caption)
                .foregroundColor(.gray)
                .padding()
            
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                
                HStack {
                    Button(sourceType == .camera ? "Retake" : "Choose Another Picture") {
                        self.showImagePicker = true
                    }
                    .padding()
                    
                    Button("Next") {
                        processImage(uiImage)
                    }
                    .padding()
                }
            } else {
                Button("Upload from Library") {
                    self.sourceType = .photoLibrary
                    self.showImagePicker = true
                }
                .padding()
                
                Button("Take Picture") {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        self.sourceType = .camera
                        self.showImagePicker = true
                    } else {
                        self.alertTitle = "Camera Unavailable"
                        self.alertMessage = "This device does not support camera functionality."
                        self.showAlert = true
                    }
                }
                .padding()
            }
        }
        .navigationBarTitle("Scan Receipt", displayMode: .inline)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: self.$uiImage, sourceType: self.sourceType)
        }
        .alert(isPresented: $showAlert) {
            createAlert()
        }
        .sheet(isPresented: $showAddExpenseView) {
            AddExpenseView(amount: $recognizedAmount, receiptImage: $uiImage)
        }
    }
    
    // Functions
    private func processImage(_ image: UIImage) {
        recognizeText(from: image) { totalAmount in
            if let totalAmount = totalAmount {
                self.recognizedText = totalAmount
                self.alertTitle = "Is the total amount \(totalAmount)?"
                self.alertMessage = ""
                self.isTotalAmountCorrect = true
                self.showAlert = true
            } else {
                self.fullRecognizedText = self.debugText // Store the full recognized text
                self.alertTitle = "Error"
                self.alertMessage = "Could not find the total amount."
                self.showAlert = true
            }
        }
    }

    private func createAlert() -> Alert {
        if isTotalAmountCorrect {
            return Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                primaryButton: .default(Text("Yes")) {
                    self.recognizedAmount = self.recognizedText
                    self.showAddExpenseView = true
                },
                secondaryButton: .cancel(Text("No")) {
                    // Show the full recognized text for debugging
                    self.alertTitle = "Recognized Text"
                    self.alertMessage = self.fullRecognizedText
                    self.showAlert = true
                }
            )
        } else {
            return Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    
    private func findHighestTotalAmount(in text: String) -> String? {
        let primaryKeywords = ["Total", "TOTAL", "total"]
        let secondaryKeywords = ["Subtotal", "SUBTOTAL", "subtotal", "Balance due", "BALANCE DUE"]
        let allKeywords = primaryKeywords + secondaryKeywords

        let currencySymbols = ["\\$", "CAD\\$", "CA\\$","CA"]
        let currencyPattern = "(\(currencySymbols.joined(separator: "|")))"
        let pattern = "(\(allKeywords.joined(separator: "|")))[\\s\\S]*?\(currencyPattern)?([0-9,]*\\.?[0-9]+)"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsString = text as NSString
        let results = regex?.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))

        let amounts = results?.compactMap { result -> (String, Double, NSRange)? in
            if result.numberOfRanges == 4 {
                let keyword = nsString.substring(with: result.range(at: 1))
                let numberString = nsString.substring(with: result.range(at: 3)).replacingOccurrences(of: ",", with: "")
                if let number = Double(numberString) {
                    return (keyword, number, result.range(at: 3))
                }
            }
            return nil
        }

        let filteredAmounts = amounts?.filter { keyword, amount, range in
            let precedingRange = NSRange(location: max(range.location - 100, 0), length: min(100, range.location))
            let followingRange = NSRange(location: range.location + range.length, length: min(100, nsString.length - (range.location + range.length)))
            let surroundingString = nsString.substring(with: precedingRange) + nsString.substring(with: followingRange)

            let tipPattern = "(Tip|TIP|tip|Suggested Gratuity|SUGGESTED GRATUITY|suggested gratuity)[\\s\\S]*?\\$?[0-9]+\\.?[0-9]*"

            if let _ = surroundingString.range(of: tipPattern, options: .regularExpression) {
                return false
            }

            return true
        }

        // Prioritize primary keywords
        if let highestPrimaryAmount = filteredAmounts?.filter({ primaryKeywords.contains($0.0) }).max(by: { $0.1 < $1.1 }) {
            return String(format: "%.2f", highestPrimaryAmount.1)
        }

        // If no primary keyword amounts, consider secondary keywords
        if let highestSecondaryAmount = filteredAmounts?.filter({ secondaryKeywords.contains($0.0) }).max(by: { $0.1 < $1.1 }) {
            return String(format: "%.2f", highestSecondaryAmount.1)
        }

        return nil
    }


    
    private func recognizeText(from image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                completion(nil)
                return
            }
            
            let recognizedStrings = observations.compactMap { observation in
                return observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            DispatchQueue.main.async {
                // Print the full recognized text to the console for debugging
                print("Debug Text: \(recognizedStrings)")

                self.fullRecognizedText = recognizedStrings // Update the full recognized text here
                let totalAmount = self.findHighestTotalAmount(in: recognizedStrings)
                completion(totalAmount)
            }
        }
        
        do {
            try requestHandler.perform([request])
        } catch {
            completion(nil)
        }
    }


      
    struct ScanReceiptView_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                ScanReceiptView()
            }
        }
    }
    
}



