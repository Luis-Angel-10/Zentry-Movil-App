import 'package:flutter/material.dart';

class AvatarFrame {
  const AvatarFrame({
    required this.id,
    required this.label,
    required this.colors,
  });

  final String id;
  final String label;
  final List<Color> colors;
}

const List<AvatarFrame> kAvatarFrames = [
  AvatarFrame(
    id: 'default',
    label: 'Zentry',
    colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
  ),
  AvatarFrame(
    id: 'gold',
    label: 'Oro',
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
  ),
  AvatarFrame(
    id: 'ice',
    label: 'Hielo',
    colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
  ),
  AvatarFrame(
    id: 'fire',
    label: 'Fuego',
    colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
  ),
  AvatarFrame(
    id: 'emerald',
    label: 'Esmeralda',
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
  ),
];

List<Color> avatarFrameColors(String? frameId) {
  final frame = kAvatarFrames.firstWhere(
    (f) => f.id == frameId,
    orElse: () => kAvatarFrames.first,
  );
  return frame.colors;
}
