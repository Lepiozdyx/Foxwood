
import SwiftUI

struct FoodGameView: View {
    @StateObject private var viewModel: FoodGameViewModel
    let onComplete: (Bool) -> Void
    
    init(onComplete: @escaping (Bool) -> Void) {
        self.onComplete = onComplete
        _viewModel = StateObject(wrappedValue: FoodGameViewModel { success in
            onComplete(success)
        })
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BackgroundView(name: .backgrWater)
                
                switch viewModel.gameState {
                case .countdown(let count):
                    CountdownView(count: count)
                case .playing:
                    FoodGamePlayView(
                        viewModel: viewModel,
                        geometry: geometry
                    )
                case .finished(let success):
                    GameOverView(
                        success: success,
                        onExit: { viewModel.completeGame() }
                    )
                default:
                    EmptyView()
                }
            }
            .onAppear {
                viewModel.updateLayout(
                    size: geometry.size,
                    safeArea: geometry.safeAreaInsets
                )
            }
            .onChange(of: geometry.size) { newSize in
                viewModel.updateLayout(
                    size: newSize,
                    safeArea: geometry.safeAreaInsets
                )
            }
            .onDisappear {
                viewModel.cleanup()
            }
        }
    }
}

// MARK: - Game Play View
struct FoodGamePlayView: View {
    @ObservedObject var viewModel: FoodGameViewModel
    let geometry: GeometryProxy
    
    var body: some View {
        ZStack {
            VStack {
                GameStatusBar(
                    timeRemaining: viewModel.timeRemaining,
                    score: viewModel.collectedFood,
                    requiredNumber: 10
                )
                Spacer()
            }
            
            FallingItemsView(
                items: viewModel.items,
                screenHeight: geometry.size.height,
                onTapItem: { viewModel.tapItem($0) }
            )
            
            if viewModel.isMissTap {
                MissTapOverlayView()
            }
        }
    }
}

// MARK: - Falling Items View
struct FallingItemsView: View {
    let items: [FoodItem]
    let screenHeight: CGFloat
    let onTapItem: (FoodItem) -> Void
    
    var body: some View {
        ForEach(items) { item in
            FallingFoodItemView(
                item: item,
                screenHeight: screenHeight,
                onTap: { onTapItem(item) }
            )
        }
    }
}

struct FallingFoodItemView: View {
    let item: FoodItem
    let screenHeight: CGFloat
    let onTap: () -> Void
    
    @State private var offset: CGFloat = 0
    
    var body: some View {
        Image(item.type.imageName)
            .resizable()
            .frame(width: FoodGameConstants.itemSize, height: FoodGameConstants.itemSize)
            .position(x: item.position.x, y: item.position.y + offset)
            .opacity(item.isEnabled ? 1 : 0)
            .onTapGesture {
                guard item.isEnabled else { return }
                onTap()
            }
            .onAppear {
                withAnimation(.linear(duration: FoodGameConstants.itemFallingDuration)) {
                    offset = screenHeight + FoodGameConstants.itemSize * 2
                }
            }
            .playSound()
    }
}

// MARK: - Penalty View
struct MissTapOverlayView: View {
    var body: some View {
        Color.red.opacity(0.2)
            .ignoresSafeArea()
            .transition(.opacity)
            .allowsHitTesting(false)
    }
}

#Preview {
    FoodGameView(onComplete: {_ in })
        .environmentObject(NavigationManager())
}
