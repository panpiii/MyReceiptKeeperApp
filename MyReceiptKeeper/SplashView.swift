//
//  SplashView.swift
//  MyReceiptKeeper
//
//  Created by Teresa Pan on 2023-10-31.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack {
                Text("MyReceiptKeeper")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Make your life easier")
                    .font(.subheadline)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}

