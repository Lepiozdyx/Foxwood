
import SwiftUI

struct GameStatusBar: View {
    let timeRemaining: TimeInterval
    let score: Int
    let requiredNumber: Int
    var isTimer = true
    
    var body: some View {
        HStack(spacing: 4) {
            Spacer()
            
            if isTimer {
                GameMetricView(
                    value: String(format: "%.0f", timeRemaining)
                )
            }
            
            GameMetricView(
                value: "\(score)/\(requiredNumber)"
            )
        }
        .padding()
    }
}

struct GameMetricView: View {
    let value: String
    
    var body: some View {
        Image(.hexagon)
            .resizable()
            .frame(width: 120, height: 50)
            .overlay {
                Text(value)
                    .fontModifier(26)
            }
    }
}
