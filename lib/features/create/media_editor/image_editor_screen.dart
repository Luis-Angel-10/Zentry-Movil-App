import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import 'package:Zentry/l10n/generated/app_localizations.dart';

class _AspectOption {
  final String label;
  final double? ratio;
  const _AspectOption(this.label, this.ratio);
}

class ImageEditorScreen extends StatefulWidget {
  final File imageFile;

  const ImageEditorScreen({super.key, required this.imageFile});

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  final GlobalKey _boundaryKey = GlobalKey();

  int _quarterTurns = 0;
  bool _flipH = false;
  double _brightness = 0;
  double _contrast = 1;
  double _saturation = 1;
  double? _aspectRatio;
  bool _saving = false;

  List<_AspectOption> _aspectOptions(AppLocalizations l10n) => [
    _AspectOption(l10n.imageEditorAspectOriginal, null),
    _AspectOption('1:1', 1.0),
    _AspectOption('4:5', 4 / 5),
    _AspectOption('16:9', 16 / 9),
  ];

  List<double> _brightnessContrastMatrix() {
    final t = (1 - _contrast) / 2 * 255 + _brightness * 255;
    return [
      _contrast,
      0,
      0,
      0,
      t,
      0,
      _contrast,
      0,
      0,
      t,
      0,
      0,
      _contrast,
      0,
      t,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  List<double> _saturationMatrix() {
    final sr = (1 - _saturation) * 0.3086;
    final sg = (1 - _saturation) * 0.6094;
    final sb = (1 - _saturation) * 0.0820;
    return [
      sr + _saturation,
      sg,
      sb,
      0,
      0,
      sr,
      sg + _saturation,
      sb,
      0,
      0,
      sr,
      sg,
      sb + _saturation,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final boundary =
          _boundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/zentry_edit_${DateTime.now().microsecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);

      if (mounted) Navigator.pop(context, file);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(l10n.imageEditorTitle),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    l10n.commonSave,
                    style: const TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: RepaintBoundary(
                  key: _boundaryKey,
                  child: AspectRatio(
                    aspectRatio: _aspectRatio ?? 1.0,
                    child: ClipRect(
                      child: ColorFiltered(
                        colorFilter: ColorFilter.matrix(_saturationMatrix()),
                        child: ColorFiltered(
                          colorFilter: ColorFilter.matrix(
                            _brightnessContrastMatrix(),
                          ),
                          child: RotatedBox(
                            quarterTurns: _quarterTurns,
                            child: Transform(
                              alignment: Alignment.center,
                              transform: _flipH
                                  ? Matrix4.diagonal3Values(-1.0, 1.0, 1.0)
                                  : Matrix4.identity(),
                              child: Image.file(
                                widget.imageFile,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.rotate_left,
                          color: Colors.white,
                        ),
                        onPressed: () => setState(
                          () => _quarterTurns = (_quarterTurns + 3) % 4,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.rotate_right,
                          color: Colors.white,
                        ),
                        onPressed: () => setState(
                          () => _quarterTurns = (_quarterTurns + 1) % 4,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.flip, color: Colors.white),
                        onPressed: () => setState(() => _flipH = !_flipH),
                      ),
                    ],
                  ),
                  Row(
                    children: _aspectOptions(l10n).map((opt) {
                      final selected = _aspectRatio == opt.ratio;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(opt.label),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _aspectRatio = opt.ratio),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 6),
                  _slider(
                    l10n.imageEditorBrightness,
                    _brightness,
                    -1,
                    1,
                    (v) => setState(() => _brightness = v),
                  ),
                  _slider(
                    l10n.imageEditorContrast,
                    _contrast,
                    0.5,
                    2,
                    (v) => setState(() => _contrast = v),
                  ),
                  _slider(
                    l10n.imageEditorSaturation,
                    _saturation,
                    0,
                    2,
                    (v) => setState(() => _saturation = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 84,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        Expanded(
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }
}
