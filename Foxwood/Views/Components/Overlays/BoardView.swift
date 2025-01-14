//
//  BoardView.swift
//  Foxwood
//
//  Created by Alex on 10.01.2025.
//

import SwiftUI

struct BoardView: View {
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        Image(.board)
            .resizable()
            .frame(maxWidth: width, maxHeight: height)
            .padding()
    }
}

#Preview {
    BoardView(width: 350, height: 550)
}
