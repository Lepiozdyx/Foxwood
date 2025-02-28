
import SwiftUI

struct TutorialView: View {
    @StateObject private var viewModel = TutorialViewModel()
    @EnvironmentObject private var navigationManager: NavigationManager
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            ZStack {
                BackgroundView()
                
                VStack {
                    HStack {
                        MenuActionButton(image: .backButton) {
                            navigationManager.navigateBack()
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .padding()
                
                BoardView(
                    width: width / 1.2,
                    height: height / 1.2
                )
                .overlay {
                    VStack {
                        ScrollViewWithPadding(
                            contentHeight: height,
                            boardSize: CGSize(width: width / 1.3, height: height / 1.5)
                        ) {
                            contentView
                                .padding(.bottom, 30)
                        }
                    }
                }
                .overlay(alignment: .bottom) {
                    // Navigation buttons
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
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - Content Views
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
            VStack(spacing: 40) {
                Text("Good luck and have fun!")
                    .fontModifier(24)
                Image(.logo)
                    .resizable()
                    .frame(width: 110, height: 120)
            }
        }
    }
    
    // MARK: - welcomeView
    private var welcomeView: some View {
        VStack(spacing: 30) {
            Text("Welcome to the “foxwood” forest!")
                .fontModifier(24)
            
            customDivider
            
            VStack(spacing: 20) {
                Text("In 'Classic game' your goal is to gather resources to survive the night.")
                    .fontModifier(18)
                
                HStack(spacing: 20) {
                    Image(.wood)
                    Image(.waterdrop)
                    Image(.mushroom)
                    Image(.berries)
                }
                
                customDivider
                
                Text("You have only 10 moves before nightfall. Get your resources together. Good luck!")
                    .fontModifier(18)
                
                Image(.greenUnderlay)
                    .resizable()
                    .frame(width: 160, height: 120)
                    .overlay {
                        VStack(spacing: 4) {
                            Text("wood 0/2")
                                .fontModifier(16)
                            Text("Water 0/2")
                                .fontModifier(16)
                            Text("Food 0/2")
                                .fontModifier(16)
                        }
                    }
                
                customDivider
                
                Text("Unlock achievements for the resources you get")
                    .fontModifier(18)
            }
        }
    }
    
    // MARK: - fieldView
    private var fieldView: some View {
        VStack(spacing: 30) {
            Text("Main game field")
                .fontModifier(24)
            
            customDivider
            
            VStack(spacing: 10) {
                Text("Click on the game cells to open them to find resources")
                    .fontModifier(18)
                
                Image(.miniboard)
                    .resizable()
                    .frame(width: 180, height: 180)
                    .overlay {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.white)
                            .shadow(color: .black, radius: 2, x: -3, y: 3)
                    }
                
                Image(.board2)
                    .resizable()
                    .frame(width: 180, height: 180)
            }
            .frame(maxHeight: 500)
            
            customDivider
            
            Text("Use landscape or portrait screen orientation while playing a mini-games")
                .fontModifier(18)
        }
    }
    
    // MARK: - cagesView
    private var cagesView: some View {
        VStack(spacing: 30) {
            Text("Game cells with mini-games.")
                .fontModifier(24)
            
            customDivider
            
            VStack(spacing: 10) {
                Text("You can't make your next move until you play.")
                    .fontModifier(18)
                
                HStack(spacing: 10) {
                    Image(.woodCube)
                    Image(.waterCube)
                    Image(.mushroomCube)
                    Image(.berriesCube)
                }
                
                customDivider
                
                Text("Empty game cell - does not spend moves. You may continue to make your next move")
                    .fontModifier(18)
                
                Image(.emptyCube)
                
                customDivider
                
                Text("game cell with a spider web is a trap, opening such a cell you lose 1 move")
                    .fontModifier(18)
                
                Image(.webCube)
            }
        }
    }
    
    // MARK: - resourcesView
    private var resourcesView: some View {
        VStack(spacing: 30) {
            Text("Mini-games")
                .fontModifier(24)
            
            customDivider
            
            VStack(spacing: 20) {
                Text("After you open a game cell with the resource, complete the mini-game to get it")
                    .fontModifier(18)
                
                customDivider
                
                VStack {
                    Text("- The game of getting food. \nYou need to catch resources by using taps. Time limit 30 seconds.")
                        .fontModifier(18)
                    
                    HStack {
                        Image(.mushroomButton)
                            .resizable()
                            .frame(width: 50, height: 50)
                        Image(.berriesButton)
                            .resizable()
                            .frame(width: 50, height: 50)
                        Image(systemName: "checkmark")
                            .font(.system(size: 30))
                            .foregroundStyle(.green)
                            .shadow(color: .black, radius: 2, x: -3, y: 3)
                    }
                    
                    HStack {
                        Image(.poisonMushroomButton)
                            .resizable()
                            .frame(width: 50, height: 50)
                        Image(.bacteriaButton)
                            .resizable()
                            .frame(width: 50, height: 50)
                        Image(.bacteria2Button)
                            .resizable()
                            .frame(width: 50, height: 50)
                        Image(systemName: "xmark")
                            .font(.system(size: 30))
                            .foregroundStyle(.red)
                            .shadow(color: .black, radius: 2, x: -3, y: 3)
                    }
                }
                .frame(height: 250, alignment: .top)
                
                customDivider
                
                VStack {
                    Text("- The game of getting water. \nControl a moving object by swiping on the screen to catch a drop of water. Time limit 30 seconds.")
                        .fontModifier(18)
                    
                    HStack(spacing: 20) {
                        Image(.waterdrop)
                            .resizable()
                            .frame(width: 30, height: 40)
                        
                        Circle()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.yellow)
                            .shadow(color: .black, radius: 2, x: 1, y: 1)
                            .overlay {
                                Image(systemName: "hand.draw.fill")
                                    .font(.system(size: 30))
                                    .foregroundStyle(.white)
                                    .shadow(color: .black, radius: 2, x: -1, y: 2)
                                    .offset(x: 15, y: 15)
                            }
                    }
                }
                .frame(height: 250, alignment: .top)
                
                customDivider
                
                VStack {
                    Text("- The game of getting wood. \nYour task is to make a series of five accurate hits in time by pressing the button. Watch the indicator, it must be in the “green” zone. There are three chances to miss! No time limits.")
                        .fontModifier(18)
                    
                    HStack(spacing: 20) {
                        Image(.scale)
                            .resizable()
                            .frame(width: 100, height: 20)
                        
                        Image(.circleButton)
                            .resizable()
                            .frame(width: 35, height: 35)
                    }
                }
                .frame(height: 300, alignment: .top)
            }
        }
    }
    
    // MARK: - customDivider
    private var customDivider: some View {
        Rectangle()
            .frame(width: .infinity, height: 1)
            .foregroundStyle(.white)
    }
}

// MARK: - Custom ScrollView with Padding
struct ScrollViewWithPadding<Content: View>: View {
    let contentHeight: CGFloat
    let content: Content
    let boardSize: CGSize

    init(contentHeight: CGFloat, boardSize: CGSize, @ViewBuilder content: () -> Content) {
        self.contentHeight = contentHeight
        self.boardSize = boardSize
        self.content = content()
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            content
                .padding(.top)
                .padding(.horizontal, 30)
        }
        .frame(
            width: boardSize.width,
            height: boardSize.height
        )
    }
}

#Preview {
    TutorialView()
        .environmentObject(NavigationManager())
}
