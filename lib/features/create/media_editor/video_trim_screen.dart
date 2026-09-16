import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:Zentry/l10n/generated/app_localizations.dart';

class VideoTrimScreen extends StatefulWidget {
  final File videoFile;

  const VideoTrimScreen({super.key, required this.videoFile});

  @override
  State<VideoTrimScreen> createState() => _VideoTrimScreenState();
}

class _VideoTrimScreenState extends State<VideoTrimScreen> {
  late final VideoPlayerController _controller;
  bool _ready = false;
  double _start = 0;
  double _end = 1;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _ready = true;
          _end = _controller.value.duration.inMilliseconds.toDouble();
        });
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
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
        ? _controller.value.duration.inMilliseconds.toDouble()
        : 1.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(l10n.videoTrimTitle),
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
            : Column(
                children: [
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
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
                            _controller.seekTo(
                              Duration(milliseconds: values.start.round()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
