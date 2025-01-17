//
//  WaterGameView.swift
//  Foxwood
//
//  Created by Alex on 14.01.2025.
//

import SwiftUI

struct WaterGameView: View {
    @StateObject private var viewModel: WaterGameViewModel
    @EnvironmentObject private var navigationManager: NavigationManager
    
    init(onComplete: ((Bool) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: WaterGameViewModel(onGameComplete: onComplete))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BackgroundView()
                
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
                            navigationManager.navigateBack()
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
    WaterGameView()
        .environmentObject(NavigationManager())
}

// MARK: - WaterGamePlayView
struct WaterGamePlayView: View {
    @ObservedObject var viewModel: WaterGameViewModel
    let geometry: GeometryProxy
    
    var body: some View {
        ZStack {
            // Status Bar
            VStack {
                GameStatusBar(
                    timeRemaining: viewModel.timeRemaining,
                    score: viewModel.score,
                    requiredNumber: 5
                )
                
                Spacer()
            }
            
            // Game Area
            GameAreaView(
                width: geometry.size.width - geometry.safeAreaInsets.leading -
                       geometry.safeAreaInsets.trailing - WaterGameConstants.borderPadding * 2,
                height: geometry.size.height - geometry.safeAreaInsets.top -
                        geometry.safeAreaInsets.bottom - WaterGameConstants.statusBarHeight -
                        WaterGameConstants.borderPadding * 2
            )
            
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
        ForEach(segments) { segment in
            Circle()
                .foregroundStyle(.yellow)
                .shadow(color: .red, radius: 1)
                .overlay(Circle().stroke(.black, lineWidth: 1))
                .frame(width: WaterGameConstants.snakeSize, height: WaterGameConstants.snakeSize)
                .position(segment.position)
        }
    }
}

// MARK: - Water Drop View
struct WaterDropView: View {
    let drop: WaterDrop
    
    var body: some View {
        Image(.waterdrop)
            .resizable()
            .shadow(color: .black, radius: 1, x: 0.5, y: 0.5)
            .frame(width: WaterGameConstants.dropSize, height: WaterGameConstants.dropSize * 1.3)
            .position(drop.position)
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
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.red.opacity(0.5), lineWidth: 3)
            )
    }
}
