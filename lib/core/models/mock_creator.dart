import 'package:flutter/material.dart';

class MockCreator {
  final String name;
  final String role;
  final Color color;

  const MockCreator({
    required this.name,
    required this.role,
    required this.color,
  });
}

const List<MockCreator> kMockCreators = [
  MockCreator(
    name: 'Ana Torres',
    role: 'Arte Digital',
    color: Colors.pinkAccent,
  ),
  MockCreator(name: 'Carlos Ruiz', role: 'GameDev', color: Colors.blueAccent),
  MockCreator(
    name: 'María López',
    role: 'Fotografía',
    color: Colors.orangeAccent,
  ),
  MockCreator(name: 'Alex Rivera', role: 'Música', color: Colors.purpleAccent),
  MockCreator(
    name: 'Fernanda Ruiz',
    role: 'Diseño UI',
    color: Colors.tealAccent,
  ),
  MockCreator(
    name: 'Daniel Vega',
    role: 'Animación',
    color: Colors.deepOrangeAccent,
  ),
];

List<MockCreator> searchMockCreators(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  return kMockCreators
      .where(
        (c) =>
            c.name.toLowerCase().contains(q) ||
            c.role.toLowerCase().contains(q),
      )
      .toList();
}
