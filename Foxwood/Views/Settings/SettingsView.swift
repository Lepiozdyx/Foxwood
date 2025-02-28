
import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject private var navigationManager: NavigationManager
    
    var body: some View {
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
            
            BoardView(width: 350, height: 350)
            
            VStack(spacing: 30) {
                HStack(spacing: 40) {
                    Image(.hexagon)
                        .resizable()
                        .frame(width: 160, height: 55)
                        .overlay {
                            Text("Effects")
                                .fontModifier(24)
                        }
                    
                    SwitchButtonView(isOn: viewModel.isHapticsOn) {
                        viewModel.toggleHaptics()
                    }
                }
                
                HStack(spacing: 40) {
                    Image(.hexagon)
                        .resizable()
                        .frame(width: 160, height: 55)
                        .overlay {
                            Text("Music")
                                .fontModifier(24)
                        }
                    
                    SwitchButtonView(isOn: viewModel.isMusicOn) {
                        viewModel.toggleMusic()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(NavigationManager())
}

// MARK: - SwitchButtonView
struct SwitchButtonView: View {
    let isOn: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(.circleButton)
                .resizable()
                .colorMultiply(isOn ? .white : .brown)
                .frame(width: 80, height: 80)
                .opacity(isOn ? 1 : 0.8)
        }
        .buttonStyle(.plain)
    }
}
