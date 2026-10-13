import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Worker model representing a trade professional near the user
class WorkerModel {
  final String id;
  final String name;
  final String trade;
  final double rating;
  final int reviewCount;
  final int visitFee; // in Rupees (e.g., ₹99, ₹149)
  final int hourlyRate; // in Rupees (e.g., ₹349, ₹420)
  final double distanceKm;
  final int etaMinutes;
  final LatLng location;
  final Color avatarColor;
  final bool isVerified;
  final String phone;

  const WorkerModel({
    required this.id,
    required this.name,
    required this.trade,
    required this.rating,
    required this.reviewCount,
    required this.visitFee,
    required this.hourlyRate,
    required this.distanceKm,
    required this.etaMinutes,
    required this.location,
    this.avatarColor = const Color(0xFFDCE7D6),
    this.isVerified = true,
    this.phone = '+91 98421 55432',
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'W';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get formattedVisitFee => '₹$visitFee';
  String get formattedHourlyRate => '₹$hourlyRate/hr';
  String get formattedDistance => '${distanceKm.toStringAsFixed(1)} km';
  String get formattedEta => '$etaMinutes mins';

  WorkerModel copyWith({
    String? id,
    String? name,
    String? trade,
    double? rating,
    int? reviewCount,
    int? visitFee,
    int? hourlyRate,
    double? distanceKm,
    int? etaMinutes,
    LatLng? location,
    Color? avatarColor,
    bool? isVerified,
    String? phone,
  }) {
    return WorkerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      trade: trade ?? this.trade,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      visitFee: visitFee ?? this.visitFee,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      distanceKm: distanceKm ?? this.distanceKm,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      location: location ?? this.location,
      avatarColor: avatarColor ?? this.avatarColor,
      isVerified: isVerified ?? this.isVerified,
      phone: phone ?? this.phone,
    );
  }
}
