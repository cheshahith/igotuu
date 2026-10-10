import 'package:flutter/material.dart';

/// Service provider model representing verified professionals
class ProviderModel {
  final String id;
  final String initials;
  final String name;
  final String trade;
  final double rating;
  final int reviewCount;
  final String pricePerHour;
  final String distance;
  final bool isVerified;
  final Color avatarColor;

  const ProviderModel({
    required this.id,
    required this.initials,
    required this.name,
    required this.trade,
    required this.rating,
    required this.reviewCount,
    required this.pricePerHour,
    required this.distance,
    this.isVerified = true,
    required this.avatarColor,
  });
}

/// 8 verified dummy providers near user with realistic home-services trades
class DummyProviders {
  DummyProviders._();

  static const List<ProviderModel> list = [
    ProviderModel(
      id: 'p1',
      initials: 'RK',
      name: 'Rahul Kumar',
      trade: 'Master Plumber',
      rating: 4.9,
      reviewCount: 142,
      pricePerHour: '\$45/hr',
      distance: '0.8 km',
      isVerified: true,
      avatarColor: Color(0xFFDCE7D9),
    ),
    ProviderModel(
      id: 'p2',
      initials: 'SJ',
      name: 'Sarah Jenkins',
      trade: 'Licensed Electrician',
      rating: 4.95,
      reviewCount: 198,
      pricePerHour: '\$55/hr',
      distance: '1.2 km',
      isVerified: true,
      avatarColor: Color(0xFFF9E4EC),
    ),
    ProviderModel(
      id: 'p3',
      initials: 'MV',
      name: 'Marcus Vance',
      trade: 'Custom Carpenter',
      rating: 4.88,
      reviewCount: 115,
      pricePerHour: '\$48/hr',
      distance: '1.7 km',
      isVerified: true,
      avatarColor: Color(0xFFE2EEDF),
    ),
    ProviderModel(
      id: 'p4',
      initials: 'AP',
      name: 'Amit Patel',
      trade: 'Auto & Engine Mechanic',
      rating: 4.92,
      reviewCount: 167,
      pricePerHour: '\$50/hr',
      distance: '2.1 km',
      isVerified: true,
      avatarColor: Color(0xFFF6DEE5),
    ),
    ProviderModel(
      id: 'p5',
      initials: 'ER',
      name: 'Elena Rostova',
      trade: 'Pipe & Fixture Specialist',
      rating: 4.89,
      reviewCount: 89,
      pricePerHour: '\$42/hr',
      distance: '2.5 km',
      isVerified: true,
      avatarColor: Color(0xFFD6E8D4),
    ),
    ProviderModel(
      id: 'p6',
      initials: 'DK',
      name: 'David Kim',
      trade: 'Smart Home Electrician',
      rating: 4.96,
      reviewCount: 210,
      pricePerHour: '\$60/hr',
      distance: '3.0 km',
      isVerified: true,
      avatarColor: Color(0xFFFAE2EB),
    ),
    ProviderModel(
      id: 'p7',
      initials: 'TS',
      name: 'Tariq Siddiqui',
      trade: 'Cabinet & Wood Joiner',
      rating: 4.85,
      reviewCount: 76,
      pricePerHour: '\$46/hr',
      distance: '3.4 km',
      isVerified: true,
      avatarColor: Color(0xFFDEEADA),
    ),
    ProviderModel(
      id: 'p8',
      initials: 'LB',
      name: 'Lucas Bennett',
      trade: 'Brake & Motor Mechanic',
      rating: 4.91,
      reviewCount: 134,
      pricePerHour: '\$52/hr',
      distance: '4.1 km',
      isVerified: true,
      avatarColor: Color(0xFFF4DDE5),
    ),
  ];
}
