import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _hapticsEnabled = true;
  bool _soundsEnabled = false;
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

  void _haptic() {
    if (_hapticsEnabled) HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = themeProvider.currentTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surface,
        title: Text('Settings',
            style: TextStyle(color: theme.onBackground, fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('Appearance', theme),
          _themeSelector(themeProvider, theme),
          const SizedBox(height: 8),
          _customThemeBuilder(themeProvider, theme),

          const SizedBox(height: 20),
          _sectionHeader('General', theme),
          _card([
            _switchTile('Haptic Feedback', 'Vibrate on interactions', _hapticsEnabled, (v) {
              setState(() => _hapticsEnabled = v);
              HapticFeedback.mediumImpact();
            }, theme),
            _divider(theme),
            _switchTile('Sounds', 'Play UI sounds (coming soon)', _soundsEnabled, (v) {
              _haptic();
              setState(() => _soundsEnabled = v);
            }, theme),
            _divider(theme),
            _switchTile('Background Refresh', 'Refresh content in background', _backgroundRefresh, (v) {
              _haptic();
              setState(() => _backgroundRefresh = v);
            }, theme),
            _divider(theme),
            _switchTile('Notifications', 'Get notified about nothing', _notifications, (v) {
              _haptic();
              setState(() => _notifications = v);
            }, theme),
          ], theme),

          const SizedBox(height: 16),
          _sectionHeader('Sync & Data', theme),
          _card([
            _switchTile('Cloud Sync', 'Sync your nothing to the cloud', _cloudSync, (v) {
              _haptic();
              setState(() => _cloudSync = v);
            }, theme),
            _divider(theme),
            _switchTile('Analytics', "Help us improve (we won't)", _analytics, (v) {
              _haptic();
              setState(() => _analytics = v);
            }, theme),
            _divider(theme),
            _switchTile('Data Saver', 'Use less data doing nothing', _dataSaver, (v) {
              _haptic();
              setState(() => _dataSaver = v);
            }, theme),
            _divider(theme),
            _dropdownTile('Region', _selectedRegion, _regions,
                (v) => setState(() => _selectedRegion = v!), theme),
          ], theme),

          const SizedBox(height: 16),
          _sectionHeader('Advanced', theme),
          _card([
            _switchTile('Reduced Motion', 'Less animations', _reducedMotion, (v) {
              _haptic();
              setState(() => _reducedMotion = v);
            }, theme),
            _divider(theme),
            _switchTile('Auto Update', 'Keep app updated automatically', _autoUpdate, (v) {
              _haptic();
              setState(() => _autoUpdate = v);
            }, theme),
            _divider(theme),
            _sliderTile('Performance Level', _performanceLevel,
                (v) => setState(() => _performanceLevel = v), theme),
            _divider(theme),
            _switchTile('Night Mode', 'Optimize for night use', _nightMode, (v) {
              _haptic();
              setState(() => _nightMode = v);
            }, theme),
            _divider(theme),
            _switchTile('Experimental Features', "Enable features that don't exist",
                _experimentalFeatures, (v) {
              _haptic();
              setState(() => _experimentalFeatures = v);
            }, theme),
            _divider(theme),
            _switchTile('Beta Program', 'Get early access to nothing', _betaProgram, (v) {
              _haptic();
              setState(() => _betaProgram = v);
            }, theme),
          ], theme),

          const SizedBox(height: 16),
          _sectionHeader('About', theme),
          _card([
            ListTile(
              title: Text('Version', style: TextStyle(color: theme.onBackground)),
              trailing: Text('1.0.0 (null)',
                  style: TextStyle(color: theme.onBackground.withOpacity(0.5))),
            ),
            _divider(theme),
            ListTile(
              title: Text('Build', style: TextStyle(color: theme.onBackground)),
              trailing: Text('0x00000000',
                  style: TextStyle(
                      color: theme.onBackground.withOpacity(0.5),
                      fontFamily: 'monospace')),
            ),
            _divider(theme),
            ListTile(
              title: Text('Reset Everything',
                  style: TextStyle(color: Colors.red.shade400)),
              trailing: Icon(Icons.chevron_right,
                  color: theme.onBackground.withOpacity(0.3)),
              onTap: () => _showResetDialog(theme),
            ),
          ], theme),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _themeSelector(ThemeProvider provider, theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Color Theme',
              style: TextStyle(
                  color: theme.onBackground, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 16),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: AppThemes.presets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (ctx, i) {
                final t = AppThemes.presets[i];
                final selected = !provider.useCustom && provider.selectedIndex == i;
                return GestureDetector(
                  onTap: () {
                    _haptic();
                    provider.selectPreset(i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: t.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? theme.onBackground : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: selected
                          ? [BoxShadow(color: t.primary.withOpacity(0.5), blurRadius: 10)]
                          : null,
                    ),
                    child: selected
                        ? Icon(Icons.check, color: t.onPrimary, size: 22)
                        : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          // Fixed: theme names scroll with circles using same ListView
          SizedBox(
            height: 18,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: AppThemes.presets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (ctx, i) {
                final t = AppThemes.presets[i];
                final selected = !provider.useCustom && provider.selectedIndex == i;
                return SizedBox(
                  width: 52,
                  child: Text(
                    t.name,
                    style: TextStyle(
                      fontSize: 9,
                      color: selected
                          ? theme.primary
                          : theme.onBackground.withOpacity(0.35),
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
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
    );
  }

  Widget _customThemeBuilder(ThemeProvider provider, theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Custom Theme',
                  style: TextStyle(
                      color: theme.onBackground,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const Spacer(),
              if (provider.useCustom)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Active',
                      style: TextStyle(color: theme.primary, fontSize: 11)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _colorRow('Primary', provider.customPrimary,
              (c) => provider.updateCustomColor(primary: c), theme),
          _colorRow('Background', provider.customBackground,
              (c) => provider.updateCustomColor(background: c), theme),
          _colorRow('Surface', provider.customSurface,
              (c) => provider.updateCustomColor(surface: c), theme),
          _colorRow('Text', provider.customOnBackground,
              (c) => provider.updateCustomColor(onBackground: c), theme),
          _colorRow('Accent', provider.customAccent,
              (c) => provider.updateCustomColor(accent: c), theme),
        ],
      ),
    );
  }

  Widget _colorRow(String label, Color color, ValueChanged<Color> onChanged, theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                  color: theme.onBackground.withOpacity(0.7), fontSize: 15)),
          const Spacer(),
          GestureDetector(
            onTap: () => _pickColor(color, onChanged),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: theme.onBackground.withOpacity(0.15), width: 2),
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
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
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
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: theme.primary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    );
  }

  Widget _card(List<Widget> children, theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(children: children),
    );
  }

  Widget _switchTile(String title, String sub, bool value,
      ValueChanged<bool> onChanged, theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: theme.onBackground,
                        fontWeight: FontWeight.w500,
                        fontSize: 16)),
                const SizedBox(height: 2),
                Text(sub,
                    style: TextStyle(
                        color: theme.onBackground.withOpacity(0.45), fontSize: 13)),
              ],
            ),
          ),
          Transform.scale(
            scale: 1.1,
            child: Switch(value: value, onChanged: onChanged),
          ),
        ],
      ),
    );
  }

  Widget _sliderTile(String title, double value, ValueChanged<double> onChanged, theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: theme.onBackground,
                  fontWeight: FontWeight.w500,
                  fontSize: 16)),
          Slider(
            value: value,
            min: 1,
            max: 5,
            divisions: 4,
            label: value.round().toString(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _dropdownTile(String title, String value, List<String> items,
      ValueChanged<String?> onChanged, theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          Text(title,
              style: TextStyle(
                  color: theme.onBackground,
                  fontWeight: FontWeight.w500,
                  fontSize: 16)),
          const Spacer(),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            dropdownColor: theme.surface,
            style: TextStyle(color: theme.onBackground),
            items: items
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _divider(theme) => Divider(
        height: 1,
        indent: 20,
        endIndent: 20,
        color: theme.onBackground.withOpacity(0.07),
      );
}
