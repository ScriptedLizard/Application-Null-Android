import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme_provider.dart';

enum ShapeType { circle, square, triangle }

class PhysicsShape {
  Offset position;
  Offset velocity;
  ShapeType type;
  Color color;
  double size;
  double rotation;
  double angularVelocity;

  PhysicsShape({
    required this.position,
    required this.type,
    required this.color,
    this.size = 48,
    this.velocity = Offset.zero,
    this.rotation = 0,
    this.angularVelocity = 0,
  });
}

class NotepadScreen extends StatefulWidget {
  const NotepadScreen({super.key});

  @override
  State<NotepadScreen> createState() => _NotepadScreenState();
}

class _NotepadScreenState extends State<NotepadScreen>
    with SingleTickerProviderStateMixin {
  final List<PhysicsShape> _shapes = [];
  final Random _random = Random();
  late AnimationController _physics;
  Size _canvasSize = Size.zero;

  int? _draggingIndex;
  Offset _dragOffset = Offset.zero;
  Offset _lastDragPos = Offset.zero;
  Offset _dragVelocity = Offset.zero;

  bool _boldActive = false;
  bool _bulletActive = false;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSaved = false;

  static const double _gravity = 0.35;
  static const double _bounce = 0.55;
  static const double _friction = 0.985;

  @override
  void initState() {
    super.initState();
    _loadNote();
    _physics = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )..addListener(_tickPhysics)..repeat();
  }

  Future<void> _loadNote() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('notepad_content') ?? '';
    setState(() => _textController.text = saved);
  }

  Future<void> _saveNote() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notepad_content', _textController.text);
    HapticFeedback.lightImpact();
    setState(() => _isSaved = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isSaved = false);
  }

  void _tickPhysics() {
    if (_canvasSize == Size.zero || _shapes.isEmpty) return;
    setState(() {
      // Update positions
      for (int i = 0; i < _shapes.length; i++) {
        if (_draggingIndex == i) continue;
        final s = _shapes[i];
        s.velocity = Offset(s.velocity.dx * _friction, s.velocity.dy + _gravity);
        s.position += s.velocity;
        s.rotation += s.angularVelocity;
        s.angularVelocity *= 0.98;

        final half = s.size / 2;
        if (s.position.dy + half > _canvasSize.height) {
          s.position = Offset(s.position.dx, _canvasSize.height - half);
          s.velocity = Offset(s.velocity.dx * _friction, -s.velocity.dy.abs() * _bounce);
          s.angularVelocity = s.velocity.dx * 0.08;
          if (s.velocity.dy.abs() < 1) s.velocity = Offset(s.velocity.dx, 0);
        }
        if (s.position.dy - half < 0) {
          s.position = Offset(s.position.dx, half);
          s.velocity = Offset(s.velocity.dx, s.velocity.dy.abs() * _bounce);
        }
        if (s.position.dx - half < 0) {
          s.position = Offset(half, s.position.dy);
          s.velocity = Offset(s.velocity.dx.abs() * _bounce, s.velocity.dy);
        }
        if (s.position.dx + half > _canvasSize.width) {
          s.position = Offset(_canvasSize.width - half, s.position.dy);
          s.velocity = Offset(-s.velocity.dx.abs() * _bounce, s.velocity.dy);
        }
      }

      // Shape-to-shape collision
      for (int i = 0; i < _shapes.length; i++) {
        for (int j = i + 1; j < _shapes.length; j++) {
          final a = _shapes[i];
          final b = _shapes[j];
          final minDist = (a.size + b.size) / 2;
          final delta = b.position - a.position;
          final dist = delta.distance;

          if (dist < minDist && dist > 0) {
            final normal = delta / dist;
            final overlap = minDist - dist;

            // Separate shapes
            if (_draggingIndex != i) {
              a.position -= normal * overlap * 0.5;
            }
            if (_draggingIndex != j) {
              b.position += normal * overlap * 0.5;
            }

            // Exchange velocity along collision normal
            final relVel = b.velocity - a.velocity;
            final velAlongNormal = relVel.dx * normal.dx + relVel.dy * normal.dy;

            if (velAlongNormal < 0) {
              final impulse = velAlongNormal * _bounce;
              final impulseVec = normal * impulse;
              if (_draggingIndex != i) a.velocity += impulseVec;
              if (_draggingIndex != j) b.velocity -= impulseVec;

              // Transfer some angular velocity
              a.angularVelocity += impulse * 0.05;
              b.angularVelocity -= impulse * 0.05;
            }
          }
        }
      }
    });
  }

  void _spawnShape(ShapeType type) {
    HapticFeedback.lightImpact();
    final colors = [
      Colors.red.shade400,
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.teal.shade400,
      Colors.pink.shade400,
      Colors.amber.shade400,
      Colors.cyan.shade400,
      Colors.lime.shade400,
    ];
    setState(() {
      _shapes.add(PhysicsShape(
        position: Offset(
          60 + _random.nextDouble() * (_canvasSize.width - 120),
          30,
        ),
        type: type,
        color: colors[_random.nextInt(colors.length)],
        size: 44 + _random.nextDouble() * 24,
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 5,
          _random.nextDouble() * 2,
        ),
        angularVelocity: (_random.nextDouble() - 0.5) * 0.08,
      ));
    });
  }

  @override
  void dispose() {
    _physics.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surface,
        title: Text('Notepad', style: TextStyle(color: theme.onBackground, fontWeight: FontWeight.w600)),
        elevation: 0,
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isSaved
                ? Padding(
                    key: const ValueKey('saved'),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: theme.primary, size: 18),
                        const SizedBox(width: 4),
                        Text('Saved', style: TextStyle(color: theme.primary, fontSize: 13)),
                      ],
                    ),
                  )
                : IconButton(
                    key: const ValueKey('save'),
                    icon: Icon(Icons.save_outlined, color: theme.onBackground.withOpacity(0.7)),
                    tooltip: 'Save note',
                    onPressed: _saveNote,
                  ),
          ),
          IconButton(
            icon: Icon(Icons.delete_sweep_outlined, color: theme.onBackground.withOpacity(0.5)),
            tooltip: 'Clear shapes',
            onPressed: () => setState(() => _shapes.clear()),
          ),
        ],
      ),
      body: Column(
        children: [
          // Toolbar
          Container(
            color: theme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                _fmtBtn(Icons.format_bold, _boldActive, () {
                  setState(() => _boldActive = !_boldActive);
                }, theme),
                _fmtBtn(Icons.format_list_bulleted, _bulletActive, () {
                  setState(() {
                    _bulletActive = !_bulletActive;
                    if (_bulletActive) {
                      final text = _textController.text;
                      final newText = (text.isEmpty || text.endsWith('\n'))
                          ? '${text}• '
                          : '$text\n• ';
                      _textController.value = TextEditingValue(
                        text: newText,
                        selection: TextSelection.collapsed(offset: newText.length),
                      );
                    }
                  });
                }, theme),
                const Spacer(),
                _spawnBtn(Icons.circle_outlined, ShapeType.circle, theme),
                _spawnBtn(Icons.square_outlined, ShapeType.square, theme),
                _spawnBtn(Icons.change_history_outlined, ShapeType.triangle, theme),
              ],
            ),
          ),
          Divider(height: 1, color: theme.onBackground.withOpacity(0.08)),
          // Main area
          Expanded(
            child: LayoutBuilder(builder: (ctx, constraints) {
              _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
              return Stack(
                children: [
                  // Notepad - full area, tappable
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => _focusNode.requestFocus(),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: TextStyle(
                            color: theme.onBackground,
                            fontWeight: _boldActive ? FontWeight.bold : FontWeight.normal,
                            fontSize: 16,
                            height: 1.7,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Tap to write something...',
                            hintStyle: TextStyle(
                              color: theme.onBackground.withOpacity(0.25),
                              fontSize: 16,
                            ),
                          ),
                          onChanged: (val) {
                            if (_bulletActive && val.endsWith('\n')) {
                              final newText = '${val}• ';
                              _textController.value = TextEditingValue(
                                text: newText,
                                selection: TextSelection.collapsed(offset: newText.length),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  // Physics layer — only intercepts if touching a shape
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanStart: (d) {
                        for (int i = _shapes.length - 1; i >= 0; i--) {
                          final s = _shapes[i];
                          if ((s.position - d.localPosition).distance < s.size * 0.7) {
                            _draggingIndex = i;
                            _dragOffset = d.localPosition - s.position;
                            _lastDragPos = d.localPosition;
                            break;
                          }
                        }
                      },
                      onPanUpdate: (d) {
                        if (_draggingIndex != null) {
                          _dragVelocity = d.localPosition - _lastDragPos;
                          _lastDragPos = d.localPosition;
                          setState(() {
                            _shapes[_draggingIndex!].position =
                                d.localPosition - _dragOffset;
                            _shapes[_draggingIndex!].velocity = Offset.zero;
                          });
                        }
                      },
                      onPanEnd: (_) {
                        if (_draggingIndex != null) {
                          _shapes[_draggingIndex!].velocity = _dragVelocity * 1.8;
                          _shapes[_draggingIndex!].angularVelocity =
                              _dragVelocity.dx * 0.05;
                          _draggingIndex = null;
                        }
                      },
                      child: CustomPaint(
                        painter: _ShapesPainter(_shapes),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _fmtBtn(IconData icon, bool active, VoidCallback onTap, theme) {
    return IconButton(
      icon: Icon(icon, color: active ? theme.primary : theme.onBackground.withOpacity(0.4)),
      onPressed: onTap,
      iconSize: 22,
    );
  }

  Widget _spawnBtn(IconData icon, ShapeType type, theme) {
    return IconButton(
      icon: Icon(icon, color: theme.primary),
      tooltip: 'Spawn ${type.name}',
      onPressed: () => _spawnShape(type),
      iconSize: 22,
    );
  }
}

class _ShapesPainter extends CustomPainter {
  final List<PhysicsShape> shapes;
  _ShapesPainter(this.shapes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in shapes) {
      final paint = Paint()
        ..color = s.color.withOpacity(0.88)
        ..style = PaintingStyle.fill;

      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.save();
      canvas.translate(s.position.dx, s.position.dy);
      canvas.rotate(s.rotation);

      switch (s.type) {
        case ShapeType.circle:
          canvas.drawCircle(const Offset(2, 4), s.size / 2, shadowPaint);
          canvas.drawCircle(Offset.zero, s.size / 2, paint);
          break;
        case ShapeType.square:
          final half = s.size / 2;
          final rect = Rect.fromLTWH(-half, -half, s.size, s.size);
          final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
          canvas.drawRRect(rRect.shift(const Offset(2, 4)), shadowPaint);
          canvas.drawRRect(rRect, paint);
          break;
        case ShapeType.triangle:
          final path = Path()
            ..moveTo(0, -s.size / 2)
            ..lineTo(s.size / 2, s.size / 2)
            ..lineTo(-s.size / 2, s.size / 2)
            ..close();
          canvas.drawPath(path.shift(const Offset(2, 4)), shadowPaint);
          canvas.drawPath(path, paint);
          break;
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ShapesPainter old) => true;
}
