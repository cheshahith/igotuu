import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Abstract routing interface.
/// Easily swappable with Google Directions API, Routes API, or OSRM.
abstract class RoutingService {
  Future<List<LatLng>> getRoute({
    required LatLng origin,
    required LatLng destination,
  });
}

/// Mock routing service that interpolates a realistic, curved street route with turn waypoints.
class MockRoutingService implements RoutingService {
  final String? directionsApiKey;

  const MockRoutingService({this.directionsApiKey});

  @override
  Future<List<LatLng>> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    // If a directions API key is configured in the future, we could call Google Directions API here.
    // In mock mode, we generate a high-fidelity curved street path.
    return _generateCurvedPath(origin, destination);
  }

  /// Generates a realistic curved path simulating city streets and turns
  List<LatLng> _generateCurvedPath(LatLng start, LatLng end) {
    const totalSteps = 24;
    final path = <LatLng>[];

    final dLat = end.latitude - start.latitude;
    final dLng = end.longitude - start.longitude;

    // Normal vector perpendicular to the direct vector for street curvature
    final normalLat = -dLng;
    final normalLng = dLat;

    for (int i = 0; i <= totalSteps; i++) {
      final t = i / totalSteps;

      // Linear interpolation base
      final baseLat = start.latitude + (dLat * t);
      final baseLng = start.longitude + (dLng * t);

      // Arc curvature + subtle street turn sine wave
      final curveIntensity = 0.22 * math.sin(t * math.pi);
      final turnWave = 0.08 * math.sin(t * 3.0 * math.pi);
      final offsetFactor = curveIntensity + turnWave;

      final lat = baseLat + (normalLat * offsetFactor);
      final lng = baseLng + (normalLng * offsetFactor);

      path.add(LatLng(lat, lng));
    }

    return path;
  }
}
