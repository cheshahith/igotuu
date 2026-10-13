import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Abstract live location service interface.
/// Easily swappable with Firebase Firestore live document listener (e.g. workers/{id}/location)
/// or a WebSocket / MQTT channel.
abstract class LiveLocationService {
  Stream<LatLng> streamWorkerLocation({
    required String workerId,
    required List<LatLng> routeWaypoints,
    Duration updateInterval = const Duration(milliseconds: 1400),
  });

  void pause();
  void resume();
  bool get isPaused;
  void stop();
}

/// Mock live location service simulating movement along route waypoints.
/// Fully supports pause/resume to test live marker halt behavior.
class MockLiveLocationService implements LiveLocationService {
  Timer? _timer;
  StreamController<LatLng>? _controller;
  int _currentIndex = 0;
  bool _isPaused = false;
  List<LatLng> _currentRoute = [];

  @override
  bool get isPaused => _isPaused;

  @override
  Stream<LatLng> streamWorkerLocation({
    required String workerId,
    required List<LatLng> routeWaypoints,
    Duration updateInterval = const Duration(milliseconds: 1400),
  }) {
    stop();

    _currentRoute = List<LatLng>.from(routeWaypoints);
    _currentIndex = 0;
    _isPaused = false;

    _controller = StreamController<LatLng>.broadcast(
      onCancel: () {
        _timer?.cancel();
      },
    );

    if (_currentRoute.isEmpty) {
      return _controller!.stream;
    }

    // Emit initial position
    _controller!.add(_currentRoute.first);

    _timer = Timer.periodic(updateInterval, (timer) {
      if (_isPaused) return;

      if (_currentIndex < _currentRoute.length - 1) {
        _currentIndex++;
        if (_controller != null && !_controller!.isClosed) {
          _controller!.add(_currentRoute[_currentIndex]);
        }
      } else {
        timer.cancel();
      }
    });

    return _controller!.stream;
  }

  @override
  void pause() {
    _isPaused = true;
  }

  @override
  void resume() {
    _isPaused = false;
  }

  @override
  void stop() {
    _timer?.cancel();
    _timer = null;
    if (_controller != null && !_controller!.isClosed) {
      _controller!.close();
    }
    _controller = null;
    _currentIndex = 0;
    _isPaused = false;
  }
}
