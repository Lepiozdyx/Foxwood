
import SwiftUI

struct WaterGameView: View {
    @StateObject private var viewModel: WaterGameViewModel
    
    init(onComplete: @escaping (Bool) -> Void) {
        _viewModel = StateObject(wrappedValue: WaterGameViewModel(onGameComplete: onComplete))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BackgroundView(name: .backgrFood)
                
                // Game Content
                switch viewModel.gameState {
                case .initial:
                    EmptyView()
                case .countdown(let count):
                    CountdownView(count: count)
                case .playing:
                    WaterGamePlayView(
                        viewModel: viewModel,
                        geometry: geometry
                    )
                case .finished(let success):
                    GameOverView(
                        success: success,
                        onExit: {
                            viewModel.completeGame()
                        }
                    )
                }
            }
            .onAppear {
                viewModel.updateLayout(
                    bounds: geometry.frame(in: .local),
                    safeArea: geometry.safeAreaInsets
                )
            }
            .onChange(of: geometry.size) { _ in
                viewModel.updateLayout(
                    bounds: geometry.frame(in: .local),
                    safeArea: geometry.safeAreaInsets
                )
            }
        }
        .navigationBarHidden(true)
        .onDisappear {
            viewModel.cleanup()
        }
    }
}

#Preview {
    WaterGameView(onComplete: {_ in })
        .environmentObject(NavigationManager())
}

// MARK: - WaterGamePlayView
struct WaterGamePlayView: View {
    @ObservedObject var viewModel: WaterGameViewModel
    let geometry: GeometryProxy
    
    var body: some View {
        ZStack {
            // Game Area
            GameAreaView(
                width: geometry.size.width,
                height: geometry.size.height - geometry.safeAreaInsets.top -
                WaterGameConstants.statusBarHeight - geometry.safeAreaInsets.bottom
            )
            
            // Status Bar
            VStack {
                GameStatusBar(
                    timeRemaining: viewModel.timeRemaining,
                    score: viewModel.score,
                    requiredNumber: WaterGameConstants.requiredDrops
                )
                
                Spacer()
            }
            
            // Game Elements
            ZStack {
                SnakeView(segments: viewModel.segments)
                WaterDropView(drop: viewModel.waterDrop)
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 30)
                .onChanged { gesture in
                    viewModel.handleDrag(
                        start: gesture.startLocation,
                        end: gesture.location
                    )
                }
        )
    }
}

// MARK: - Snake View
struct SnakeView: View {
    let segments: [SnakeSegment]
    
    var body: some View {
        ForEach(Array(segments.enumerated()), id: \.element.id) { index, segment in
            Circle()
                .foregroundStyle(index == 0 ? .orange : .blue.opacity(0.6))
                .shadow(color: .black, radius: 1)
                .overlay(
                    Circle()
                        .stroke(.black.opacity(0.5), lineWidth: 1)
                )
                .frame(
                    width: WaterGameConstants.snakeSize,
                    height: WaterGameConstants.snakeSize
                )
                .position(segment.position)
        }
    }
}

// MARK: - Water Drop View
struct WaterDropView: View {
    @State private var scale: CGFloat = 1.0
    @State private var rotation: CGFloat = 0
    
    let drop: WaterDrop
    
    var body: some View {
        Image(.waterdr)
            .resizable()
            .shadow(color: .white.opacity(0.6), radius: 2, x: 0, y: 1)
            .frame(width: WaterGameConstants.dropSize, height: WaterGameConstants.dropSize * 1.3)
            .position(drop.position)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true)
                ) {
                    scale = 0.9
                }

                withAnimation(
                    .easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: true)
                ) {
                    rotation = 2
                }
            }
            .onDisappear {
                scale = 0
                rotation = 0
            }
    }
}

// MARK: - Game Area View
struct GameAreaView: View {
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        Color.clear
            .frame(width: width, height: height)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.red.opacity(0.7),
                                Color.blue.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 4
                    )
            )
    }
}
