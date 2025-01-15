//
//  FoodGameView.swift
//  Foxwood
//
//  Created by Alex on 14.01.2025.
//

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
                BackgroundView()
                
                switch viewModel.gameState {
                case .countdown(let count):
                    FoodGameCountdownView(count: count)
                case .playing:
                    FoodGamePlayView(
                        viewModel: viewModel,
                        geometry: geometry
                    )
                case .finished(let success):
                    FoodGameOverView(
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

// MARK: - Countdown View
struct FoodGameCountdownView: View {
    let count: Int
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
            VStack {
                Text("Get Ready!")
                    .fontModifier(30)
                Text("\(count)")
                    .fontModifier(40)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Game Play View
struct FoodGamePlayView: View {
    @ObservedObject var viewModel: FoodGameViewModel
    let geometry: GeometryProxy
    
    var body: some View {
        ZStack {
            VStack {
                GameStatusBarView(
                    timeRemaining: viewModel.timeRemaining,
                    collectedFood: viewModel.collectedFood
                )
                Spacer()
            }
            
            FallingItemsView(
                items: viewModel.items,
                screenHeight: geometry.size.height,
                onTapItem: { viewModel.tapItem($0) }
            )
            
            if viewModel.isPenalty {
                PenaltyOverlayView()
            }
        }
    }
}

// MARK: - Status Bar View
struct GameStatusBarView: View {
    let timeRemaining: TimeInterval
    let collectedFood: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Spacer()
            
            GameMetricView(
                value: String(format: "%.0f", timeRemaining)
            )
            
            GameMetricView(
                value: "\(collectedFood)/\(FoodGameConstants.requiredFoodCount)"
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
                // TODO: Add more complex animations
                withAnimation(.linear(duration: FoodGameConstants.itemFallingDuration)) {
                    offset = screenHeight + FoodGameConstants.itemSize * 2
                }
            }
            .playSound()
    }
}

// MARK: - Penalty View
struct PenaltyOverlayView: View {
    var body: some View {
        ZStack {
            Color.red.opacity(0.3)
                .ignoresSafeArea()
                .transition(.opacity)
                .allowsHitTesting(false)
            
            Text("You've been poisoned, wait five seconds")
                .fontModifier(26)
                .transition(.scale)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.ultraThinMaterial)
                )
        }
    }
}

// MARK: - Game Over View
struct FoodGameOverView: View {
    let success: Bool
    let onExit: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            BoardView(width: 400, height: 350)
                .overlay(alignment: .top) {
                    ZStack {
                        Image(.hexagon)
                            .resizable()
                            .frame(width: 130, height: 50)
                        
                        Text(success ?
                             "Win" :
                             "Loose"
                        )
                        .fontModifier(18)
                    }
                }
                .overlay {
                    VStack(spacing: 20) {
                        Text(success ?
                             "All right! You did it!" :
                             "You didn't get enough food"
                        )
                        .fontModifier(24)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        
                        Button {
                            onExit()
                        } label: {
                            ActionView(
                                text: "Back to board",
                                fontSize: 24,
                                width: 250,
                                height: 70
                            )
                        }
                    }
                }
                .padding()
        }
    }
}

#Preview {
    FoodGameView(onComplete: {_ in })
        .environmentObject(NavigationManager())
}
