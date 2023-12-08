//
//  MyReceiptKeeperApp.swift
//  MyReceiptKeeper
//
//  Created by Teresa Pan on 2023-10-31.
//

import SwiftUI

@main
struct MyReceiptKeeperApp: App {
    // Access the shared instance of PersistenceController
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
