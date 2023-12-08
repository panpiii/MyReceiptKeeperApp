//
//  ReceiptImages.swift
//  MyReceiptKeeper
//
//  Created by Teresa Pan on 2023-11-17.
//

import Foundation
import FirebaseDatabase
import FirebaseFirestore

struct ReceiptImages: Identifiable {
    var id: String // Firestore document ID
    var imageURL: String

    init(id: String = UUID().uuidString, imageURL: String) {
        self.id = id
        self.imageURL = imageURL
    }
}

