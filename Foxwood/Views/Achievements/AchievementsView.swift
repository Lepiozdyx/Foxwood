
import SwiftUI

struct AchievementsView: View {
    @StateObject private var viewModel = AchievementsViewModel()
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
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            let achievements = viewModel.achievements
                            ForEach(0..<achievements.count/2, id: \.self) { row in
                                HStack(spacing: 10) {
                                    ForEach(0..<2, id: \.self) { col in
                                        let index = row * 2 + col
                                        if index < achievements.count {
                                            AchievementItemView(
                                                achievement: achievements[index],
                                                viewModel: viewModel
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(
                        width: width / 1.3,
                        height: height / 1.4
                    )
                }
            }
        }
    }
}

struct AchievementItemView: View {
    let achievement: Achievement
    let viewModel: AchievementsViewModel
    
    var body: some View {
        let style = viewModel.achievementStyle(for: achievement)
        
        VStack {
            Image(achievement.type.image)
                .resizable()
                .frame(width: 140, height: 100)
                .opacity(style.opacity)
                .colorMultiply(style.color)
            
            Image(.greenUnderlay)
                .resizable()
                .frame(width: 130, height: 55)
                .overlay {
                    Text(achievement.progressText)
                        .fontModifier(12)
                }
        }
    }
}

#Preview {
    AchievementsView()
        .environmentObject(NavigationManager())
}
