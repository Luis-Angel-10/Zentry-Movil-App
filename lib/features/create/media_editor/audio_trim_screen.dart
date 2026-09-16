import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:Zentry/l10n/generated/app_localizations.dart';

class AudioTrimScreen extends StatefulWidget {
  final File audioFile;

  const AudioTrimScreen({super.key, required this.audioFile});

  @override
  State<AudioTrimScreen> createState() => _AudioTrimScreenState();
}

class _AudioTrimScreenState extends State<AudioTrimScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _ready = false;
  double _start = 0;
  double _end = 1;

  @override
  void initState() {
    super.initState();
    _player.setFilePath(widget.audioFile.path).then((duration) {
      if (!mounted || duration == null) return;
      setState(() {
        _ready = true;
        _end = duration.inMilliseconds.toDouble();
      });
      _player.setLoopMode(LoopMode.one);
      _player.play();
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _fmt(double ms) {
    final d = Duration(milliseconds: ms.round());
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalMs = _ready
        ? (_player.duration?.inMilliseconds.toDouble() ?? 1)
        : 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFF07070D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.audioTrimTitle),
        actions: [
          TextButton(
            onPressed: !_ready
                ? null
                : () => Navigator.pop(context, {
                    'start': _start / 1000,
                    'end': _end / 1000,
                  }),
            child: Text(
              l10n.commonSave,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: !_ready
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Spacer(),
                    const Icon(
                      Icons.audiotrack,
                      color: Colors.white54,
                      size: 72,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.trimStartLabel(_fmt(_start)),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          l10n.trimEndLabel(_fmt(_end)),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: RangeValues(_start, _end),
                      min: 0,
                      max: totalMs,
                      onChanged: (values) {
                        setState(() {
                          _start = values.start;
                          _end = values.end;
                        });
                        _player.seek(
                          Duration(milliseconds: values.start.round()),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
