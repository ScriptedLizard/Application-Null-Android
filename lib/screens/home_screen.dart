import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../widgets/wheel_picker_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Random _random = Random();

  // Switch states
  final List<bool> _switchStates = List.filled(12, false);

  // Which switch is the slow one (up to 1s delay) - fixed at index 3
  static const int _slowSwitchIndex = 3;

  // Which 5 switches are instant (no delay) - fixed indices
  static const Set<int> _instantSwitches = {0, 5, 7, 10, 11};

  // Loading state per switch
  final List<bool> _switching = List.filled(12, false);

  // App fake-freeze overlay
  bool _frozen = false;

  // Stopwatch
  bool _stopwatchRunning = false;
  Duration _elapsed = Duration.zero;
  Timer? _stopwatchTimer;
  DateTime? _startTime;

  // Wheel picker selection
  String _wheelResult = '—';

  final List<Map<String, dynamic>> _switchData = [
    {'label': 'Enable Everything', 'sub': 'Instant'},
    {'label': 'Toggle Something', 'sub': null},
    {'label': 'Activate Mode', 'sub': null},
    {'label': 'Apply Ultra Settings', 'sub': 'Takes a moment...'},
    {'label': 'Thing Switchy Switchy', 'sub': null},
    {'label': 'Quick Toggle', 'sub': 'Instant'},
    {'label': 'Do the Thing', 'sub': null},
    {'label': 'Boost Performance', 'sub': 'Instant'},
    {'label': 'Enable Null Protocol', 'sub': null},
    {'label': 'Sync with Void', 'sub': null},
    {'label': 'Override Override', 'sub': 'Instant'},
    {'label': 'Confirm Confirmation', 'sub': 'Instant'},
  ];

  Future<void> _handleSwitch(int index, bool val) async {
    if (_switching[index]) return;

    setState(() => _switching[index] = true);

    int delayMs = 0;
    if (_instantSwitches.contains(index)) {
      delayMs = 0;
    } else if (index == _slowSwitchIndex) {
      delayMs = 200 + _random.nextInt(800); // 200–1000ms
    } else {
      delayMs = _random.nextInt(86); // 0–85ms
    }

    if (delayMs > 0) {
      setState(() => _frozen = true);
      await Future.delayed(Duration(milliseconds: delayMs));
      setState(() => _frozen = false);
    }

    HapticFeedback.lightImpact();
    setState(() {
      _switchStates[index] = val;
      _switching[index] = false;
    });
  }

  void _toggleStopwatch() {
    if (_stopwatchRunning) {
      _stopwatchTimer?.cancel();
      setState(() => _stopwatchRunning = false);
    } else {
      _startTime = DateTime.now().subtract(_elapsed);
      _stopwatchTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
        setState(() => _elapsed = DateTime.now().difference(_startTime!));
      });
      setState(() => _stopwatchRunning = true);
    }
  }

  void _resetStopwatch() {
    _stopwatchTimer?.cancel();
    setState(() {
      _stopwatchRunning = false;
      _elapsed = Duration.zero;
    });
  }

  String _formatElapsed(Duration d) {
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ms = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return '$min:$sec.$ms';
  }

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: theme.background,
          appBar: AppBar(
            backgroundColor: theme.surface,
            title: Text(
              'Application Null',
              style: TextStyle(
                color: theme.onBackground,
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
            ),
            centerTitle: false,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStopwatch(theme),
              const SizedBox(height: 16),
              _buildWheelPicker(theme),
              const SizedBox(height: 16),
              _buildSwitchSection(theme),
            ],
          ),
        ),
        if (_frozen)
          Positioned.fill(
            child: AbsorbPointer(
              child: Container(color: Colors.transparent),
            ),
          ),
      ],
    );
  }

  Widget _buildStopwatch(theme) {
    return Card(
      color: theme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              _formatElapsed(_elapsed),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w200,
                color: theme.primary,
                fontFeatures: const [FontFeature.tabularFigures()],
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: _toggleStopwatch,
                  icon: Icon(_stopwatchRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_stopwatchRunning ? 'Pause' : 'Start'),
                  style: FilledButton.styleFrom(backgroundColor: theme.primary),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _resetStopwatch,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWheelPicker(theme) {
    return Card(
      color: theme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          'Select your thingy:',
          style: TextStyle(color: theme.onBackground, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          _wheelResult,
          style: TextStyle(
            color: theme.primary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(Icons.tune, color: theme.primary),
        onTap: () async {
          final result = await showDialog<String>(
            context: context,
            builder: (_) => const WheelPickerDialog(),
          );
          if (result != null) setState(() => _wheelResult = result);
        },
      ),
    );
  }

  Widget _buildSwitchSection(theme) {
    return Card(
      color: theme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: List.generate(_switchData.length, (i) {
          final data = _switchData[i];
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                title: Text(
                  data['label'] as String,
                  style: TextStyle(
                    color: theme.onBackground,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                subtitle: data['sub'] != null
                    ? Text(
                        data['sub'] as String,
                        style: TextStyle(
                          color: theme.onBackground.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      )
                    : null,
                trailing: _switching[i]
                    ? SizedBox(
                        width: 36,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.primary,
                        ),
                      )
                    : Switch(
                        value: _switchStates[i],
                        onChanged: (val) => _handleSwitch(i, val),
                      ),
              ),
              if (i < _switchData.length - 1)
                Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: theme.onBackground.withOpacity(0.08),
                ),
            ],
          );
        }),
      ),
    );
  }
}
