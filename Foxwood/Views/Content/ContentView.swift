//
//  ContentView.swift
//  Foxwood
//
//  Created by Alex on 10.01.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            NavigationRootView()
                .transition(.opacity)
        }
    }
}

#Preview {
    ContentView()
}
