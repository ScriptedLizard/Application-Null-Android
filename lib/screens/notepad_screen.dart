import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  bool _boldActive = false;
  bool _bulletActive = false;
  final TextEditingController _textController = TextEditingController();

  static const double _gravity = 0.4;
  static const double _bounce = 0.6;
  static const double _friction = 0.98;

  @override
  void initState() {
    super.initState();
    _physics = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )..addListener(_tickPhysics)..repeat();
  }

  void _tickPhysics() {
    if (_canvasSize == Size.zero) return;
    setState(() {
      for (int i = 0; i < _shapes.length; i++) {
        if (_draggingIndex == i) continue;
        final s = _shapes[i];
        s.velocity = Offset(s.velocity.dx * _friction, s.velocity.dy + _gravity);
        s.position += s.velocity;
        s.rotation += s.angularVelocity;
        s.angularVelocity *= 0.99;

        final half = s.size / 2;

        // Floor
        if (s.position.dy + half > _canvasSize.height) {
          s.position = Offset(s.position.dx, _canvasSize.height - half);
          s.velocity = Offset(s.velocity.dx * _friction, -s.velocity.dy * _bounce);
          s.angularVelocity = s.velocity.dx * 0.1;
        }
        // Ceiling
        if (s.position.dy - half < 0) {
          s.position = Offset(s.position.dx, half);
          s.velocity = Offset(s.velocity.dx, s.velocity.dy.abs() * _bounce);
        }
        // Walls
        if (s.position.dx - half < 0) {
          s.position = Offset(half, s.position.dy);
          s.velocity = Offset(s.velocity.dx.abs() * _bounce, s.velocity.dy);
        }
        if (s.position.dx + half > _canvasSize.width) {
          s.position = Offset(_canvasSize.width - half, s.position.dy);
          s.velocity = Offset(-s.velocity.dx.abs() * _bounce, s.velocity.dy);
        }
      }
    });
  }

  void _spawnShape(ShapeType type) {
    final colors = [
      Colors.red, Colors.blue, Colors.green, Colors.orange,
      Colors.purple, Colors.teal, Colors.pink, Colors.amber,
    ];
    _shapes.add(PhysicsShape(
      position: Offset(
        50 + _random.nextDouble() * (_canvasSize.width - 100),
        50,
      ),
      type: type,
      color: colors[_random.nextInt(colors.length)],
      size: 40 + _random.nextDouble() * 30,
      velocity: Offset(
        (_random.nextDouble() - 0.5) * 6,
        _random.nextDouble() * 3,
      ),
      angularVelocity: (_random.nextDouble() - 0.5) * 0.1,
    ));
  }

  @override
  void dispose() {
    _physics.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surface,
        title: Text('Notepad', style: TextStyle(color: theme.onBackground)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep_outlined, color: theme.onBackground.withOpacity(0.6)),
            tooltip: 'Clear shapes',
            onPressed: () => setState(() => _shapes.clear()),
          ),
        ],
      ),
      body: Column(
        children: [
          // Formatting toolbar
          Container(
            color: theme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                      if (text.isEmpty || text.endsWith('\n')) {
                        _textController.text = '${text}• ';
                      } else {
                        _textController.text = '$text\n• ';
                      }
                      _textController.selection = TextSelection.collapsed(
                        offset: _textController.text.length,
                      );
                    }
                  });
                }, theme),
                const Spacer(),
                // Spawn buttons
                _spawnBtn(Icons.circle_outlined, ShapeType.circle, theme),
                _spawnBtn(Icons.square_outlined, ShapeType.square, theme),
                _spawnBtn(Icons.change_history_outlined, ShapeType.triangle, theme),
              ],
            ),
          ),
          const Divider(height: 1),
          // Canvas with physics shapes + notepad
          Expanded(
            child: LayoutBuilder(builder: (ctx, constraints) {
              _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
              return Stack(
                children: [
                  // Notepad text area
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _textController,
                        maxLines: null,
                        expands: true,
                        style: TextStyle(
                          color: theme.onBackground,
                          fontWeight: _boldActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: 16,
                          height: 1.6,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Write something...',
                          hintStyle: TextStyle(color: theme.onBackground.withOpacity(0.3)),
                        ),
                        onChanged: (val) {
                          if (_bulletActive && val.endsWith('\n')) {
                            _textController.text = '${val}• ';
                            _textController.selection = TextSelection.collapsed(
                              offset: _textController.text.length,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  // Physics layer
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanStart: (d) {
                        for (int i = _shapes.length - 1; i >= 0; i--) {
                          final s = _shapes[i];
                          if ((s.position - d.localPosition).distance < s.size) {
                            _draggingIndex = i;
                            _dragOffset = d.localPosition - s.position;
                            break;
                          }
                        }
                      },
                      onPanUpdate: (d) {
                        if (_draggingIndex != null) {
                          setState(() {
                            _shapes[_draggingIndex!].position =
                                d.localPosition - _dragOffset;
                            _shapes[_draggingIndex!].velocity = d.delta * 1.5;
                          });
                        }
                      },
                      onPanEnd: (_) => _draggingIndex = null,
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
      icon: Icon(icon,
          color: active ? theme.primary : theme.onBackground.withOpacity(0.5)),
      onPressed: onTap,
      iconSize: 22,
    );
  }

  Widget _spawnBtn(IconData icon, ShapeType type, theme) {
    return IconButton(
      icon: Icon(icon, color: theme.primary),
      tooltip: 'Spawn ${type.name}',
      onPressed: () => setState(() => _spawnShape(type)),
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
        ..color = s.color.withOpacity(0.85)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(s.position.dx, s.position.dy);
      canvas.rotate(s.rotation);

      switch (s.type) {
        case ShapeType.circle:
          canvas.drawCircle(Offset.zero, s.size / 2, paint);
          break;
        case ShapeType.square:
          final half = s.size / 2;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(-half, -half, s.size, s.size),
              const Radius.circular(6),
            ),
            paint,
          );
          break;
        case ShapeType.triangle:
          final path = Path()
            ..moveTo(0, -s.size / 2)
            ..lineTo(s.size / 2, s.size / 2)
            ..lineTo(-s.size / 2, s.size / 2)
            ..close();
          canvas.drawPath(path, paint);
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ShapesPainter old) => true;
}
