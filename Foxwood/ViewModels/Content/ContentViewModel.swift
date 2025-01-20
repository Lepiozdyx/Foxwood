
import Foundation

enum AppState {
    case loading
    case initialWebView
    case navigationRoot
}

@MainActor
final class ContentViewModel: ObservableObject {
    @Published private(set) var appState: AppState = .loading
    let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    func onAppear() {
        Task {
            if networkManager.checkedURL != nil {
                appState = .initialWebView
                return
            }
            
            do {
                if try await networkManager.checkInitialURL() {
                    appState = .initialWebView
                } else {
                    appState = .navigationRoot
                }
            } catch {
                appState = .navigationRoot
            }
        }
    }
}
