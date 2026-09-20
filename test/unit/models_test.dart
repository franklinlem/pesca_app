import 'package:flutter_test/flutter_test.dart';
import 'package:pesca_app/features/catches/models/catch_model.dart';
import 'package:pesca_app/features/equipment/models/equipment_model.dart';
import 'package:pesca_app/features/sessions/models/fishing_session.dart';
import 'package:pesca_app/features/weather/models/weather_condition.dart';

void main() {
  group('Model Serialization Tests', () {
    test('CatchModel toMap e fromMap', () {
      final now = DateTime.now();
      final catchModel = CatchModel(
        id: 'catch-123',
        sessionId: 'session-456',
        species: 'Tucunaré-Açú',
        lengthCm: 65.5,
        weightKg: 4.8,
        timestamp: now,
        baitUsed: 'Shiner 90',
        technique: 'Pincho de Superfície',
        isReleased: true,
        latitude: -13.1234,
        longitude: -50.5678,
      );

      final map = catchModel.toMap();
      final deserialized = CatchModel.fromMap(map);

      expect(deserialized.id, equals('catch-123'));
      expect(deserialized.species, equals('Tucunaré-Açú'));
      expect(deserialized.lengthCm, equals(65.5));
      expect(deserialized.weightKg, equals(4.8));
      expect(deserialized.isReleased, isTrue);
      expect(deserialized.latitude, equals(-13.1234));
    });

    test('Equipment toMap e fromMap', () {
      final eq = Equipment(
        id: 'eq-1',
        type: EquipmentType.rod,
        name: 'Vara Venom 17lbs',
        brand: 'Marine Sports',
        specs: '6\'0" Fast Action',
      );

      final map = eq.toMap();
      final deserialized = Equipment.fromMap(map);

      expect(deserialized.id, equals('eq-1'));
      expect(deserialized.type, equals(EquipmentType.rod));
      expect(deserialized.name, equals('Vara Venom 17lbs'));
      expect(deserialized.typeLabel, equals('Vara'));
    });

    test('WeatherCondition toMap e fromMap', () {
      final weather = WeatherCondition(
        weather: 'Ensolarado',
        wind: 'Fraco',
        waterCondition: 'Limpa',
        temperatureC: 32.0,
        moonPhase: 'Crescente',
      );

      final map = weather.toMap();
      final deserialized = WeatherCondition.fromMap(map);

      expect(deserialized.weather, equals('Ensolarado'));
      expect(deserialized.wind, equals('Fraco'));
      expect(deserialized.temperatureC, equals(32.0));
    });

    test('FishingSession stats calculados', () {
      final session = FishingSession(
        id: 'sess-1',
        startTime: DateTime.now(),
        locationName: 'Rio Araguaia',
        catches: [
          CatchModel(
            id: 'c1',
            sessionId: 'sess-1',
            species: 'Tucunaré',
            lengthCm: 40.0,
            timestamp: DateTime.now(),
            isReleased: true,
          ),
          CatchModel(
            id: 'c2',
            sessionId: 'sess-1',
            species: 'Dourado',
            lengthCm: 70.0,
            timestamp: DateTime.now(),
            isReleased: true,
          ),
          CatchModel(
            id: 'c3',
            sessionId: 'sess-1',
            species: 'Traíra',
            lengthCm: 30.0,
            timestamp: DateTime.now(),
            isReleased: false,
          ),
        ],
      );

      expect(session.totalCatches, equals(3));
      expect(session.totalReleased, equals(2));
      expect(session.maxLen, equals(70.0));
    });
  });
}
