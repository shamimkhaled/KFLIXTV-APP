import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../providers/favorites_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PackageInfo? _info;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((i) => setState(() => _info = i));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: KColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 90,
            automaticallyImplyLeading: false,
            backgroundColor: KColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: KColors.brandGradient,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(children: [
                      const Icon(Icons.tune_rounded,
                          color: Colors.white, size: 24),
                      const SizedBox(width: 10),
                      Text('Settings',
                          style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Appearance ─────────────────────────────────────────
                _SectionLabel('APPEARANCE'),
                const SizedBox(height: 10),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(15, 14, 15, 10),
                        child: Text('Theme',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: KColors.textPrimary)),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                        child: Row(
                          children: [
                            _ThemeChip(
                                label: 'Dark',
                                selected: theme.themeMode == ThemeMode.dark,
                                onTap: () =>
                                    theme.setThemeMode(ThemeMode.dark)),
                            const SizedBox(width: 8),
                            _ThemeChip(
                                label: 'Light',
                                selected: theme.themeMode == ThemeMode.light,
                                onTap: () =>
                                    theme.setThemeMode(ThemeMode.light)),
                            const SizedBox(width: 8),
                            _ThemeChip(
                                label: 'System',
                                selected:
                                    theme.themeMode == ThemeMode.system,
                                onTap: () =>
                                    theme.setThemeMode(ThemeMode.system)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // ── Storage ────────────────────────────────────────────
                _SectionLabel('STORAGE'),
                const SizedBox(height: 10),
                _Card(
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.cleaning_services_rounded,
                        iconColor: KColors.secondary,
                        title: 'Clear Cache',
                        subtitle: 'WebView cache and local storage',
                        trailing: const SizedBox.shrink(),
                        onTap: () => _clearCache(context),
                        divider: true,
                      ),
                      _SettingsTile(
                        icon: Icons.delete_outline_rounded,
                        iconColor: KColors.offline,
                        title: 'Clear Favorites',
                        subtitle: 'Removes all saved portals',
                        trailing: const SizedBox.shrink(),
                        onTap: () => _clearFavorites(context),
                        divider: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // ── About ──────────────────────────────────────────────
                _SectionLabel('ABOUT'),
                const SizedBox(height: 10),
                _Card(
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        iconColor: KColors.primary,
                        title: 'About KFLIX TV',
                        subtitle: 'Description and credits',
                        trailing: const Icon(Icons.chevron_right_rounded,
                            color: KColors.navInactive, size: 20),
                        onTap: () => _showAbout(context),
                        divider: true,
                      ),
                      _SettingsTile(
                        icon: Icons.tag_rounded,
                        iconColor: KColors.textMuted,
                        title: 'App Version',
                        subtitle: _info == null
                            ? 'Loading…'
                            : '${_info!.version} (build ${_info!.buildNumber})',
                        trailing: const SizedBox.shrink(),
                        onTap: null,
                        divider: false,
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache(BuildContext context) async {
    await WebViewCookieManager().clearCookies();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared')),
      );
    }
  }

  Future<void> _clearFavorites(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: KColors.surface,
        title: const Text('Clear Favorites?',
            style: TextStyle(color: KColors.textPrimary)),
        content: const Text('This will remove all saved portals.',
            style: TextStyle(color: KColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                  backgroundColor: KColors.offline),
              child: const Text('Clear')),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<FavoritesProvider>().clearFavorites();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Favorites cleared')),
      );
    }
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'KFLIX TV',
      applicationVersion: _info?.version ?? '',
      applicationIcon: const Icon(Icons.live_tv_rounded,
          size: 40, color: KColors.primary),
      children: const [
        SizedBox(height: 12),
        Text(
          'KFLIX TV is a lightweight portal launcher that brings together '
          'ISP FTP servers, movie portals, and Live TV streams into a '
          'single, Netflix-style home screen.\n\n'
          'No backend, no accounts, no tracking — everything runs locally.',
          style: TextStyle(color: KColors.textSecondary),
        ),
      ],
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: KColors.textMuted,
            letterSpacing: 0.5));
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KColors.borderSubtle),
      ),
      child: child,
    );
  }
}

class _ThemeChip extends StatelessWidget {
  const _ThemeChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            gradient: selected
                ? const LinearGradient(colors: KColors.brandGradient)
                : null,
            color: selected ? null : KColors.surfaceHighest,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : KColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
    required this.divider,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: iconColor, size: 19),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: KColors.textPrimary)),
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 11, color: KColors.textMuted)),
                    ],
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
        if (divider)
          const Divider(height: 1, color: KColors.borderSubtle,
              indent: 15, endIndent: 15),
      ],
    );
  }
}
