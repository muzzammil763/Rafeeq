import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_theme.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/widgets/cancel_button.dart';
import 'package:rafeeq/ui/common/app_info_dialog.dart';
import 'package:rafeeq/ui/widgets/rafeeq_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeveloperSharedPrefsScreen extends ConsumerStatefulWidget {
  const DeveloperSharedPrefsScreen({super.key});

  @override
  ConsumerState<DeveloperSharedPrefsScreen> createState() =>
      _DeveloperSharedPrefsScreenState();
}

class _DeveloperSharedPrefsScreenState
    extends ConsumerState<DeveloperSharedPrefsScreen> {
  Map<String, dynamic> _prefsData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final Map<String, dynamic> data = {};
    for (var key in keys) {
      data[key] = prefs.get(key);
    }
    setState(() {
      _prefsData = Map.fromEntries(
        data.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      );
      _isLoading = false;
    });
  }

  Future<void> _deletePref(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    _loadPrefs();
  }

  Future<void> _clearAllPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _loadPrefs();
  }

  void _showClearAllConfirmation(BuildContext context) {
    final theme = context.mainTheme;
    final colorScheme = Theme.of(context).colorScheme;
    AppInfoDialog.show(
      context,
      title: "Clear All Preferences",
      iconAsset: "assets/logo.svg",
      gradientColors: [theme.secondaryColor, theme.primaryColor],
      contentWidgets: [
        _buildConfirmationMessage(
          "Are you sure you want to delete all SharedPreferences? This will reset the app state and cannot be undone.",
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: CancelButton()),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _clearAllPrefs();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Delete All',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: colorScheme.secondary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showDeleteSingleConfirmation(BuildContext context, String key) {
    final theme = context.mainTheme;
    final palette = SettingsPalette.of(context);
    AppInfoDialog.show(
      context,
      title: "Delete Preference",
      iconAsset: "assets/logo.svg",
      gradientColors: [theme.secondaryColor, theme.primaryColor],
      contentWidgets: [
        _buildConfirmationMessage("Are you sure you want to delete '$key'?"),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: CancelButton()),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deletePref(key);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.accent,
                  foregroundColor: palette.card,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "Delete",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: palette.card,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildConfirmationMessage(String message) {
    final palette = SettingsPalette.of(context);
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: palette.title, height: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.mainTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final palette = SettingsPalette.of(context);

    return Scaffold(
      backgroundColor: theme.bgColor,
      appBar: RafeeqAppBar(
        title: 'Shared Preferences (${_prefsData.length})',
        palette: palette,
        showBackButton: true,
        actions: [
          IconButton(
            tooltip: "Clear All",
            onPressed: () => _showClearAllConfirmation(context),
            icon: Icon(CupertinoIcons.trash, size: 24),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _prefsData.isEmpty
          ? Center(
              child: Text(
                "No Shared Preferences found.",
                style: TextStyle(color: theme.textColor),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _prefsData.length,
              itemBuilder: (context, index) {
                final key = _prefsData.keys.elementAt(index);
                final value = _prefsData[key];

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: theme.bgColor, // Use app aesthetic
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.onSurface.withValues(alpha: 0.1),
                      width: 1,
                    ),
                    boxShadow: kSubtleBoxShadow,
                  ),
                  child: ListTile(
                    title: Text(
                      key,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.textColor,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      value.toString(),
                      style: TextStyle(
                        color: theme.textColor.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        CupertinoIcons.trash,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      onPressed: () =>
                          _showDeleteSingleConfirmation(context, key),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
