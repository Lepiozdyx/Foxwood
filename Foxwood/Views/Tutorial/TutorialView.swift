//
//  TutorialView.swift
//  Foxwood
//
//  Created by Alex on 10.01.2025.
//

import SwiftUI

struct TutorialView: View {
    @StateObject private var viewModel = TutorialViewModel()
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            ZStack {
                BackgroundView()
                
                BoardView(
                    width: width / 1.3,
                    height: height / 1.3
                )
                .overlay {
                    contentView
                        .padding(30)
                }
                .overlay(alignment: .bottom) {
                    HStack {
                        Button {
                            viewModel.moveToPreviousStep()
                        } label: {
                            Image(.arrowButton)
                                .resizable()
                                .frame(width: 80, height: 80)
                                .rotationEffect(.degrees(180))
                        }
                        .disabled(viewModel.tutorialState == .welcome)
                        .opacity(viewModel.tutorialState == .welcome ? 0 : 1)
                        
                        Spacer()
                        
                        Button {
                            viewModel.moveToNextStep()
                        } label: {
                            Image(.arrowButton)
                                .resizable()
                                .frame(width: 80, height: 80)
                        }
                        .disabled(viewModel.tutorialState == .tutorialEnd)
                        .opacity(viewModel.tutorialState == .tutorialEnd ? 0 : 1)
                    }
                }
            }
        }
    }
    
    // MARK: - subviews
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.tutorialState {
        case .welcome:
            welcomeView
        case .field:
            fieldView
        case .cages:
            cagesView
        case .resources:
            resourcesView
        case .tutorialEnd:
            tutorialEndView
        }
    }
    
    // MARK: welcomeView
    private var welcomeView: some View {
        VStack(spacing: 10) {
            Text("Welcome to the 'foxwood' forest!")
                .fontModifier(20)
            
            Text("Your goal is to gather resources to survive the night.")
                .fontModifier(18)
            
            HStack(spacing: 20) {
                Image(.wood)
                Image(.waterdrop)
                Image(.mushroom)
                Image(.berries)
            }
        }
    }
    
    // MARK: fieldView
    private var fieldView: some View {
        VStack(spacing: 10) {
            Text("Click on the game cells to open them to find resources that will allow you to survive the night in the woods")
                .fontModifier(18)
            
            Image(.miniboard)
                .resizable()
                .frame(width: 150, height: 150)
                .overlay {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 2, x: -3, y: 3)
                }
        }
    }
    
    // MARK: cagesView
    private var cagesView: some View {
        VStack(spacing: 10) {
            Text("Game cells with mini-games")
                .fontModifier(16)
            
            HStack(spacing: 10) {
                Image(.woodCube)
                Image(.waterCube)
                Image(.mushroomCube)
                Image(.berriesCube)
            }
            
            Text("Empty game cell - does not spend moves")
                .fontModifier(16)
            
            Image(.emptyCube)
            
            Text("game cell with a spider web is a trap, - 1 turn")
                .fontModifier(16)
            
            Image(.webCube)
        }
    }
    
    // MARK: resourcesView
    private var resourcesView: some View {
        VStack(spacing: 10) {
            Text("After you open a game cell with the resource, complete the mini-game to get it")
                .fontModifier(18)
            
            HStack {
                Image(.mushroomButton)
                Image(.berriesButton)
                Image(systemName: "checkmark")
                    .font(.system(size: 30))
                    .foregroundStyle(.green)
                    .shadow(color: .black, radius: 2, x: -3, y: 3)
            }
            
            HStack {
                Image(.poisonMushroomButton)
                Image(.bacteriaButton)
                Image(.bacteria2Button)
                Image(systemName: "xmark")
                    .font(.system(size: 30))
                    .foregroundStyle(.red)
                    .shadow(color: .black, radius: 2, x: -3, y: 3)
            }
        }
    }
    
    // MARK: tutorialEndView
    private var tutorialEndView: some View {
        VStack(spacing: 10) {
            Text("You have 10 moves before nightfall. Get your resources together. Good luck!")
                .fontModifier(20)
            
            Image(.board)
                .resizable()
                .frame(width: 120, height: 100)
                .overlay {
                    VStack(spacing: 4) {
                        Text("wood 0/2")
                            .fontModifier(12)
                        Text("Water 0/2")
                            .fontModifier(12)
                        Text("Food 0/2")
                            .fontModifier(12)
                    }
                }
        }
    }
}

#Preview {
    TutorialView()
}
