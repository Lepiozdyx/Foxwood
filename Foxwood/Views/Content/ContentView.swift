
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
            case .navigationRoot:
                NavigationRootView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}

#Preview {
    ContentView()
}
