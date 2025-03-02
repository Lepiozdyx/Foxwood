
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        Group {
            switch viewModel.appState {
            case .loading:
                LoadingView()
            case .initialWebView:
                if let url = viewModel.networkManager.checkedURL {
                    InitialWebView(url: url, networkManager: viewModel.networkManager)
                } else {
                    InitialWebView(url: NetworkManager.initial, networkManager: viewModel.networkManager)
                }
            case .onboarding:
                OnboardingView(isOnboardingCompleted: $viewModel.isOnboardingCompleted)
                    .transition(.opacity)
            case .navigationRoot:
                NavigationRootView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onChange(of: viewModel.isOnboardingCompleted) { completed in
            if completed {
                withAnimation {
                    viewModel.completeOnboarding()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
