//
//  YouTubeMusicWebView.swift
//  LoomMusic
//

import SwiftUI
import WebKit

struct YouTubeMusicWebView: NSViewRepresentable {
    // YouTube Music gates playback behind a user-agent sniff and rejects WKWebView's
    // default UA as "not optimised." Presenting as a current desktop Chrome build
    // (the browser YT Music itself points unsupported users to) satisfies that check.
    private static let desktopChromeUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"

    let request: YouTubeMusicRequest
    var onVideoOpened: (_ videoId: String, _ title: String) -> Void = { _, _ in }

    func makeCoordinator() -> Coordinator {
        Coordinator(onVideoOpened: onVideoOpened)
    }

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.customUserAgent = Self.desktopChromeUserAgent
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: request.url))
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        context.coordinator.onVideoOpened = onVideoOpened
        if context.coordinator.loadedRequest != request {
            context.coordinator.loadedRequest = request
            context.coordinator.lastVideoId = nil
            webView.load(URLRequest(url: request.url))
        }
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var onVideoOpened: (_ videoId: String, _ title: String) -> Void
        var loadedRequest: YouTubeMusicRequest?
        var lastVideoId: String?

        init(onVideoOpened: @escaping (_ videoId: String, _ title: String) -> Void) {
            self.onVideoOpened = onVideoOpened
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard let url = webView.url, url.path == "/watch" else { return }
            guard let videoId = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "v" })?.value else { return }
            guard videoId != lastVideoId else { return }
            lastVideoId = videoId

            webView.evaluateJavaScript("document.title") { [weak self] result, _ in
                let rawTitle = (result as? String) ?? videoId
                let title = rawTitle.replacingOccurrences(of: " - YouTube Music", with: "")
                self?.onVideoOpened(videoId, title)
            }
        }
    }
}
