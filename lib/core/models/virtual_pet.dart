class PetSpecies {
  final String id;
  final String emoji;
  final int price;

  const PetSpecies({
    required this.id,
    required this.emoji,
    required this.price,
  });
}

enum PetMood { ecstatic, happy, neutral, sad, critical }

enum PetStage { baby, young, adult }

const List<PetSpecies> kPetSpecies = [
  PetSpecies(id: 'cat', emoji: '🐱', price: 250),
  PetSpecies(id: 'dog', emoji: '🐶', price: 250),
  PetSpecies(id: 'dragon', emoji: '🐉', price: 500),
  PetSpecies(id: 'panda', emoji: '🐼', price: 400),
];

class VirtualPet {
  final String speciesId;
  final String name;
  final int xp;
  final int hunger;
  final int happiness;
  final DateTime lastInteractionAt;

  const VirtualPet({
    required this.speciesId,
    required this.name,
    required this.xp,
    required this.hunger,
    required this.happiness,
    required this.lastInteractionAt,
  });

  int get level => 1 + xp ~/ 50;

  double get levelProgress => (xp % 50) / 50;

  String get emoji => kPetSpecies
      .firstWhere((s) => s.id == speciesId, orElse: () => kPetSpecies.first)
      .emoji;

  PetStage get stage {
    if (level <= 2) return PetStage.baby;
    if (level <= 5) return PetStage.young;
    return PetStage.adult;
  }

  PetMood get mood {
    final avg = (hunger + happiness) / 2;
    if (avg >= 85) return PetMood.ecstatic;
    if (avg >= 60) return PetMood.happy;
    if (avg >= 35) return PetMood.neutral;
    if (avg >= 15) return PetMood.sad;
    return PetMood.critical;
  }

  VirtualPet copyWith({
    String? name,
    int? xp,
    int? hunger,
    int? happiness,
    DateTime? lastInteractionAt,
  }) {
    return VirtualPet(
      speciesId: speciesId,
      name: name ?? this.name,
      xp: xp ?? this.xp,
      hunger: hunger ?? this.hunger,
      happiness: happiness ?? this.happiness,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'speciesId': speciesId,
    'name': name,
    'xp': xp,
    'hunger': hunger,
    'happiness': happiness,
    'lastInteractionAt': lastInteractionAt.toIso8601String(),
  };

  factory VirtualPet.fromJson(Map<String, dynamic> json) => VirtualPet(
    speciesId: json['speciesId'] as String,
    name: json['name'] as String,
    xp: json['xp'] as int,
    hunger: json['hunger'] as int,
    happiness: json['happiness'] as int,
    lastInteractionAt: DateTime.parse(json['lastInteractionAt'] as String),
  );
}
