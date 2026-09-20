import 'package:pesca_app/features/catches/models/catch_model.dart';
import 'package:pesca_app/features/weather/models/weather_condition.dart';

class FishingSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final String? notes;
  final bool isActive;
  final List<CatchModel> catches;
  final WeatherCondition? weather;

  FishingSession({
    required this.id,
    required this.startTime,
    this.endTime,
    this.locationName,
    this.latitude,
    this.longitude,
    this.notes,
    this.isActive = true,
    this.catches = const [],
    this.weather,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory FishingSession.fromMap(Map<String, dynamic> map, {List<CatchModel> catches = const [], WeatherCondition? weather}) {
    return FishingSession(
      id: map['id'] as String,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time'] as String) : null,
      locationName: map['location_name'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      catches: catches,
      weather: weather,
    );
  }

  int get totalCatches => catches.length;
  int get totalReleased => catches.where((c) => c.isReleased).length;
  double get maxLen => catches.isEmpty ? 0 : catches.map((c) => c.lengthCm).reduce((a, b) => a > b ? a : b);
}
