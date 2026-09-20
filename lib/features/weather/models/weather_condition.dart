class WeatherCondition {
  final String? id;
  final String? sessionId;
  final String weather; // Ex: Ensolarado, Nublado, Chuvoso, Tempestade
  final String wind; // Ex: Fraco, Moderado, Forte, Sem Vento
  final String waterCondition; // Ex: Limpa, Turva, Barrenta, Salobra, Agitada
  final double? temperatureC;
  final String? moonPhase; // Ex: Nova, Crescente, Cheia, Minguante
  final double? pressureHpa;
  final String? notes;

  WeatherCondition({
    this.id,
    this.sessionId,
    required this.weather,
    required this.wind,
    required this.waterCondition,
    this.temperatureC,
    this.moonPhase,
    this.pressureHpa,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'weather': weather,
      'wind': wind,
      'water_condition': waterCondition,
      'temperature_c': temperatureC,
      'moon_phase': moonPhase,
      'pressure_hpa': pressureHpa,
      'notes': notes,
    };
  }

  factory WeatherCondition.fromMap(Map<String, dynamic> map) {
    return WeatherCondition(
      id: map['id'] as String?,
      sessionId: map['session_id'] as String?,
      weather: map['weather'] as String? ?? 'Ensolarado',
      wind: map['wind'] as String? ?? 'Fraco',
      waterCondition: map['water_condition'] as String? ?? 'Limpa',
      temperatureC: (map['temperature_c'] as num?)?.toDouble(),
      moonPhase: map['moon_phase'] as String?,
      pressureHpa: (map['pressure_hpa'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
    );
  }
}
