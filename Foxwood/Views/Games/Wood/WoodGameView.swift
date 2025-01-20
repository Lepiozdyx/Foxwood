
import SwiftUI

struct WoodGameView: View {
    @StateObject private var viewModel: WoodGameViewModel
    
    init(onComplete: @escaping (Bool) -> Void) {
        _viewModel = StateObject(wrappedValue: WoodGameViewModel(onGameComplete: onComplete))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BackgroundView()
                
                switch viewModel.gameState {
                case .countdown(let count):
                    CountdownView(count: count)
                case .playing, .initial:
                    WoodGamePlayView(
                        viewModel: viewModel,
                        screenWidth: geometry.size.width,
                        safeArea: geometry.safeAreaInsets
                    )
                case .finished(let success):
                    GameOverView(
                        success: success,
                        onExit: { viewModel.completeGame() }
                    )
                }
            }
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
}

// MARK: - Game Play View
struct WoodGamePlayView: View {
    @ObservedObject var viewModel: WoodGameViewModel
    let screenWidth: CGFloat
    let safeArea: EdgeInsets
    
    private var scaleWidth: CGFloat {
        screenWidth - safeArea.leading - safeArea.trailing - 32
    }
    
    var body: some View {
        ZStack {
            // Background Wood Image
            VStack {
                Spacer()
                woodImage
            }
            
            // Game UI
            VStack(spacing: 0) {
                // Status Bar
                GameStatusBar(
                    timeRemaining: 0,
                    score: viewModel.successCount,
                    requiredNumber: viewModel.requiredSuccessCount,
                    isTimer: false
                )
                
                Spacer()
                
                // Scale and Button Area
                VStack {
                    Spacer()
                    
                    scaleView
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        actionButton
                    }
                }
                .padding()
            }
        }
    }
    
    private var woodImage: some View {
        Image(.wood)
            .resizable()
            .frame(
                width: WoodGameConstants.woodImageSize.width,
                height: WoodGameConstants.woodImageSize.height
            )
            .shadow(color: .black, radius: 5, x: -3, y: 3)
            .scaleEffect(viewModel.shakeWood ? 0.95 : 1.0)
            .modifier(ShakeEffect(shaking: viewModel.shakeWood))
            .animation(.interpolatingSpring(stiffness: 500, damping: 5),
                      value: viewModel.shakeWood)
    }

    struct ShakeEffect: GeometryEffect {
        var amount: CGFloat = 5
        var shakesPerUnit = 2
        var shaking: Bool
        
        var animatableData: CGFloat {
            get { CGFloat(shaking ? 1 : 0) }
            set { }
        }

        func effectValue(size: CGSize) -> ProjectionTransform {
            guard shaking else { return ProjectionTransform(.identity) }
            
            let translation = amount * sin(animatableData * .pi * CGFloat(shakesPerUnit))
            return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
        }
    }
    
    private var scaleView: some View {
        ZStack {
            // Scale background
            Image(.scale)
                .resizable()
                .frame(width: scaleWidth, height: WoodGameConstants.scaleHeight)
            
            // Target zone
            Rectangle()
                .foregroundStyle(.green.opacity(0.1))
                .frame(
                    width: scaleWidth * WoodGameConstants.targetZoneWidth,
                    height: 20
                )
                .clipShape(.capsule)
            
            // Moving indicator
            Image(.indicator)
                .resizable()
                .frame(
                    width: WoodGameConstants.indicatorWidth,
                    height: WoodGameConstants.indicatorHeight
                )
                .colorMultiply(viewModel.indicatorColor)
                .shadow(
                    color: viewModel.lastHitSuccess == true ? .green :
                        viewModel.lastHitSuccess == false ? .red :
                            .green,
                    radius: 2
                )
                .offset(
                    x: (scaleWidth - WoodGameConstants.indicatorWidth) *
                       (viewModel.indicatorPosition.x - 0.5)
                )
        }
    }
    
    private var actionButton: some View {
        Button {
            viewModel.handleTap()
        } label: {
            Image(.circleButton)
                .resizable()
                .frame(
                    width: WoodGameConstants.buttonSize,
                    height: WoodGameConstants.buttonSize
                )
        }
        .playSound()
    }
}

#Preview {
    WoodGameView { _ in }
}
