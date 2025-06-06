import WebKit
import SwiftUI

enum LoadingState: Equatable {
    case idle
    case loading(Double)
    case completed
    case failed(Error)
    case offline
    
    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.completed, .completed),
             (.offline, .offline):
            return true
        case (.loading(let lhsProgress), .loading(let rhsProgress)):
            return abs(lhsProgress - rhsProgress) < 0.001
        case (.failed(let lhsError), .failed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

final class WebViewModel: ObservableObject {
    @Published private(set) var state: LoadingState = .idle
    @Published var isLoadingVisible: Bool = true
    let url: URL
    private var webView: WKWebView?
    private var progressObservation: NSKeyValueObservation?
    
    init(url: URL) {
        self.url = url
    }
    
    func attachWebView(_ webView: WKWebView) {
        self.webView = webView
        webView.navigationDelegate = WebViewDelegate(owner: self)
        observeProgress(webView)
        loadContent()
    }
    
    private func observeProgress(_ webView: WKWebView) {
        progressObservation?.invalidate()
        progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            guard let self = self else { return }
            let progress = min(max(webView.estimatedProgress, 0), 1) // Ограничиваем прогресс от 0 до 1
            if progress < 1.0 {
                self.updateState(.loading(progress))
            } else {
                self.updateState(.completed)
            }
        }
    }
    
    func loadContent() {
        guard let webView = webView else { return }
        updateState(.loading(0))
        let request = URLRequest(url: url, timeoutInterval: 10)
        webView.load(request)
    }
    
    func setConnection(isOnline: Bool) {
        if isOnline {
            if case .offline = state {
                loadContent()
            }
        } else {
            updateState(.offline)
        }
    }
    
    func updateState(_ state: LoadingState) {
        DispatchQueue.main.async {
            self.state = state
            if state == .completed {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.isLoadingVisible = false
                }
            } else if case .loading = state {
                self.isLoadingVisible = true
            }
        }
    }
}

private class WebViewDelegate: NSObject, WKNavigationDelegate {
    weak var owner: WebViewModel?
    
    init(owner: WebViewModel) {
        self.owner = owner
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        owner?.updateState(.loading(0.0))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        owner?.updateState(.completed)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        owner?.updateState(.failed(error))
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        owner?.updateState(.failed(error))
    }
} 
