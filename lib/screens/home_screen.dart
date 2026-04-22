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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final Random _random = Random();
  final List<bool> _switchStates = List.filled(12, false);
  static const int _slowSwitchIndex = 3;
  static const Set<int> _instantSwitches = {0, 5, 7, 10, 11};
  final List<bool> _switching = List.filled(12, false);
  bool _frozen = false;

  bool _stopwatchRunning = false;
  Duration _elapsed = Duration.zero;
  Timer? _stopwatchTimer;
  DateTime? _startTime;
  String _wheelResult = '—';

  late AnimationController _headerAnim;
  late List<AnimationController> _cardAnims;

  final List<Map<String, dynamic>> _switchData = [
    {'label': 'Enable Everything', 'sub': 'Instant response'},
    {'label': 'Toggle Something', 'sub': 'Does something, probably'},
    {'label': 'Activate Mode', 'sub': 'Mode activated'},
    {'label': 'Apply Ultra Settings', 'sub': 'This one takes a moment...'},
    {'label': 'Thing Switchy Switchy', 'sub': 'Switchy switchy'},
    {'label': 'Quick Toggle', 'sub': 'Very fast. Very impressive'},
    {'label': 'Do the Thing', 'sub': 'The thing will be done'},
    {'label': 'Boost Performance', 'sub': 'Instant boost'},
    {'label': 'Enable Null Protocol', 'sub': 'Protocol: null'},
    {'label': 'Sync with Void', 'sub': 'Syncing with nothing'},
    {'label': 'Override Override', 'sub': 'Overriding the override'},
    {'label': 'Confirm Confirmation', 'sub': 'Confirming that you confirmed'},
  ];

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _cardAnims = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    for (int i = 0; i < _cardAnims.length; i++) {
      Future.delayed(Duration(milliseconds: 100 + i * 80), () {
        if (mounted) _cardAnims[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    _headerAnim.dispose();
    for (final c in _cardAnims) c.dispose();
    super.dispose();
  }

  Future<void> _handleSwitch(int index, bool val) async {
    if (_switching[index]) return;
    setState(() => _switching[index] = true);

    int delayMs = 0;
    if (_instantSwitches.contains(index)) {
      delayMs = 0;
    } else if (index == _slowSwitchIndex) {
      delayMs = 200 + _random.nextInt(800);
    } else {
      delayMs = _random.nextInt(86);
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
    HapticFeedback.mediumImpact();
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
    HapticFeedback.lightImpact();
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

  Widget _animated(int cardIndex, Widget child) {
    final anim = CurvedAnimation(
      parent: _cardAnims[cardIndex],
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: theme.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: theme.surface,
                expandedHeight: 100,
                floating: true,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: FadeTransition(
                    opacity: _headerAnim,
                    child: Text(
                      'Application Null',
                      style: TextStyle(
                        color: theme.onBackground,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                ),
                elevation: 0,
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _animated(0, _buildStopwatch(theme)),
                    const SizedBox(height: 16),
                    _animated(1, _buildWheelPicker(theme)),
                    const SizedBox(height: 16),
                    _animated(2, _buildSwitchSection(theme)),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
        if (_frozen)
          Positioned.fill(
            child: AbsorbPointer(child: Container(color: Colors.transparent)),
          ),
      ],
    );
  }

  Widget _buildStopwatch(theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Text(
            'Stopwatch',
            style: TextStyle(
              color: theme.onBackground.withOpacity(0.5),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: _stopwatchRunning ? 52 : 48,
              fontWeight: FontWeight.w200,
              color: theme.primary,
              letterSpacing: 2,
            ),
            child: Text(
              _formatElapsed(_elapsed),
              style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _bigButton(
                _stopwatchRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                _stopwatchRunning ? 'Pause' : 'Start',
                theme.primary,
                _toggleStopwatch,
                theme,
              ),
              const SizedBox(width: 12),
              _bigButton(
                Icons.refresh_rounded,
                'Reset',
                theme.onBackground.withOpacity(0.15),
                _resetStopwatch,
                theme,
                outlined: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bigButton(IconData icon, String label, Color color, VoidCallback onTap, theme,
      {bool outlined = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(16),
          border: outlined
              ? Border.all(color: theme.onBackground.withOpacity(0.2), width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: outlined ? theme.onBackground.withOpacity(0.6) : theme.onPrimary,
                size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: outlined ? theme.onBackground.withOpacity(0.6) : theme.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWheelPicker(theme) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        final result = await showDialog<String>(
          context: context,
          builder: (_) => const WheelPickerDialog(),
        );
        if (result != null) setState(() => _wheelResult = result);
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.tune_rounded, color: theme.primary, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select your thingy:',
                    style: TextStyle(
                      color: theme.onBackground.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _wheelResult,
                    style: TextStyle(
                      color: theme.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: theme.onBackground.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchSection(theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: List.generate(_switchData.length, (i) {
          final data = _switchData[i];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['label'] as String,
                            style: TextStyle(
                              color: theme.onBackground,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            data['sub'] as String,
                            style: TextStyle(
                              color: theme.onBackground.withOpacity(0.45),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _switching[i]
                        ? SizedBox(
                            width: 40,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: theme.primary,
                            ),
                          )
                        : Transform.scale(
                            scale: 1.1,
                            child: Switch(
                              value: _switchStates[i],
                              onChanged: (val) => _handleSwitch(i, val),
                            ),
                          ),
                  ],
                ),
              ),
              if (i < _switchData.length - 1)
                Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: theme.onBackground.withOpacity(0.07),
                ),
            ],
          );
        }),
      ),
    );
  }
}
