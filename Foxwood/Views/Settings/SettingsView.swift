
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
            
            BoardView(width: 450, height: 450)
            
            VStack(spacing: 30) {
                HStack(spacing: 40) {
                    Image(.greenUnderlay)
                        .resizable()
                        .frame(width: 160, height: 50)
                        .overlay {
                            Text("Effects")
                                .fontModifier(24)
                        }
                    
                    SwitchButtonView(isOn: viewModel.isHapticsOn) {
                        viewModel.toggleHaptics()
                    }
                }
                
                HStack(spacing: 40) {
                    Image(.greenUnderlay)
                        .resizable()
                        .frame(width: 160, height: 50)
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
                .frame(width: 80, height: 80)
                .opacity(isOn ? 1 : 0.8)
                .overlay {
                    Image(systemName: isOn ? "checkmark" : "xmark")
                        .foregroundStyle(isOn ? . white : .red.opacity(0.7))
                        .font(.system(size: 30))
                        .shadow(color: .black, radius: 2, x: 2, y: -1)
                }
        }
        .buttonStyle(.plain)
    }
}
