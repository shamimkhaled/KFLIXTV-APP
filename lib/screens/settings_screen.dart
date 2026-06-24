import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../providers/favorites_provider.dart';
import '../providers/theme_provider.dart';

/// App settings: theme selection, cache/favorites management, and about info.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _packageInfo = info);
  }

  Future<void> _clearWebViewCache(BuildContext context) async {
    final controller = WebViewController();
    await controller.clearCache();
    await controller.clearLocalStorage();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('WebView cache cleared')),
    );
  }

  Future<void> _clearFavorites(BuildContext context) async {
    final favoritesProvider = context.read<FavoritesProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all favorites?'),
        content: const Text(
          'This will remove every portal from your Favorites list. This '
          'cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await favoritesProvider.clearFavorites();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Favorites cleared')),
      );
    }
  }

  void _showAbout(BuildContext context) {
    final version = _packageInfo?.version ?? '-';
    showAboutDialog(
      context: context,
      applicationName: 'KFLIX TV',
      applicationVersion: 'Version $version',
      applicationIcon: const Icon(Icons.live_tv_rounded, size: 40),
      children: const [
        SizedBox(height: 12),
        Text(
          'KFLIX TV is a lightweight portal launcher that brings together '
          'ISP FTP servers, movie portals, and Live TV streams into a '
          'single, Netflix-style home screen.\n\n'
          'No backend, no accounts, no tracking - everything runs locally '
          'on your device.',
        ),
        SizedBox(height: 12),
        Text('Built with Flutter.'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('Appearance'),
          RadioListTile<ThemeMode>(
            title: const Text('System default'),
            value: ThemeMode.system,
            groupValue: themeProvider.themeMode,
            onChanged: (mode) => themeProvider.setThemeMode(mode!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            value: ThemeMode.light,
            groupValue: themeProvider.themeMode,
            onChanged: (mode) => themeProvider.setThemeMode(mode!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            value: ThemeMode.dark,
            groupValue: themeProvider.themeMode,
            onChanged: (mode) => themeProvider.setThemeMode(mode!),
          ),
          const Divider(),
          const _SectionHeader('Storage'),
          ListTile(
            leading: const Icon(Icons.cleaning_services_rounded),
            title: const Text('Clear Cache'),
            subtitle: const Text('Clears WebView cache and local storage'),
            onTap: () => _clearWebViewCache(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded),
            title: const Text('Clear Favorites'),
            subtitle: const Text('Removes all saved favorite portals'),
            onTap: () => _clearFavorites(context),
          ),
          const Divider(),
          const _SectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('About KFLIX TV'),
            subtitle: const Text('Description and credits'),
            onTap: () => _showAbout(context),
          ),
          ListTile(
            leading: const Icon(Icons.tag_rounded),
            title: const Text('App Version'),
            subtitle: Text(_packageInfo == null
                ? 'Loading...'
                : '${_packageInfo!.version} (build ${_packageInfo!.buildNumber})'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
