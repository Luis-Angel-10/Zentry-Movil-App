import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import 'package:Zentry/l10n/generated/app_localizations.dart';

enum _DrawTool { pencil, line, rectangle, circle, eraser }

class _DrawingElement {
  final _DrawTool tool;
  final Color color;
  final double strokeWidth;
  final List<Offset> points;

  _DrawingElement({
    required this.tool,
    required this.color,
    required this.strokeWidth,
    required this.points,
  });
}

const List<Color> _kPalette = [
  Colors.black,
  Colors.white,
  Colors.redAccent,
  Colors.orange,
  Colors.amber,
  Colors.green,
  Colors.blueAccent,
  Colors.purple,
  Colors.pinkAccent,
  Colors.brown,
];

class DrawingCanvasPage extends StatefulWidget {
  const DrawingCanvasPage({super.key});

  @override
  State<DrawingCanvasPage> createState() => _DrawingCanvasPageState();
}

class _DrawingCanvasPageState extends State<DrawingCanvasPage> {
  final GlobalKey _canvasKey = GlobalKey();

  final List<_DrawingElement> _elements = [];
  _DrawingElement? _current;

  _DrawTool _tool = _DrawTool.pencil;
  Color _color = Colors.black;
  double _strokeWidth = 6;
  bool _isSaving = false;

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _current = _DrawingElement(
        tool: _tool,
        color: _tool == _DrawTool.eraser ? Colors.white : _color,
        strokeWidth: _tool == _DrawTool.eraser
            ? _strokeWidth * 3
            : _strokeWidth,
        points: [details.localPosition],
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final current = _current;
    if (current == null) return;

    setState(() {
      if (current.tool == _DrawTool.pencil ||
          current.tool == _DrawTool.eraser) {
        current.points.add(details.localPosition);
      } else {
        if (current.points.length == 1) {
          current.points.add(details.localPosition);
        } else {
          current.points[1] = details.localPosition;
        }
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final current = _current;
    if (current == null) return;

    setState(() {
      _elements.add(current);
      _current = null;
    });
  }

  void _undo() {
    if (_elements.isEmpty) return;
    setState(() {
      _elements.removeLast();
    });
  }

  void _clear() {
    setState(() {
      _elements.clear();
      _current = null;
    });
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final boundary =
          _canvasKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/zentry_drawing_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);

      if (!mounted) return;
      Navigator.pop(context, file);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        elevation: 0,
        title: Text(l10n.drawingCanvasTitle),
        actions: [
          IconButton(
            onPressed: _elements.isEmpty ? null : _undo,
            icon: const Icon(Icons.undo),
            tooltip: l10n.drawingCanvasUndo,
          ),
          IconButton(
            onPressed: _elements.isEmpty ? null : _clear,
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.drawingCanvasClear,
          ),
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    l10n.drawingCanvasSave,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: RepaintBoundary(
                  key: _canvasKey,
                  child: Container(
                    color: Colors.white,
                    width: double.infinity,
                    height: double.infinity,
                    child: GestureDetector(
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      child: CustomPaint(
                        painter: _DrawingPainter(
                          elements: _elements,
                          current: _current,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildToolbar(l10n),
        ],
      ),
    );
  }

  Widget _buildToolbar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(color: Color(0xFF1A1A2E)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _toolButton(Icons.edit, _DrawTool.pencil),
              _toolButton(Icons.show_chart, _DrawTool.line),
              _toolButton(Icons.crop_square, _DrawTool.rectangle),
              _toolButton(Icons.circle_outlined, _DrawTool.circle),
              _toolButton(Icons.cleaning_services_outlined, _DrawTool.eraser),
              const Spacer(),
              Expanded(
                child: Slider(
                  value: _strokeWidth,
                  min: 2,
                  max: 24,
                  onChanged: (value) {
                    setState(() {
                      _strokeWidth = value;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _kPalette.length,
              itemBuilder: (_, index) {
                final swatch = _kPalette[index];
                final selected = swatch == _color;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _color = swatch;
                    });
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: swatch,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? Colors.white : Colors.white24,
                        width: selected ? 3 : 1,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolButton(IconData icon, _DrawTool tool) {
    final selected = _tool == tool;

    return IconButton(
      onPressed: () {
        setState(() {
          _tool = tool;
        });
      },
      icon: Icon(icon, color: selected ? Colors.white : Colors.white38),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<_DrawingElement> elements;
  final _DrawingElement? current;

  _DrawingPainter({required this.elements, required this.current});

  void _paintElement(Canvas canvas, _DrawingElement element) {
    final paint = Paint()
      ..color = element.color
      ..strokeWidth = element.strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    switch (element.tool) {
      case _DrawTool.pencil:
      case _DrawTool.eraser:
        for (var i = 0; i < element.points.length - 1; i++) {
          canvas.drawLine(element.points[i], element.points[i + 1], paint);
        }
        break;
      case _DrawTool.line:
        if (element.points.length >= 2) {
          canvas.drawLine(element.points[0], element.points[1], paint);
        }
        break;
      case _DrawTool.rectangle:
        if (element.points.length >= 2) {
          canvas.drawRect(
            Rect.fromPoints(element.points[0], element.points[1]),
            paint,
          );
        }
        break;
      case _DrawTool.circle:
        if (element.points.length >= 2) {
          canvas.drawOval(
            Rect.fromPoints(element.points[0], element.points[1]),
            paint,
          );
        }
        break;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final element in elements) {
      _paintElement(canvas, element);
    }
    if (current != null) {
      _paintElement(canvas, current!);
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}
