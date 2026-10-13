import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Status of a booking in igotuu
enum BookingStatus {
  completed,
  pending,
}

/// Booking model representing scheduled or finished appointments
class BookingModel {
  final String id;
  final String providerName;
  final String trade;
  final String issue;
  final DateTime dateTime;
  final String timeSlot;
  final String pricePerHour;
  final BookingStatus status;
  final Color avatarColor;

  const BookingModel({
    required this.id,
    required this.providerName,
    required this.trade,
    required this.issue,
    required this.dateTime,
    required this.timeSlot,
    required this.pricePerHour,
    required this.status,
    this.avatarColor = const Color(0xFFDCE7D6),
  });

  bool get isCompleted => status == BookingStatus.completed;
  bool get isPending => status == BookingStatus.pending;

  /// Extract initials for the provider avatar (e.g., "Rajesh Kumar" -> "RK")
  String get initials {
    final parts = providerName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'P';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Formatted date string (e.g., "Tue, 13 Oct 2026")
  String get formattedDate => DateFormat('EEE, d MMM yyyy').format(dateTime);

  /// Status label text
  String get statusLabel => isCompleted ? 'Completed' : 'Pending';

  /// Copy with helper for state updates
  BookingModel copyWith({
    String? id,
    String? providerName,
    String? trade,
    String? issue,
    DateTime? dateTime,
    String? timeSlot,
    String? pricePerHour,
    BookingStatus? status,
    Color? avatarColor,
  }) {
    return BookingModel(
      id: id ?? this.id,
      providerName: providerName ?? this.providerName,
      trade: trade ?? this.trade,
      issue: issue ?? this.issue,
      dateTime: dateTime ?? this.dateTime,
      timeSlot: timeSlot ?? this.timeSlot,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      status: status ?? this.status,
      avatarColor: avatarColor ?? this.avatarColor,
    );
  }
}
