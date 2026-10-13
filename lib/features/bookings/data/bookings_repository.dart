import 'package:flutter/material.dart';
import '../domain/models/booking_model.dart';

/// Repository managing user bookings.
/// Backed by an in-memory reactive store that can be seamlessly replaced with a remote backend/Firestore.
class BookingsRepository {
  BookingsRepository._() {
    _initSampleData();
  }

  static final BookingsRepository instance = BookingsRepository._();

  final ValueNotifier<List<BookingModel>> bookingsNotifier =
      ValueNotifier<List<BookingModel>>([]);

  List<BookingModel> get bookings => bookingsNotifier.value;

  void _initSampleData() {
    final now = DateTime.now();

    // Past day A: 2 days ago (Both a COMPLETED and a PENDING booking on the same day)
    final dayBoth = DateTime(now.year, now.month, now.day - 2);

    // Past day B: 4 days ago (ONLY a PENDING booking in the past)
    final dayPendingOnly = DateTime(now.year, now.month, now.day - 4);

    // Past day C: 6 days ago (Completed booking)
    final dayCompleted1 = DateTime(now.year, now.month, now.day - 6);

    // Past day D: 10 days ago (Completed booking)
    final dayCompleted2 = DateTime(now.year, now.month, now.day - 10);

    // Past day E: In previous month (Completed booking)
    final dayPrevMonth = DateTime(now.year, now.month - 1, 18);

    // Future day: Tomorrow (Pending booking)
    final dayFuture = DateTime(now.year, now.month, now.day + 1);

    // Future day 2: In 3 days (Pending booking)
    final dayFuture2 = DateTime(now.year, now.month, now.day + 3);

    // Past day F: 14 days ago (Completed booking)
    final dayCompleted3 = DateTime(now.year, now.month, now.day - 14);

    final initialList = <BookingModel>[
      // 1. Future Pending booking
      BookingModel(
        id: 'book-001',
        providerName: 'Vikram Sundaram',
        trade: 'Electrician',
        issue: 'Main MCB tripping repeatedly upon powering AC',
        dateTime: DateTime(dayFuture.year, dayFuture.month, dayFuture.day, 10, 0),
        timeSlot: '10:00 AM - 11:30 AM',
        pricePerHour: '₹349/hr',
        status: BookingStatus.pending,
        avatarColor: const Color(0xFFF0DCD3),
      ),

      // 2. Future Pending booking 2
      BookingModel(
        id: 'book-002',
        providerName: 'Karthik Raja',
        trade: 'Plumber',
        issue: 'Bathroom mixer faucet replacement and pipe seal',
        dateTime: DateTime(dayFuture2.year, dayFuture2.month, dayFuture2.day, 15, 0),
        timeSlot: '03:00 PM - 04:30 PM',
        pricePerHour: '₹299/hr',
        status: BookingStatus.pending,
        avatarColor: const Color(0xFFD6E2E9),
      ),

      // 3. Past day Both - COMPLETED booking
      BookingModel(
        id: 'book-003',
        providerName: 'Murugan S.',
        trade: 'Carpenter',
        issue: 'Custom teakwood shoe cabinet door hinge alignment',
        dateTime: DateTime(dayBoth.year, dayBoth.month, dayBoth.day, 11, 30),
        timeSlot: '11:30 AM - 01:00 PM',
        pricePerHour: '₹399/hr',
        status: BookingStatus.completed,
        avatarColor: const Color(0xFFE8D7C8),
      ),

      // 4. Past day Both - PENDING booking on SAME DAY (verifies marker shows)
      BookingModel(
        id: 'book-004',
        providerName: 'Senthil Nathan',
        trade: 'Mechanic',
        issue: 'Brake fluid inspection and front pad adjustment',
        dateTime: DateTime(dayBoth.year, dayBoth.month, dayBoth.day, 16, 0),
        timeSlot: '04:00 PM - 05:30 PM',
        pricePerHour: '₹449/hr',
        status: BookingStatus.pending,
        avatarColor: const Color(0xFFD9E5D6),
      ),

      // 5. Past day Pending ONLY (4 days ago - verifies NO red circle appears)
      BookingModel(
        id: 'book-005',
        providerName: 'Anand Kumar',
        trade: 'Plumber',
        issue: 'Kitchen RO water purifier drainage tube blockage',
        dateTime: DateTime(dayPendingOnly.year, dayPendingOnly.month, dayPendingOnly.day, 14, 0),
        timeSlot: '02:00 PM - 03:00 PM',
        pricePerHour: '₹280/hr',
        status: BookingStatus.pending,
        avatarColor: const Color(0xFFF3E4CB),
      ),

      // 6. Past Completed (6 days ago)
      BookingModel(
        id: 'book-006',
        providerName: 'Rajesh Kumar',
        trade: 'Electrician',
        issue: 'Concealed short circuit repair in living room false ceiling',
        dateTime: DateTime(dayCompleted1.year, dayCompleted1.month, dayCompleted1.day, 9, 30),
        timeSlot: '09:30 AM - 11:00 AM',
        pricePerHour: '₹350/hr',
        status: BookingStatus.completed,
        avatarColor: const Color(0xFFD7E5D6),
      ),

      // 7. Past Completed (10 days ago)
      BookingModel(
        id: 'book-007',
        providerName: 'Dinesh Balan',
        trade: 'Carpenter',
        issue: 'Wardrobe sliding track roller set replacement',
        dateTime: DateTime(dayCompleted2.year, dayCompleted2.month, dayCompleted2.day, 17, 0),
        timeSlot: '05:00 PM - 06:30 PM',
        pricePerHour: '₹380/hr',
        status: BookingStatus.completed,
        avatarColor: const Color(0xFFF4D8DF),
      ),

      // 8. Past Completed (14 days ago)
      BookingModel(
        id: 'book-008',
        providerName: 'Praveen V.',
        trade: 'Mechanic',
        issue: 'Scooter carburetor tuning and spark plug service',
        dateTime: DateTime(dayCompleted3.year, dayCompleted3.month, dayCompleted3.day, 12, 0),
        timeSlot: '12:00 PM - 01:30 PM',
        pricePerHour: '₹420/hr',
        status: BookingStatus.completed,
        avatarColor: const Color(0xFFDFE6DA),
      ),

      // 9. Previous Month Completed
      BookingModel(
        id: 'book-009',
        providerName: 'Saravanan M.',
        trade: 'Plumber',
        issue: 'Overhead water tank automatic float switch setup',
        dateTime: DateTime(dayPrevMonth.year, dayPrevMonth.month, dayPrevMonth.day, 10, 0),
        timeSlot: '10:00 AM - 12:00 PM',
        pricePerHour: '₹320/hr',
        status: BookingStatus.completed,
        avatarColor: const Color(0xFFD6DFEB),
      ),
    ];

    bookingsNotifier.value = initialList;
  }

  /// Add a newly created booking (e.g. from Nearby Workers live request acceptance)
  void addBooking(BookingModel booking) {
    final updated = List<BookingModel>.from(bookingsNotifier.value)..insert(0, booking);
    bookingsNotifier.value = updated;
  }

  /// Retrieve all bookings sorted newest first
  List<BookingModel> getAllBookingsNewestFirst() {
    final list = List<BookingModel>.from(bookingsNotifier.value);
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  /// Retrieve bookings for a specific day
  List<BookingModel> getBookingsForDate(DateTime date) {
    return bookingsNotifier.value.where((b) {
      return b.dateTime.year == date.year &&
          b.dateTime.month == date.month &&
          b.dateTime.day == date.day;
    }).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  /// Check whether a date has at least one COMPLETED booking in the past
  bool hasCompletedBookingOn(DateTime date) {
    return bookingsNotifier.value.any((b) {
      final isSameDay = b.dateTime.year == date.year &&
          b.dateTime.month == date.month &&
          b.dateTime.day == date.day;
      return isSameDay && b.isCompleted;
    });
  }

  /// Check total booking count on a date
  int bookingCountOn(DateTime date) {
    return bookingsNotifier.value.where((b) {
      return b.dateTime.year == date.year &&
          b.dateTime.month == date.month &&
          b.dateTime.day == date.day;
    }).length;
  }
}
