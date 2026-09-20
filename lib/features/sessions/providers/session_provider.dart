import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pesca_app/core/database/database_helper.dart';
import 'package:pesca_app/features/sessions/models/fishing_session.dart';
import 'package:pesca_app/features/weather/models/weather_condition.dart';
import 'package:uuid/uuid.dart';

class SessionState {
  final FishingSession? activeSession;
  final List<FishingSession> allSessions;
  final bool isLoading;

  SessionState({
    this.activeSession,
    this.allSessions = const [],
    this.isLoading = false,
  });

  SessionState copyWith({
    FishingSession? activeSession,
    bool clearActiveSession = false,
    List<FishingSession>? allSessions,
    bool? isLoading,
  }) {
    return SessionState(
      activeSession: clearActiveSession ? null : (activeSession ?? this.activeSession),
      allSessions: allSessions ?? this.allSessions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() {
    loadSessions();
    return SessionState();
  }

  Future<void> loadSessions() async {
    state = state.copyWith(isLoading: true);
    final db = DatabaseHelper.instance;
    final active = await db.getActiveSession();
    final all = await db.getSessions();
    state = state.copyWith(
      activeSession: active,
      clearActiveSession: active == null,
      allSessions: all,
      isLoading: false,
    );
  }

  Future<FishingSession> startSession({
    String? locationName,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    final newSession = FishingSession(
      id: const Uuid().v4(),
      startTime: DateTime.now(),
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      notes: notes,
      isActive: true,
    );

    await DatabaseHelper.instance.insertSession(newSession);
    await loadSessions();
    return newSession;
  }

  Future<void> endActiveSession() async {
    if (state.activeSession == null) return;

    final updated = FishingSession(
      id: state.activeSession!.id,
      startTime: state.activeSession!.startTime,
      endTime: DateTime.now(),
      locationName: state.activeSession!.locationName,
      latitude: state.activeSession!.latitude,
      longitude: state.activeSession!.longitude,
      notes: state.activeSession!.notes,
      isActive: false,
      catches: state.activeSession!.catches,
      weather: state.activeSession!.weather,
    );

    await DatabaseHelper.instance.updateSession(updated);
    await loadSessions();
  }

  Future<void> saveWeatherForActiveSession(WeatherCondition weather) async {
    if (state.activeSession == null) return;
    final weatherWithId = WeatherCondition(
      id: const Uuid().v4(),
      sessionId: state.activeSession!.id,
      weather: weather.weather,
      wind: weather.wind,
      waterCondition: weather.waterCondition,
      temperatureC: weather.temperatureC,
      moonPhase: weather.moonPhase,
      pressureHpa: weather.pressureHpa,
      notes: weather.notes,
    );
    await DatabaseHelper.instance.saveWeather(weatherWithId);
    await loadSessions();
  }

  Future<void> deleteSession(String id) async {
    await DatabaseHelper.instance.deleteSession(id);
    await loadSessions();
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);
