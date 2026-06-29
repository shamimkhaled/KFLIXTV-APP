import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../models/portal.dart';
import '../providers/favorites_provider.dart';
import '../utils/app_theme.dart';

/// Full-screen immersive portal viewer.
///
/// The WebView fills the ENTIRE screen. A semi-transparent overlay toolbar
/// slides in on tap and auto-hides after 4 s — matching how media players
/// behave (Netflix, YouTube).
class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key, required this.portal});
  final Portal portal;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen>
    with SingleTickerProviderStateMixin {
  WebViewController? _controller;

  double _progress = 0;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _toolbarVisible = true;
  Timer? _hideTimer;

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
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      _controller = _buildController();
      _scheduleHide();
    }
  }

  WebViewController _buildController() {
    final c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(NavigationDelegate(
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
        onWebResourceError: (e) {
          if (!mounted) return;
          if (e.isForMainFrame == false) return;
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = e.description;
          });
        },
      ))
      ..loadRequest(Uri.parse(widget.portal.url));

    final platform = c.platform;
    if (platform is AndroidWebViewController) {
      platform.setMediaPlaybackRequiresUserGesture(false);
      platform.setMixedContentMode(MixedContentMode.alwaysAllow);
    }
    return c;
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    if (_useWebView) {
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    super.dispose();
  }

  void _toggleToolbar() {
    setState(() => _toolbarVisible = !_toolbarVisible);
    if (_toolbarVisible) _scheduleHide();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && !_isLoading) {
        setState(() => _toolbarVisible = false);
      }
    });
  }

  Future<void> _retry() async {
    setState(() {
      _hasError = false;
      _isLoading = true;
      _toolbarVisible = true;
    });
    _scheduleHide();
    await _controller?.reload();
  }

  Future<void> _openInBrowser() =>
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
    if (!_useWebView) {
      return _BrowserFallback(portal: widget.portal, onOpen: _openInBrowser);
    }

    final topPad = MediaQuery.of(context).padding.top;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final should = await _handleBack();
        if (should && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleToolbar,
          child: Stack(
            children: [
              // ── Full-screen WebView ───────────────────────────────────
              Positioned.fill(
                child: _hasError
                    ? _ErrorView(
                        portal: widget.portal,
                        message: _errorMessage,
                        onRetry: _retry,
                        onBrowser: _openInBrowser,
                      )
                    : WebViewWidget(controller: _controller!),
              ),

              // ── Loading overlay ───────────────────────────────────────
              if (_isLoading) ...[
                Positioned.fill(
                  child: Container(color: Colors.black54),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: KColors.primary,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.portal.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Loading…',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress bar at top
                Positioned(
                  top: topPad,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    value: _progress > 0 ? _progress : null,
                    minHeight: 3,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation(KColors.primary),
                  ),
                ),
              ],

              // ── Overlay toolbar (auto-hide) ───────────────────────────
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                top: _toolbarVisible ? 0 : -(topPad + 70),
                left: 0,
                right: 0,
                child: _OverlayToolbar(
                  portal: widget.portal,
                  topPad: topPad,
                  progress: _isLoading ? _progress : null,
                  onBack: () => _handleBack().then((pop) {
                    if (pop && context.mounted) Navigator.of(context).pop();
                  }),
                  onRefresh: () {
                    _controller?.reload();
                    _showToolbar();
                  },
                  onBrowser: _openInBrowser,
                ),
              ),

              // ── "Tap to show controls" hint ───────────────────────────
              if (!_toolbarVisible && !_isLoading && !_hasError)
                Positioned(
                  bottom: 24 + MediaQuery.of(context).padding.bottom,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _toolbarVisible ? 0 : 0.7,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Tap screen to show controls',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showToolbar() {
    setState(() => _toolbarVisible = true);
    _scheduleHide();
  }
}

// ─── Overlay toolbar ──────────────────────────────────────────────────────────

class _OverlayToolbar extends StatelessWidget {
  const _OverlayToolbar({
    required this.portal,
    required this.topPad,
    required this.progress,
    required this.onBack,
    required this.onRefresh,
    required this.onBrowser,
  });

  final Portal portal;
  final double topPad;
  final double? progress;
  final VoidCallback onBack;
  final VoidCallback onRefresh;
  final VoidCallback onBrowser;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.85),
            Colors.black.withValues(alpha: 0.0),
          ],
          stops: const [0.6, 1.0],
        ),
      ),
      padding: EdgeInsets.only(top: topPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 56,
            child: Row(
              children: [
                // Back
                _ToolbarBtn(
                    icon: Icons.arrow_back_rounded, onTap: onBack),
                const SizedBox(width: 6),
                // Title + URL
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        portal.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        portal.url,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Refresh
                _ToolbarBtn(
                    icon: Icons.refresh_rounded, onTap: onRefresh),
                // Open in browser
                _ToolbarBtn(
                    icon: Icons.open_in_browser_rounded, onTap: onBrowser),
                const SizedBox(width: 6),
              ],
            ),
          ),
          // Progress bar
          if (progress != null)
            LinearProgressIndicator(
              value: progress! > 0 ? progress : null,
              minHeight: 2,
              backgroundColor: Colors.transparent,
              valueColor:
                  const AlwaysStoppedAnimation(KColors.primary),
            ),
        ],
      ),
    );
  }
}

class _ToolbarBtn extends StatelessWidget {
  const _ToolbarBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon),
      iconSize: 22,
      color: Colors.white,
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ─── Error view (full-screen) ─────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.portal,
    required this.message,
    required this.onRetry,
    required this.onBrowser,
  });

  final Portal portal;
  final String? message;
  final VoidCallback onRetry;
  final VoidCallback onBrowser;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.wifi_off_rounded,
                    size: 40, color: Colors.redAccent),
              ),
              const SizedBox(height: 20),
              Text(
                "Can't load ${portal.name}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message ??
                    'The portal may be offline or unreachable on your network.',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                    height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                    backgroundColor: KColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onBrowser,
                  icon: const Icon(Icons.open_in_browser_rounded),
                  label: const Text('Open in Browser'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Web / Windows fallback ───────────────────────────────────────────────────

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
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    isWeb ? Icons.public_rounded : Icons.laptop_rounded,
                    size: 44,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  portal.name,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  isWeb
                      ? 'Embedded preview is blocked by your browser.\nOpen the portal directly in a new tab.'
                      : 'Portals open in your default browser on Windows.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(portal.url,
                    style: TextStyle(fontSize: 11, color: cs.primary),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.open_in_browser_rounded),
                    label: Text(isWeb ? 'Open in New Tab' : 'Open in Browser'),
                    onPressed: onOpen,
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
