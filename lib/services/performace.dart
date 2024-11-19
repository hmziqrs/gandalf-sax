import 'package:firebase_performance/firebase_performance.dart';

abstract class PerformanceTrace {
  void start();
  void stop();
  void putAttribute(String name, String value);
  void setMetric(String name, int value);
  Map<String, String> getAttributes();
  int getMetric(String name);
  void incrementMetric(String name, int number);
  void removeAttribute(String name);
}

class FirebasePerformanceTrace implements PerformanceTrace {
  final Trace _trace;

  FirebasePerformanceTrace(this._trace);

  @override
  void start() => _trace.start();

  @override
  void stop() => _trace.stop();

  @override
  void putAttribute(String name, String value) =>
      _trace.putAttribute(name, value);

  @override
  void setMetric(String name, int value) => _trace.setMetric(name, value);

  @override
  Map<String, String> getAttributes() => _trace.getAttributes();

  @override
  int getMetric(String name) => _trace.getMetric(name);

  @override
  void incrementMetric(String name, int number) =>
      _trace.incrementMetric(name, number);

  @override
  void removeAttribute(String name) => _trace.removeAttribute(name);

  Future<T> timeOperation<T>({
    required String name,
    required Future<T> Function() operation,
  }) async {
    final startTime = DateTime.now().millisecondsSinceEpoch;

    try {
      final result = await operation();
      final duration = DateTime.now().millisecondsSinceEpoch - startTime;
      setMetric('${name}_duration', duration);
      return result;
    } catch (e) {
      final duration = DateTime.now().millisecondsSinceEpoch - startTime;
      setMetric('${name}_error_duration', duration);
      rethrow;
    }
  }
}

abstract class PerformanceMonitoring {
  Future<T> trace<T>({
    required String name,
    required Future<T> Function(FirebasePerformanceTrace trace) operation,
    Map<String, String>? attributes,
  });
}

class FirebasePerformanceMonitoring implements PerformanceMonitoring {
  final FirebasePerformance _performance;

  FirebasePerformanceMonitoring([FirebasePerformance? performance])
      : _performance = performance ?? FirebasePerformance.instance;

  @override
  Future<T> trace<T>({
    required String name,
    required Future<T> Function(FirebasePerformanceTrace trace) operation,
    Map<String, String>? attributes,
  }) async {
    final trace = FirebasePerformanceTrace(await _performance.newTrace(name));

    try {
      trace.start();

      // Add initial attributes if any
      attributes?.forEach((key, value) {
        trace.putAttribute(key, value);
      });

      final result = await operation(trace);
      trace.putAttribute('success', 'true');

      return result;
    } catch (e) {
      trace.putAttribute('success', 'false');
      trace.putAttribute('error', e.toString());
      rethrow;
    } finally {
      trace.stop();
    }
  }
}
