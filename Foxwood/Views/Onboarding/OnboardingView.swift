
import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var isOnboardingCompleted: Bool
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            ZStack {
                BackgroundView()
                
                VStack {
                    Spacer()
                    
                    // Content container
                    BoardView(width: width * 0.8, height: height * 0.5)
                        .overlay(
                            Text(titleForCurrentState)
                                .fontModifier(24)
                                .frame(width: width * 0.7)
                                .padding(.bottom)
                       )
                        .overlay(alignment: .bottom) {
                            Button {
                                viewModel.moveToNextStep()
                            } label: {
                                ActionView(
                                    text: viewModel.buttonText,
                                    fontSize: 24,
                                    width: 220,
                                    height: 80
                                )
                            }
                        }
                    
                    Spacer()
                }
            }
        }
        .onChange(of: viewModel.currentState) { state in
            if state.isCompleted {
                isOnboardingCompleted = true
            }
        }
    }
    
    private var titleForCurrentState: String {
        switch viewModel.currentState {
        case .first:
            return "Welcome to Foxwood online!"
        case .second:
            return "Here you can be at one with nature"
        case .third:
            return "Immerse yourself in the atmosphere of coziness and entertainment"
        case .fourth:
            return "Play with us and discover a world of exciting adventures!"
        case .completed:
            return ""
        }
    }
}

#Preview {
    OnboardingView(isOnboardingCompleted: .constant(false))
}
