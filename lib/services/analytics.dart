import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

abstract class AnalyticsEvent {
  String get eventName;
  Map<String, Object> get parameters;
}

abstract class AnalyticsService {
  Future<void> logEvent(AnalyticsEvent event);
  Future<void> setUserProperties(Map<String, dynamic> properties);
  Future<void> setUserId(String? userId);
}

class FirebaseAnalyticsService implements AnalyticsService {
  final FirebaseAnalytics _analytics;

  FirebaseAnalyticsService(this._analytics);

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    await _analytics.logEvent(
      name: event.eventName,
      parameters: event.parameters,
    );
  }

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    for (final entry in properties.entries) {
      await _analytics.setUserProperty(
        name: entry.key,
        value: entry.value?.toString(),
      );
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
  }
}

/// Main analytics wrapper class with static methods
class Analytics {
  static final List<AnalyticsService> _services = [];

  static bool _isInitialized = false;

  static bool _isAllowed() {
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS || kIsWeb;
  }

  /// Initialize analytics services
  static void initialize({
    FirebaseAnalytics? firebaseAnalytics,
    // Add other analytics services as needed
  }) {
    if (!_isAllowed()) {
      print('Analytics not allowed on this platform');
      return;
    }
    if (_isInitialized) {
      print('Analytics already initialized');
      return;
    }

    if (firebaseAnalytics != null) {
      _services.add(FirebaseAnalyticsService(firebaseAnalytics));
    }
    // Initialize other services

    _isInitialized = true;
  }

  /// Log an analytics event
  static Future<void> logEvent(AnalyticsEvent event) async {
    if (!_isAllowed()) {
      print('Analytics not allowed on this platform');
      return;
    }
    _checkInitialization();

    for (final service in _services) {
      try {
        await service.logEvent(event);
      } catch (e) {
        print('Error logging event in ${service.runtimeType}: $e');
      }
    }
  }

  /// Set user properties
  static Future<void> setUserProperties(Map<String, dynamic> properties) async {
    if (!_isAllowed()) {
      print('Analytics not allowed on this platform');
      return;
    }
    _checkInitialization();

    for (final service in _services) {
      try {
        await service.setUserProperties(properties);
      } catch (e) {
        print('Error setting user properties in ${service.runtimeType}: $e');
      }
    }
  }

  /// Set user ID
  static Future<void> setUserId(String? userId) async {
    if (!_isAllowed()) {
      print('Analytics not allowed on this platform');
      return;
    }
    _checkInitialization();

    for (final service in _services) {
      try {
        await service.setUserId(userId);
      } catch (e) {
        print('Error setting user ID in ${service.runtimeType}: $e');
      }
    }
  }

  /// Check if analytics has been initialized
  static void _checkInitialization() {
    if (!_isInitialized) {
      throw StateError(
          'Analytics has not been initialized. Call Analytics.initialize() first.');
    }
  }
}
