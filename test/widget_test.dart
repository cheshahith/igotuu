import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:igotuu/features/bookings/data/bookings_repository.dart';
import 'package:igotuu/features/bookings/domain/models/booking_model.dart';
import 'package:igotuu/features/bookings/presentation/widgets/red_pencil_circle_painter.dart';
import 'package:igotuu/features/nearby/presentation/controllers/nearby_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BookingsRepository Tests', () {
    test('sample data contains at least 8 bookings with both completed and pending items', () {
      final repo = BookingsRepository.instance;
      final all = repo.getAllBookingsNewestFirst();

      expect(all.length, greaterThanOrEqualTo(8));

      final hasCompleted = all.any((b) => b.isCompleted);
      final hasPending = all.any((b) => b.isPending);

      expect(hasCompleted, isTrue);
      expect(hasPending, isTrue);
    });

    test('verifies date marker rules: completed has red circle, pending-only does not', () {
      final repo = BookingsRepository.instance;
      final now = DateTime.now();

      // Past day with both completed and pending: marker rule MUST return true
      final dayBoth = DateTime(now.year, now.month, now.day - 2);
      expect(repo.hasCompletedBookingOn(dayBoth), isTrue);

      // Past day with pending ONLY: marker rule MUST return false
      final dayPendingOnly = DateTime(now.year, now.month, now.day - 4);
      expect(repo.hasCompletedBookingOn(dayPendingOnly), isFalse);
    });

    test('addBooking adds new booking to repository reactively', () {
      final repo = BookingsRepository.instance;
      final initialCount = repo.bookings.length;

      final testBooking = BookingModel(
        id: 'test-new-booking-${DateTime.now().millisecondsSinceEpoch}',
        providerName: 'Test Specialist',
        trade: 'Plumber',
        issue: 'Leak check verification',
        dateTime: DateTime.now(),
        timeSlot: 'Now',
        pricePerHour: '₹300/hr',
        status: BookingStatus.pending,
      );

      repo.addBooking(testBooking);
      expect(repo.bookings.length, equals(initialCount + 1));
      expect(repo.bookings.first.id, equals(testBooking.id));
    });
  });

  group('RedPencilCirclePainter Tests', () {
    test('is deterministic for same date and should not repaint if date unchanged', () {
      final dateA = DateTime(2026, 10, 13);
      final dateB = DateTime(2026, 10, 13);
      final dateC = DateTime(2026, 10, 14);

      final painterA = RedPencilCirclePainter(date: dateA);
      final painterB = RedPencilCirclePainter(date: dateB);
      final painterC = RedPencilCirclePainter(date: dateC);

      expect(painterA.shouldRepaint(painterB), isFalse);
      expect(painterA.shouldRepaint(painterC), isTrue);
    });
  });

  group('NearbyController Tests', () {
    test('initializes workers and drives requesting -> browsing lifecycle', () async {
      final controller = NearbyController(
        trade: 'Electrician',
        userLocation: const LatLng(11.0168, 76.9558),
      );

      await controller.init();
      expect(controller.workers.length, greaterThanOrEqualTo(6));
      expect(controller.state, equals(NearbyScreenState.browsing));
      expect(controller.selectedWorker, isNotNull);

      // Sort mode test
      controller.setSortMode(WorkerSortMode.topRated);
      expect(controller.sortMode, equals(WorkerSortMode.topRated));
      expect(controller.workers.first.rating, greaterThanOrEqualTo(controller.workers.last.rating));

      // Requesting test
      controller.requestSelectedWorker();
      expect(controller.state, equals(NearbyScreenState.requesting));

      // Cancellation test
      controller.cancelRequest();
      expect(controller.state, equals(NearbyScreenState.browsing));

      controller.dispose();
    });
  });
}
