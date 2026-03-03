import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:light_sensor/light_sensor.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:sensors_plus/sensors_plus.dart';

final interviewSensorActiveProvider = StateProvider<bool>((ref) => false);

final deviceSensorServiceProvider = Provider<DeviceSensorService>((ref) {
  return const DeviceSensorService();
});

class DeviceSensorService {
  const DeviceSensorService();

  Stream<UserAccelerometerEvent> shakeEventStream() {
    return userAccelerometerEventStream();
  }

  Stream<double> gyroscopeMagnitudeStream() {
    return gyroscopeEventStream().map(_vectorMagnitude);
  }

  Future<bool> hasLightSensor() async {
    try {
      return await LightSensor.hasSensor();
    } catch (_) {
      return false;
    }
  }

  Stream<double> lightLevelStream() {
    return LightSensor.luxStream().map((lux) => lux.toDouble());
  }

  Stream<bool> proximityStateStream() {
    return ProximitySensor.events.map((value) => value > 0).distinct();
  }

  Future<bool> hasProximitySensor() async {
    try {
      return await ProximitySensor.isProximitySensorAvailable();
    } catch (_) {
      return false;
    }
  }

  double _vectorMagnitude(dynamic event) {
    final x = (event.x as num).toDouble();
    final y = (event.y as num).toDouble();
    final z = (event.z as num).toDouble();
    return math.sqrt((x * x) + (y * y) + (z * z));
  }
}

class ShakeDetector {
  ShakeDetector({
    this.threshold = 2.2,
    this.requiredHits = 3,
    this.window = const Duration(milliseconds: 850),
    this.minSpacing = const Duration(milliseconds: 90),
    this.cooldown = const Duration(seconds: 3),
  });

  final double threshold;
  final int requiredHits;
  final Duration window;
  final Duration minSpacing;
  final Duration cooldown;

  final List<DateTime> _hits = <DateTime>[];
  DateTime? _lastTriggerAt;
  DateTime? _lastHitAt;
  int? _lastDirection;

  bool addSample(UserAccelerometerEvent event) {
    final now = DateTime.now();
    final signedStrength = _dominantSignedStrength(event);
    final strength = signedStrength.abs();

    if (strength < threshold) {
      _trim(now);
      return false;
    }

    final direction = signedStrength.isNegative ? -1 : 1;
    final isCoolingDown =
        _lastTriggerAt != null && now.difference(_lastTriggerAt!) < cooldown;
    if (isCoolingDown) {
      return false;
    }

    final tooSoon =
        _lastHitAt != null && now.difference(_lastHitAt!) < minSpacing;
    final didChangeDirection =
        _lastDirection == null || direction != _lastDirection;

    if (tooSoon || !didChangeDirection) {
      _trim(now);
      return false;
    }

    _hits.add(now);
    _lastHitAt = now;
    _lastDirection = direction;
    _trim(now);

    if (_hits.length < requiredHits) {
      return false;
    }

    _lastTriggerAt = now;
    _hits.clear();
    _lastHitAt = null;
    _lastDirection = null;
    return true;
  }

  void _trim(DateTime now) {
    final removed = _hits.where((hit) => now.difference(hit) > window).length;
    _hits.removeWhere((hit) => now.difference(hit) > window);
    if (_hits.isEmpty && removed > 0) {
      _lastHitAt = null;
      _lastDirection = null;
    }
  }

  double _dominantSignedStrength(UserAccelerometerEvent event) {
    final components = <double>[event.x, event.y, event.z];
    components.sort((a, b) => b.abs().compareTo(a.abs()));
    return components.first;
  }
}

class SustainedThresholdMonitor {
  SustainedThresholdMonitor({
    required this.warningThreshold,
    required this.clearThreshold,
    required this.sustainDuration,
    required this.cooldown,
  });

  final double warningThreshold;
  final double clearThreshold;
  final Duration sustainDuration;
  final Duration cooldown;

  DateTime? _thresholdStartedAt;
  DateTime? _lastTriggerAt;
  bool _active = false;

  bool get isActive => _active;

  bool addSample(double value) {
    final now = DateTime.now();

    if (value >= warningThreshold) {
      _thresholdStartedAt ??= now;
      final hasSustained =
          now.difference(_thresholdStartedAt!) >= sustainDuration;
      final isCoolingDown =
          _lastTriggerAt != null && now.difference(_lastTriggerAt!) < cooldown;

      if (hasSustained) {
        _active = true;
        if (!isCoolingDown) {
          _lastTriggerAt = now;
          return true;
        }
      }
      return false;
    }

    if (value <= clearThreshold) {
      _thresholdStartedAt = null;
      _active = false;
    }

    return false;
  }
}
