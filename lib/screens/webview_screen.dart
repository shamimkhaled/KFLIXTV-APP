import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../models/portal.dart';
import '../providers/favorites_provider.dart';

/// Full-screen portal viewer.
///
/// • Android / Android TV → embedded WebView with JS, mixed-content, autoplay.
/// • Web / Windows         → url_launcher fallback (iframes blocked by CORS).
class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key, required this.portal});

  final Portal portal;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  // Only created on platforms that support WebView
  WebViewController? _controller;

  double _progress = 0;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  bool get _useWebView =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().addRecent(widget.portal.url);
    });

    if (_useWebView) {
      // Allow landscape so HTML5 video can go fullscreen
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      _controller = _buildController();
    }
  }

  WebViewController _buildController() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) {
            if (!mounted) return;
            setState(() => _progress = p / 100);
          },
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            if (error.isForMainFrame == false) return;
            setState(() {
              _isLoading = false;
              _hasError = true;
              _errorMessage = error.description;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.portal.url));

    final platform = controller.platform;
    if (platform is AndroidWebViewController) {
      platform.setMediaPlaybackRequiresUserGesture(false);
      platform.setMixedContentMode(MixedContentMode.alwaysAllow);
    }

    return controller;
  }

  @override
  void dispose() {
    if (_useWebView) {
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    super.dispose();
  }

  Future<void> _retry() async {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    await _controller?.reload();
  }

  Future<void> _openInBrowser() async =>
      launchUrl(Uri.parse(widget.portal.url),
          mode: LaunchMode.externalApplication);

  Future<bool> _handleBack() async {
    if (_controller != null && await _controller!.canGoBack()) {
      await _controller!.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // ── Web / Windows: no embedded WebView — launch in browser ─────────────
    if (!_useWebView) {
      return _BrowserFallback(
        portal: widget.portal,
        onOpen: _openInBrowser,
      );
    }

    // ── Android / iOS / macOS: embedded WebView ────────────────────────────
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _handleBack();
        if (shouldPop && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title:
              Text(widget.portal.name, overflow: TextOverflow.ellipsis),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
              onPressed: () => _controller?.reload(),
            ),
            IconButton(
              icon: const Icon(Icons.open_in_browser_rounded),
              tooltip: 'Open in Browser',
              onPressed: _openInBrowser,
            ),
          ],
          bottom: _isLoading
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(3),
                  child: LinearProgressIndicator(
                    value: _progress > 0 ? _progress : null,
                    minHeight: 3,
                  ),
                )
              : null,
        ),
        body: _hasError
            ? _ErrorFallback(
                portal: widget.portal,
                message: _errorMessage,
                onRetry: _retry,
                onOpenInBrowser: _openInBrowser,
              )
            : RefreshIndicator(
                onRefresh: () async => _controller?.reload(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          kToolbarHeight,
                      child: WebViewWidget(controller: _controller!),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ── Web / Windows fallback ────────────────────────────────────────────────────

class _BrowserFallback extends StatelessWidget {
  const _BrowserFallback({required this.portal, required this.onOpen});
  final Portal portal;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isWeb = kIsWeb;

    return Scaffold(
      appBar: AppBar(title: Text(portal.name)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isWeb ? Icons.public_rounded : Icons.laptop_rounded,
                size: 72,
                color: cs.primary,
              ),
              const SizedBox(height: 20),
              Text(
                portal.name,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                isWeb
                    ? 'Embedded preview is blocked by browser security (CORS).\nOpen the portal directly in a new tab.'
                    : 'Opening portals in a built-in player is not supported on Windows yet.\nLaunch in your default browser instead.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 6),
              Text(
                portal.url,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: cs.primary),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.open_in_browser_rounded),
                  label: Text(
                      isWeb ? 'Open in New Tab' : 'Open in Browser'),
                  onPressed: onOpen,
                  style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Android error fallback ────────────────────────────────────────────────────

class _ErrorFallback extends StatelessWidget {
  const _ErrorFallback({
    required this.portal,
    required this.message,
    required this.onRetry,
    required this.onOpenInBrowser,
  });

  final Portal portal;
  final String? message;
  final VoidCallback onRetry;
  final VoidCallback onOpenInBrowser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text("Couldn't load ${portal.name}",
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              message ??
                  'The portal may be offline or unreachable on your current network.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onOpenInBrowser,
                  icon: const Icon(Icons.open_in_browser_rounded),
                  label: const Text('Open in Browser'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
