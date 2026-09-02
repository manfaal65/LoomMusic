//
//  YouTubeMusicWebView.swift
//  LoomMusic
//

import SwiftUI
import WebKit

struct YouTubeMusicWebView: NSViewRepresentable {
    // YouTube Music gates playback behind a user-agent sniff and rejects WKWebView's
    // default UA as "not optimised." WKWebView is a real WebKit engine (same family as
    // Safari), so identifying as desktop Safari passes that gate *and* gets served the
    // H.264/AAC-style streams WebKit's media pipeline can actually decode end-to-end.
    // (A Chrome UA passes the gate too, but YouTube then serves Chrome-preferred
    // VP9/Opus adaptive segments that WKWebView can't reliably decode past the first
    // segment or two — that's what caused playback to stall and spin mid-song.)
    private static let desktopSafariUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15"

    private static let bridgeMessageHandlerName = "loomPlayer"
    private static let searchThumbnailMessageHandlerName = "loomSearchThumbnail"

    // Best-effort bridge into YouTube Music's own player bar DOM. These selectors
    // (#play-pause-button, .next-button, .previous-button, ytmusic-player-bar's
    // .title/.byline/img) are undocumented and owned by YouTube — if a future YT
    // Music redesign renames them, the state bridge and transport controls will
    // silently stop updating/responding until the selectors are refreshed.
    private static let bridgeScript = """
    (function() {
        if (window.__loomBridgeInstalled) { return; }
        window.__loomBridgeInstalled = true;

        function postState() {
            var video = document.querySelector('video');
            var bar = document.querySelector('ytmusic-player-bar');
            var titleEl = bar ? bar.querySelector('.title') : null;
            var artistEl = bar ? bar.querySelector('.byline') : null;
            var imgEl = bar ? bar.querySelector('img') : null;
            try {
                window.webkit.messageHandlers.\(bridgeMessageHandlerName).postMessage({
                    isPlaying: video ? (!video.paused && !video.ended) : false,
                    currentTime: video ? video.currentTime : 0,
                    duration: (video && isFinite(video.duration)) ? video.duration : 0,
                    title: titleEl ? titleEl.textContent.trim() : '',
                    artist: artistEl ? artistEl.textContent.trim() : '',
                    artwork: (imgEl && imgEl.src) ? imgEl.src : ''
                });
            } catch (e) {}
        }

        function attachVideoListeners() {
            var video = document.querySelector('video');
            if (!video || video.__loomBound) { return; }
            video.__loomBound = true;
            ['play', 'pause', 'timeupdate', 'durationchange', 'ended', 'waiting', 'playing'].forEach(function(evt) {
                video.addEventListener(evt, postState);
            });
        }

        var observer = new MutationObserver(function() {
            attachVideoListeners();
            postState();
        });
        observer.observe(document.documentElement, { childList: true, subtree: true });

        attachVideoListeners();
        setInterval(postState, 1000);
    })();
    """

    // Scrapes the first result thumbnail off the search results page so Home's
    // "Recent" cards can show real artwork for a searched-but-not-yet-played query,
    // instead of a generic placeholder icon. Same undocumented-DOM caveat as above —
    // if YouTube Music's search result markup changes, this silently stops finding
    // an image and the placeholder is used instead (no crash, just no thumbnail).
    private static let searchThumbnailScript = """
    (function() {
        if (window.__loomThumbInstalled) { return; }
        window.__loomThumbInstalled = true;
        if (location.pathname.indexOf('/search') !== 0) { return; }

        var attempts = 0;
        var maxAttempts = 40;
        var timer = setInterval(function() {
            attempts++;
            var imgs = document.querySelectorAll(
                'ytmusic-responsive-list-item-renderer img, ytmusic-shelf-renderer img, ytmusic-card-shelf-renderer img, ytmusic-two-row-item-renderer img'
            );
            var found = null;
            for (var i = 0; i < imgs.length; i++) {
                var src = imgs[i].currentSrc || imgs[i].src;
                if (src && src.indexOf('http') === 0) {
                    found = src;
                    break;
                }
            }
            if (found) {
                clearInterval(timer);
                try {
                    window.webkit.messageHandlers.\(searchThumbnailMessageHandlerName).postMessage(found);
                } catch (e) {}
            } else if (attempts >= maxAttempts) {
                clearInterval(timer);
            }
        }, 500);
    })();
    """

    let request: YouTubeMusicRequest
    var onVideoOpened: (_ videoId: String, _ title: String) -> Void = { _, _ in }
    var onSearchThumbnail: (_ query: String, _ thumbnailURL: URL) -> Void = { _, _ in }

    func makeCoordinator() -> Coordinator {
        Coordinator(onVideoOpened: onVideoOpened, onSearchThumbnail: onSearchThumbnail)
    }

    func makeNSView(context: Context) -> WKWebView {
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: Self.bridgeMessageHandlerName)
        contentController.add(context.coordinator, name: Self.searchThumbnailMessageHandlerName)
        contentController.addUserScript(
            WKUserScript(source: Self.bridgeScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        )
        contentController.addUserScript(
            WKUserScript(source: Self.searchThumbnailScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        )

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.customUserAgent = Self.desktopSafariUserAgent
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: request.url))

        PlaybackController.shared.attach(webView)

        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        context.coordinator.onVideoOpened = onVideoOpened
        context.coordinator.onSearchThumbnail = onSearchThumbnail
        if context.coordinator.loadedRequest != request {
            context.coordinator.loadedRequest = request
            context.coordinator.lastVideoId = nil
            webView.load(URLRequest(url: request.url))
        }
    }

    static func dismantleNSView(_ webView: WKWebView, coordinator: Coordinator) {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: bridgeMessageHandlerName)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: searchThumbnailMessageHandlerName)
        PlaybackController.shared.detach(webView)
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var onVideoOpened: (_ videoId: String, _ title: String) -> Void
        var onSearchThumbnail: (_ query: String, _ thumbnailURL: URL) -> Void
        var loadedRequest: YouTubeMusicRequest?
        var lastVideoId: String?

        init(
            onVideoOpened: @escaping (_ videoId: String, _ title: String) -> Void,
            onSearchThumbnail: @escaping (_ query: String, _ thumbnailURL: URL) -> Void
        ) {
            self.onVideoOpened = onVideoOpened
            self.onSearchThumbnail = onSearchThumbnail
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

        // A long-running WebContent process (heavy JS SPA + continuous audio decode)
        // can be memory-jetsam-killed by the OS after playing for a while, which looks
        // like playback silently stopping and the page reloading. Recover automatically
        // instead of leaving the panel stuck.
        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            if let loadedRequest {
                webView.load(URLRequest(url: loadedRequest.url))
            }
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == YouTubeMusicWebView.searchThumbnailMessageHandlerName {
                guard let query = loadedRequest?.searchQuery,
                      let urlString = message.body as? String,
                      let url = URL(string: urlString) else { return }
                onSearchThumbnail(query, url)
                return
            }

            guard let body = message.body as? [String: Any] else { return }
            let isPlaying = body["isPlaying"] as? Bool ?? false
            let currentTime = body["currentTime"] as? Double ?? 0
            let duration = body["duration"] as? Double ?? 0
            let title = body["title"] as? String ?? ""
            let artist = body["artist"] as? String ?? ""
            let artworkURL = (body["artwork"] as? String).flatMap(URL.init(string:))

            PlaybackController.shared.updateFromBridge(
                isPlaying: isPlaying,
                currentTime: currentTime,
                duration: duration,
                title: title,
                artist: artist,
                artworkURL: artworkURL
            )
        }
    }
}
