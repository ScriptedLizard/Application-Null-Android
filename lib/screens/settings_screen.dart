import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Real settings
  bool _hapticsEnabled = true;
  bool _soundsEnabled = false;

  // Fake settings (look real, do nothing)
  bool _cloudSync = false;
  bool _analytics = true;
  bool _autoUpdate = true;
  bool _reducedMotion = false;
  bool _experimentalFeatures = false;
  bool _nightMode = false;
  double _performanceLevel = 3;
  bool _backgroundRefresh = true;
  bool _notifications = false;
  bool _dataSaver = false;
  String _selectedRegion = 'Auto';
  bool _betaProgram = false;

  final List<String> _regions = ['Auto', 'US East', 'US West', 'EU Central', 'Asia Pacific', 'Void'];

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = themeProvider.currentTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surface,
        title: Text('Settings', style: TextStyle(color: theme.onBackground)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('Appearance', theme),
          _themeSelector(themeProvider, theme),
          const SizedBox(height: 8),
          _customThemeBuilder(themeProvider, theme),

          const SizedBox(height: 16),
          _sectionHeader('General', theme),
          _card([
            _switchTile('Haptic Feedback', 'Vibrate on interactions', _hapticsEnabled,
                (v) => setState(() => _hapticsEnabled = v), theme, real: true),
            _divider(theme),
            _switchTile('Sounds', 'Play UI sounds', _soundsEnabled,
                (v) => setState(() => _soundsEnabled = v), theme, real: true),
            _divider(theme),
            _switchTile('Background Refresh', 'Refresh content in background', _backgroundRefresh,
                (v) => setState(() => _backgroundRefresh = v), theme),
            _divider(theme),
            _switchTile('Notifications', 'Get notified about nothing', _notifications,
                (v) => setState(() => _notifications = v), theme),
          ], theme),

          const SizedBox(height: 16),
          _sectionHeader('Sync & Data', theme),
          _card([
            _switchTile('Cloud Sync', 'Sync your nothing to the cloud', _cloudSync,
                (v) => setState(() => _cloudSync = v), theme),
            _divider(theme),
            _switchTile('Analytics', 'Help us improve (we won\'t)', _analytics,
                (v) => setState(() => _analytics = v), theme),
            _divider(theme),
            _switchTile('Data Saver', 'Use less data doing nothing', _dataSaver,
                (v) => setState(() => _dataSaver = v), theme),
            _divider(theme),
            _dropdownTile('Region', _selectedRegion, _regions,
                (v) => setState(() => _selectedRegion = v!), theme),
          ], theme),

          const SizedBox(height: 16),
          _sectionHeader('Advanced', theme),
          _card([
            _switchTile('Reduced Motion', 'Less animations', _reducedMotion,
                (v) => setState(() => _reducedMotion = v), theme),
            _divider(theme),
            _switchTile('Auto Update', 'Keep app updated automatically', _autoUpdate,
                (v) => setState(() => _autoUpdate = v), theme),
            _divider(theme),
            _sliderTile('Performance Level', _performanceLevel,
                (v) => setState(() => _performanceLevel = v), theme),
            _divider(theme),
            _switchTile('Night Mode', 'Optimize for night use', _nightMode,
                (v) => setState(() => _nightMode = v), theme),
            _divider(theme),
            _switchTile('Experimental Features', 'Enable features that don\'t exist', _experimentalFeatures,
                (v) => setState(() => _experimentalFeatures = v), theme),
            _divider(theme),
            _switchTile('Beta Program', 'Get early access to nothing', _betaProgram,
                (v) => setState(() => _betaProgram = v), theme),
          ], theme),

          const SizedBox(height: 16),
          _sectionHeader('About', theme),
          _card([
            ListTile(
              title: Text('Version', style: TextStyle(color: theme.onBackground)),
              trailing: Text('1.0.0 (null)', style: TextStyle(color: theme.onBackground.withOpacity(0.5))),
            ),
            _divider(theme),
            ListTile(
              title: Text('Build', style: TextStyle(color: theme.onBackground)),
              trailing: Text('0x00000000', style: TextStyle(color: theme.onBackground.withOpacity(0.5), fontFamily: 'monospace')),
            ),
            _divider(theme),
            ListTile(
              title: Text('Reset Everything', style: TextStyle(color: Colors.red.shade400)),
              trailing: Icon(Icons.chevron_right, color: theme.onBackground.withOpacity(0.3)),
              onTap: () => _showResetDialog(theme),
            ),
          ], theme),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _themeSelector(ThemeProvider provider, theme) {
    return Card(
      color: theme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Color Theme', style: TextStyle(color: theme.onBackground, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AppThemes.presets.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final t = AppThemes.presets[i];
                  final selected = !provider.useCustom && provider.selectedIndex == i;
                  return GestureDetector(
                    onTap: () => provider.selectPreset(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: t.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? theme.onBackground : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: selected
                            ? [BoxShadow(color: t.primary.withOpacity(0.5), blurRadius: 8)]
                            : null,
                      ),
                      child: selected
                          ? Icon(Icons.check, color: t.onPrimary, size: 20)
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 20,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AppThemes.presets.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final t = AppThemes.presets[i];
                  final selected = !provider.useCustom && provider.selectedIndex == i;
                  return SizedBox(
                    width: 48,
                    child: Text(
                      t.name,
                      style: TextStyle(
                        fontSize: 9,
                        color: selected
                            ? theme.primary
                            : theme.onBackground.withOpacity(0.4),
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customThemeBuilder(ThemeProvider provider, theme) {
    return Card(
      color: theme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Custom Theme', style: TextStyle(color: theme.onBackground, fontWeight: FontWeight.w500)),
                const Spacer(),
                if (provider.useCustom)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Active', style: TextStyle(color: theme.primary, fontSize: 11)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _colorRow('Primary', provider.customPrimary, (c) => provider.updateCustomColor(primary: c), theme),
            _colorRow('Background', provider.customBackground, (c) => provider.updateCustomColor(background: c), theme),
            _colorRow('Surface', provider.customSurface, (c) => provider.updateCustomColor(surface: c), theme),
            _colorRow('Text', provider.customOnBackground, (c) => provider.updateCustomColor(onBackground: c), theme),
            _colorRow('Accent', provider.customAccent, (c) => provider.updateCustomColor(accent: c), theme),
          ],
        ),
      ),
    );
  }

  Widget _colorRow(String label, Color color, ValueChanged<Color> onChanged, theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: theme.onBackground.withOpacity(0.7), fontSize: 14)),
          const Spacer(),
          GestureDetector(
            onTap: () => _pickColor(color, onChanged),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: theme.onBackground.withOpacity(0.2)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pickColor(Color initial, ValueChanged<Color> onChanged) {
    showDialog(
      context: context,
      builder: (_) {
        Color picked = initial;
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: initial,
              onColorChanged: (c) => picked = c,
              enableAlpha: false,
              labelTypes: const [],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                onChanged(picked);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _showResetDialog(theme) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Everything?'),
        content: const Text('This will reset all settings to their default nothing.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _cloudSync = false;
                _analytics = true;
                _autoUpdate = true;
                _reducedMotion = false;
                _experimentalFeatures = false;
                _nightMode = false;
                _performanceLevel = 3;
                _backgroundRefresh = true;
                _notifications = false;
                _dataSaver = false;
                _selectedRegion = 'Auto';
                _betaProgram = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Everything reset. Nothing changed.')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: theme.primary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _card(List<Widget> children, theme) {
    return Card(
      color: theme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }

  Widget _switchTile(String title, String sub, bool value, ValueChanged<bool> onChanged,
      theme, {bool real = false}) {
    return ListTile(
      title: Text(title, style: TextStyle(color: theme.onBackground)),
      subtitle: Text(
        real ? sub : sub,
        style: TextStyle(color: theme.onBackground.withOpacity(0.5), fontSize: 12),
      ),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _sliderTile(String title, double value, ValueChanged<double> onChanged, theme) {
    return ListTile(
      title: Text(title, style: TextStyle(color: theme.onBackground)),
      subtitle: Slider(
        value: value,
        min: 1,
        max: 5,
        divisions: 4,
        label: value.round().toString(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _dropdownTile(String title, String value, List<String> items,
      ValueChanged<String?> onChanged, theme) {
    return ListTile(
      title: Text(title, style: TextStyle(color: theme.onBackground)),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        dropdownColor: theme.surface,
        style: TextStyle(color: theme.onBackground),
        items: items.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _divider(theme) => Divider(
        height: 1,
        indent: 16,
        endIndent: 16,
        color: theme.onBackground.withOpacity(0.08),
      );
}
