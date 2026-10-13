import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/worker_model.dart';

/// Abstract contract for fetching workers.
/// Can be cleanly implemented by Firestore (e.g. workers collection query) or REST backend.
abstract class WorkerRepository {
  Future<List<WorkerModel>> getNearbyWorkers({
    required String trade,
    required LatLng userLocation,
  });
}

/// Mock implementation generating 7 realistic workers per trade distributed around the user.
class MockWorkerRepository implements WorkerRepository {
  const MockWorkerRepository();

  static const Map<String, List<Map<String, dynamic>>> _tradeProfiles = {
    'Electrician': [
      {'name': 'Rajesh Kumar', 'rating': 4.9, 'reviews': 148, 'visit': 99, 'rate': 349, 'color': Color(0xFFD7E5D6)},
      {'name': 'Vikram Sundaram', 'rating': 4.8, 'reviews': 96, 'visit': 149, 'rate': 399, 'color': Color(0xFFF3E4CB)},
      {'name': 'Karthik Raja', 'rating': 4.7, 'reviews': 72, 'visit': 99, 'rate': 299, 'color': Color(0xFFD6E2E9)},
      {'name': 'Sanjay Verma', 'rating': 4.9, 'reviews': 210, 'visit': 199, 'rate': 449, 'color': Color(0xFFE8D7C8)},
      {'name': 'Arun Prakash', 'rating': 4.6, 'reviews': 54, 'visit': 99, 'rate': 280, 'color': Color(0xFFF4D8DF)},
      {'name': 'Ganesh Moorthy', 'rating': 4.8, 'reviews': 118, 'visit': 149, 'rate': 360, 'color': Color(0xFFDFE6DA)},
      {'name': 'Mani Kandan', 'rating': 4.7, 'reviews': 83, 'visit': 99, 'rate': 320, 'color': Color(0xFFE2D9F3)},
    ],
    'Plumber': [
      {'name': 'Murugan S.', 'rating': 4.9, 'reviews': 184, 'visit': 99, 'rate': 320, 'color': Color(0xFFD6E2E9)},
      {'name': 'Anand Kumar', 'rating': 4.8, 'reviews': 130, 'visit': 149, 'rate': 380, 'color': Color(0xFFD7E5D6)},
      {'name': 'Saravanan M.', 'rating': 4.7, 'reviews': 67, 'visit': 99, 'rate': 299, 'color': Color(0xFFF3E4CB)},
      {'name': 'Balamurugan P.', 'rating': 4.9, 'reviews': 204, 'visit': 199, 'rate': 420, 'color': Color(0xFFE8D7C8)},
      {'name': 'Siva Kumar', 'rating': 4.6, 'reviews': 45, 'visit': 99, 'rate': 270, 'color': Color(0xFFF4D8DF)},
      {'name': 'Ramesh Kannan', 'rating': 4.8, 'reviews': 92, 'visit': 149, 'rate': 350, 'color': Color(0xFFDFE6DA)},
      {'name': 'Dharmaraj K.', 'rating': 4.7, 'reviews': 78, 'visit': 99, 'rate': 310, 'color': Color(0xFFE2D9F3)},
    ],
    'Carpenter': [
      {'name': 'Dinesh Balan', 'rating': 4.9, 'reviews': 165, 'visit': 149, 'rate': 399, 'color': Color(0xFFE8D7C8)},
      {'name': 'Kandasamy R.', 'rating': 4.8, 'reviews': 112, 'visit': 99, 'rate': 349, 'color': Color(0xFFF3E4CB)},
      {'name': 'Velumani S.', 'rating': 4.7, 'reviews': 58, 'visit': 99, 'rate': 299, 'color': Color(0xFFD7E5D6)},
      {'name': 'Chandran M.', 'rating': 4.9, 'reviews': 190, 'visit': 199, 'rate': 450, 'color': Color(0xFFD6E2E9)},
      {'name': 'Naveen Kumar', 'rating': 4.6, 'reviews': 42, 'visit': 99, 'rate': 280, 'color': Color(0xFFF4D8DF)},
      {'name': 'Ravichandran T.', 'rating': 4.8, 'reviews': 88, 'visit': 149, 'rate': 370, 'color': Color(0xFFDFE6DA)},
      {'name': 'Shanmugam A.', 'rating': 4.7, 'reviews': 76, 'visit': 99, 'rate': 330, 'color': Color(0xFFE2D9F3)},
    ],
    'Mechanic': [
      {'name': 'Senthil Nathan', 'rating': 4.9, 'reviews': 178, 'visit': 149, 'rate': 420, 'color': Color(0xFFDFE6DA)},
      {'name': 'Praveen V.', 'rating': 4.8, 'reviews': 124, 'visit': 99, 'rate': 349, 'color': Color(0xFFD6E2E9)},
      {'name': 'Mohan Dass', 'rating': 4.7, 'reviews': 69, 'visit': 99, 'rate': 299, 'color': Color(0xFFD7E5D6)},
      {'name': 'Subramani G.', 'rating': 4.9, 'reviews': 215, 'visit': 199, 'rate': 460, 'color': Color(0xFFE8D7C8)},
      {'name': 'Jeyakumar B.', 'rating': 4.6, 'reviews': 51, 'visit': 99, 'rate': 290, 'color': Color(0xFFF4D8DF)},
      {'name': 'Vigneshwaran K.', 'rating': 4.8, 'reviews': 95, 'visit': 149, 'rate': 380, 'color': Color(0xFFF3E4CB)},
      {'name': 'Antony Raj', 'rating': 4.7, 'reviews': 84, 'visit': 99, 'rate': 340, 'color': Color(0xFFE2D9F3)},
    ],
  };

  @override
  Future<List<WorkerModel>> getNearbyWorkers({
    required String trade,
    required LatLng userLocation,
  }) async {
    // Standardize trade lookup key
    final cleanTrade = trade.trim();
    final profileList = _tradeProfiles[cleanTrade] ?? _tradeProfiles['Electrician']!;

    // Fixed radial distribution offsets around user (0.4 km to 2.8 km)
    // 1 degree latitude ~ 111 km. 1 km ~ 0.009 deg.
    final angles = [0.35, 1.25, 2.10, 3.45, 4.20, 5.15, 5.90];
    final distancesKm = [0.5, 0.8, 1.2, 1.6, 2.1, 2.4, 2.8];

    final workers = <WorkerModel>[];

    for (int i = 0; i < profileList.length; i++) {
      final p = profileList[i];
      final angle = angles[i % angles.length];
      final distKm = distancesKm[i % distancesKm.length];

      // Convert km to approximate lat/lng offsets
      final dLat = (distKm / 111.0) * math.sin(angle);
      final dLng = (distKm / (111.0 * math.cos(userLocation.latitude * math.pi / 180.0))) * math.cos(angle);

      final workerLoc = LatLng(
        userLocation.latitude + dLat,
        userLocation.longitude + dLng,
      );

      // ETA estimated at ~25 km/h: eta = (distKm / 25) * 60 mins
      final eta = math.max(3, (distKm / 25.0 * 60).round());

      workers.add(
        WorkerModel(
          id: 'worker-$cleanTrade-$i',
          name: p['name'] as String,
          trade: cleanTrade,
          rating: (p['rating'] as num).toDouble(),
          reviewCount: p['reviews'] as int,
          visitFee: p['visit'] as int,
          hourlyRate: p['rate'] as int,
          distanceKm: distKm,
          etaMinutes: eta,
          location: workerLoc,
          avatarColor: p['color'] as Color,
          isVerified: true,
          phone: '+91 984${20 + i} 554${30 + i}',
        ),
      );
    }

    return workers;
  }
}
