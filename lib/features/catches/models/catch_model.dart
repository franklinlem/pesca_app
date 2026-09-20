class CatchModel {
  final String id;
  final String sessionId;
  final String species; // Ex: Tucunaré, Robalo, Dourado, Traíra, Tambaqui
  final double lengthCm; // Comprimento em cm
  final double? weightKg; // Peso opcional em kg
  final DateTime timestamp;
  final String? baitUsed; // Isca usada
  final String? technique; // Técnica (Ex: Pincho, Jigging, Pesca de Fundo, Fly)
  final bool isReleased; // Captura e Soltura (Pesque e Solte)
  final String? photoPath;
  final double? latitude;
  final double? longitude;
  final String? notes;
  final String? equipmentId;

  CatchModel({
    required this.id,
    required this.sessionId,
    required this.species,
    required this.lengthCm,
    this.weightKg,
    required this.timestamp,
    this.baitUsed,
    this.technique,
    required this.isReleased,
    this.photoPath,
    this.latitude,
    this.longitude,
    this.notes,
    this.equipmentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'species': species,
      'length_cm': lengthCm,
      'weight_kg': weightKg,
      'timestamp': timestamp.toIso8601String(),
      'bait_used': baitUsed,
      'technique': technique,
      'is_released': isReleased ? 1 : 0,
      'photo_path': photoPath,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
      'equipment_id': equipmentId,
    };
  }

  factory CatchModel.fromMap(Map<String, dynamic> map) {
    return CatchModel(
      id: map['id'] as String,
      sessionId: map['session_id'] as String,
      species: map['species'] as String,
      lengthCm: (map['length_cm'] as num).toDouble(),
      weightKg: (map['weight_kg'] as num?)?.toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
      baitUsed: map['bait_used'] as String?,
      technique: map['technique'] as String?,
      isReleased: (map['is_released'] as int? ?? 1) == 1,
      photoPath: map['photo_path'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
      equipmentId: map['equipment_id'] as String?,
    );
  }
}
