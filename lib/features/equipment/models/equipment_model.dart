enum EquipmentType {
  rod, // Vara
  reel, // Carretilha/Molinete
  line, // Linha
  bait, // Isca (Artificial ou Natural)
}

class Equipment {
  final String id;
  final EquipmentType type;
  final String name;
  final String? brand; // Marca
  final String? specs; // Ex: 17lbs 6'0", 0.37mm Fluorocarbono, Isca de Meia Água 9cm
  final String? photoPath;
  final bool isFavorite;

  Equipment({
    required this.id,
    required this.type,
    required this.name,
    this.brand,
    this.specs,
    this.photoPath,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'brand': brand,
      'specs': specs,
      'photo_path': photoPath,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  factory Equipment.fromMap(Map<String, dynamic> map) {
    return Equipment(
      id: map['id'] as String,
      type: EquipmentType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => EquipmentType.rod,
      ),
      name: map['name'] as String,
      brand: map['brand'] as String?,
      specs: map['specs'] as String?,
      photoPath: map['photo_path'] as String?,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
    );
  }

  String get typeLabel {
    switch (type) {
      case EquipmentType.rod:
        return 'Vara';
      case EquipmentType.reel:
        return 'Carretilha/Molinete';
      case EquipmentType.line:
        return 'Linha';
      case EquipmentType.bait:
        return 'Isca';
    }
  }
}
