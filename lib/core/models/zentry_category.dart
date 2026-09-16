import 'package:flutter/material.dart';

class CategoryGroup {
  final String name;
  final String emoji;
  final IconData icon;
  final Color color;
  final List<String> subcategories;

  const CategoryGroup({
    required this.name,
    required this.emoji,
    required this.icon,
    required this.color,
    required this.subcategories,
  });
}

class CategoryMatch {
  final CategoryGroup group;
  final String subcategory;

  const CategoryMatch({required this.group, required this.subcategory});
}

const List<CategoryGroup> kZentryCategoryGroups = [
  CategoryGroup(
    name: 'Artes visuales y plásticas',
    emoji: '🎨',
    icon: Icons.palette,
    color: Color(0xFF9C27B0),
    subcategories: [
      'Dibujo',
      'Pintura',
      'Ilustración',
      'Acuarela',
      'Óleo',
      'Acrílico',
      'Grabado',
      'Collage',
      'Arte digital',
      'Arte urbano',
      'Grafiti',
      'Muralismo',
      'Escultura',
      'Cerámica',
      'Modelado',
      'Arte abstracto',
      'Arte conceptual',
      'Instalaciones artísticas',
    ],
  ),
  CategoryGroup(
    name: 'Artes manuales y artesanías',
    emoji: '🧵',
    icon: Icons.content_cut,
    color: Color(0xFFA1887F),
    subcategories: [
      'Bordado',
      'Tejido',
      'Crochet',
      'Costura creativa',
      'Patchwork',
      'Macramé',
      'Bisutería',
      'Joyería artesanal',
      'Alfarería',
      'Artesanía',
      'Trabajo en madera',
      'Tallado',
      'Carpintería artística',
      'Trabajo en cuero',
      'Papel maché',
      'Origami',
      'Manualidades con papel',
      'Velas artesanales',
      'Jabones artesanales',
      'Restauración creativa',
      'Reciclaje artístico',
    ],
  ),
  CategoryGroup(
    name: 'Fotografía y arte visual digital',
    emoji: '📸',
    icon: Icons.photo_camera,
    color: Color(0xFFE53935),
    subcategories: [
      'Fotografía artística',
      'Fotografía de retrato',
      'Fotografía de naturaleza',
      'Fotografía urbana',
      'Fotografía documental',
      'Edición fotográfica',
      'Fotomanipulación',
      'Arte generado digitalmente',
      'Modelado 3D',
      'Renderizado',
      'Arte 3D',
      'Diseño visual',
    ],
  ),
  CategoryGroup(
    name: 'Cine, video y animación',
    emoji: '🎬',
    icon: Icons.movie_creation_outlined,
    color: Color(0xFF3F51B5),
    subcategories: [
      'Cortometrajes',
      'Cine independiente',
      'Producción audiovisual',
      'Videografía',
      'Edición de video',
      'Animación 2D',
      'Animación 3D',
      'Stop motion',
      'Motion graphics',
      'Videos musicales',
      'Documentales',
      'Dirección audiovisual',
    ],
  ),
  CategoryGroup(
    name: 'Música y arte sonoro',
    emoji: '🎵',
    icon: Icons.music_note,
    color: Color(0xFF1E88E5),
    subcategories: [
      'Canto',
      'Composición musical',
      'Interpretación instrumental',
      'Producción musical',
      'Composición de letras',
      'Música electrónica',
      'Beatmaking',
      'DJ',
      'Diseño sonoro',
      'Podcasts creativos',
      'Experimentación sonora',
    ],
  ),
  CategoryGroup(
    name: 'Literatura y expresión escrita',
    emoji: '📚',
    icon: Icons.menu_book,
    color: Color(0xFF43A047),
    subcategories: [
      'Novelas',
      'Cuentos',
      'Poesía',
      'Microcuentos',
      'Ensayos',
      'Guiones',
      'Teatro escrito',
      'Cómics',
      'Manga',
      'Narrativa gráfica',
      'Fanfiction',
      'Letras de canciones',
      'Crónica',
      'Escritura creativa',
    ],
  ),
  CategoryGroup(
    name: 'Artes escénicas y expresión corporal',
    emoji: '💃',
    icon: Icons.theater_comedy,
    color: Color(0xFFD81B60),
    subcategories: [
      'Danza',
      'Ballet',
      'Danza contemporánea',
      'Danza urbana',
      'Teatro',
      'Actuación',
      'Performance',
      'Circo',
      'Acrobacia artística',
      'Mimo',
      'Títeres',
      'Coreografía',
      'Expresión corporal',
    ],
  ),
  CategoryGroup(
    name: 'Videojuegos y creación interactiva',
    emoji: '🎮',
    icon: Icons.sports_esports,
    color: Color(0xFFFB8C00),
    subcategories: [
      'Desarrollo de videojuegos',
      'Diseño de videojuegos',
      'Arte conceptual',
      'Diseño de personajes',
      'Diseño de niveles',
      'Narrativa interactiva',
      'Pixel art',
      'Desarrollo indie',
      'Mods',
      'Experiencias interactivas',
      'Realidad virtual',
      'Realidad aumentada',
    ],
  ),
  CategoryGroup(
    name: 'Diseño y creación aplicada',
    emoji: '👗',
    icon: Icons.design_services,
    color: Color(0xFF00897B),
    subcategories: [
      'Diseño gráfico',
      'Diseño editorial',
      'Diseño de personajes',
      'Diseño de moda',
      'Diseño textil',
      'Diseño de interiores',
      'Diseño industrial',
      'Diseño de producto',
      'Diseño UX/UI',
      'Branding',
      'Tipografía',
      'Diseño web',
    ],
  ),
  CategoryGroup(
    name: 'Arquitectura y espacios creativos',
    emoji: '🏛️',
    icon: Icons.architecture,
    color: Color(0xFF546E7A),
    subcategories: [
      'Arquitectura',
      'Arquitectura conceptual',
      'Maquetas',
      'Diseño de espacios',
      'Paisajismo',
      'Diseño de interiores',
      'Escenografía',
    ],
  ),
  CategoryGroup(
    name: 'Arte culinario',
    emoji: '🍰',
    icon: Icons.cake_outlined,
    color: Color(0xFFF4511E),
    subcategories: [
      'Repostería artística',
      'Decoración de pasteles',
      'Gastronomía creativa',
      'Escultura en alimentos',
      'Presentación gastronómica',
      'Chocolate artístico',
    ],
  ),
  CategoryGroup(
    name: 'Otras expresiones creativas',
    emoji: '🧩',
    icon: Icons.auto_awesome,
    color: Color(0xFF00ACC1),
    subcategories: [
      'Cosplay',
      'Maquillaje artístico',
      'Body paint',
      'Nail art',
      'Customización',
      'Coleccionismo creativo',
      'Dioramas',
      'Miniaturas',
      'Arte con LEGO',
      'Creación de props',
      'Efectos especiales',
      'Arte experimental',
      'Arte tecnológico',
      'Obras interdisciplinarias',
    ],
  ),
];

List<CategoryMatch> searchZentryCategories(String query) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return const [];

  final results = <CategoryMatch>[];
  for (final group in kZentryCategoryGroups) {
    for (final sub in group.subcategories) {
      if (sub.toLowerCase().contains(normalized)) {
        results.add(CategoryMatch(group: group, subcategory: sub));
      }
    }
  }
  return results;
}
