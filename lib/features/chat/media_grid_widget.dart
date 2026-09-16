import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'media_viewer_page.dart';

class MediaGridWidget extends StatelessWidget {
  final List<File> files;
  final bool isVideo;

  const MediaGridWidget({
    super.key,
    required this.files,
    required this.isVideo,
  });

  String _heroTag(int index) => 'chat_media_${files[index].path}_$index';

  void _open(BuildContext context, int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, __, ___) => MediaViewerPage(
          files: files,
          initialIndex: index,
          isVideo: isVideo,
          heroTagFor: _heroTag,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (files.length == 1) {
      return SizedBox(
        width: 240,
        height: 240,
        child: mediaItem(context, 0, borderRadius: BorderRadius.circular(18)),
      );
    }

    if (files.length == 2) {
      return SizedBox(
        width: 240,
        height: 160,
        child: Row(
          children: [
            Expanded(
              child: mediaItem(
                context,
                0,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(18),
                ),
              ),
            ),
            const SizedBox(width: 3),
            Expanded(
              child: mediaItem(
                context,
                1,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(18),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (files.length == 3) {
      return SizedBox(
        width: 240,
        height: 200,
        child: Row(
          children: [
            Expanded(
              child: mediaItem(
                context,
                0,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(18),
                ),
              ),
            ),
            const SizedBox(width: 3),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: mediaItem(
                      context,
                      1,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Expanded(
                    child: mediaItem(
                      context,
                      2,
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: 240,
      height: 240,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: files.length > 4 ? 4 : files.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
        ),
        itemBuilder: (_, index) {
          return Stack(
            fit: StackFit.expand,
            children: [
              mediaItem(
                context,
                index,
                borderRadius: BorderRadius.circular(14),
              ),
              if (index == 3 && files.length > 4)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: Text(
                        "+${files.length - 4}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget mediaItem(
    BuildContext context,
    int index, {
    required BorderRadius borderRadius,
  }) {
    final file = files[index];

    return GestureDetector(
      onTap: () => _open(context, index),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Hero(
          tag: _heroTag(index),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (isVideo)
                FutureBuilder<String?>(
                  future: VideoThumbnail.thumbnailFile(
                    video: file.path,
                    imageFormat: ImageFormat.JPEG,
                    quality: 75,
                  ),
                  builder: (_, snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                        color: Colors.black12,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    return Image.file(File(snapshot.data!), fit: BoxFit.cover);
                  },
                )
              else
                Image.file(file, fit: BoxFit.cover),

              if (isVideo)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
