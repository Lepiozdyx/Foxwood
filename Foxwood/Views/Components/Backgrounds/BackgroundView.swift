//
//  BackgroundView.swift
//  Foxwood
//
//  Created by Alex on 10.01.2025.
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
        Image(.bg)
            .resizable()
            .ignoresSafeArea()
    }
}

#Preview {
    BackgroundView()
}
