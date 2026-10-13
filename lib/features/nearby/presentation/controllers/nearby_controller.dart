import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../bookings/data/bookings_repository.dart';
import '../../../bookings/domain/models/booking_model.dart';
import '../../domain/models/worker_model.dart';
import '../../domain/repositories/worker_repository.dart';
import '../../domain/services/live_location_service.dart';
import '../../domain/services/routing_service.dart';

/// State of the nearby workers map flow
enum NearbyScreenState {
  browsing,
  requesting,
  onTheWay,
  arrived,
  cancelled,
}

/// Sort options for workers sheet
enum WorkerSortMode {
  nearest,
  topRated,
  lowestFee,
}

/// Master controller driving the Rapido-style nearby workers map flow
class NearbyController extends ChangeNotifier {
  final String trade;
  final LatLng userLocation;
  final WorkerRepository workerRepository;
  final RoutingService routingService;
  final LiveLocationService liveLocationService;

  NearbyController({
    required this.trade,
    required this.userLocation,
    this.workerRepository = const MockWorkerRepository(),
    this.routingService = const MockRoutingService(),
    LiveLocationService? liveLocationService,
  }) : liveLocationService = liveLocationService ?? MockLiveLocationService();

  // Internal state
  NearbyScreenState _state = NearbyScreenState.browsing;
  NearbyScreenState get state => _state;

  WorkerSortMode _sortMode = WorkerSortMode.nearest;
  WorkerSortMode get sortMode => _sortMode;

  List<WorkerModel> _allWorkers = [];
  WorkerModel? _selectedWorker;
  WorkerModel? get selectedWorker => _selectedWorker;

  String? _busyNotice;
  String? get busyNotice => _busyNotice;

  // Live tracking fields
  List<LatLng> _routePoints = [];
  List<LatLng> get routePoints => _routePoints;

  LatLng? _workerCurrentLocation;
  LatLng? get workerCurrentLocation => _workerCurrentLocation;

  double _workerHeading = 0.0;
  double get workerHeading => _workerHeading;

  double _remainingDistanceKm = 0.0;
  double get remainingDistanceKm => _remainingDistanceKm;

  int _remainingEtaMins = 0;
  int get remainingEtaMins => _remainingEtaMins;

  bool _isDisposed = false;
  Timer? _requestTimer;
  StreamSubscription<LatLng>? _locationSubscription;

  bool get isSimulationPaused => liveLocationService.isPaused;

  /// Sorted worker list based on current sort chip
  List<WorkerModel> get workers {
    final list = List<WorkerModel>.from(_allWorkers);
    switch (_sortMode) {
      case WorkerSortMode.nearest:
        list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
      case WorkerSortMode.topRated:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case WorkerSortMode.lowestFee:
        list.sort((a, b) => a.visitFee.compareTo(b.visitFee));
        break;
    }
    return list;
  }

  /// Load workers on screen initialization
  Future<void> init() async {
    _allWorkers = await workerRepository.getNearbyWorkers(
      trade: trade,
      userLocation: userLocation,
    );
    if (_allWorkers.isNotEmpty) {
      _selectedWorker = _allWorkers.first;
    }
    notifyListeners();
  }

  /// Change sorting filter
  void setSortMode(WorkerSortMode mode) {
    _sortMode = mode;
    notifyListeners();
  }

  /// Select a worker from map marker or bottom sheet card
  void selectWorker(WorkerModel worker) {
    if (_state != NearbyScreenState.browsing) return;
    _selectedWorker = worker;
    _busyNotice = null;
    notifyListeners();
  }

  /// Tap "Request" button to request selected worker
  void requestSelectedWorker() {
    if (_selectedWorker == null) return;
    _state = NearbyScreenState.requesting;
    _busyNotice = null;
    notifyListeners();

    // Simulate worker decision: after 3.8 seconds, 80% accept, 20% decline
    _requestTimer?.cancel();
    _requestTimer = Timer(const Duration(milliseconds: 3800), () {
      if (_isDisposed) return;

      // 1 in 5 chance (20%) worker is busy
      final isDeclined = math.Random().nextInt(5) == 0;

      if (isDeclined) {
        _state = NearbyScreenState.browsing;
        _busyNotice = '${_selectedWorker!.name} is busy with another job. Please pick another expert.';
        notifyListeners();
      } else {
        _onWorkerAccepted();
      }
    });
  }

  /// Worker accepts request: schedule booking and start live tracking
  Future<void> _onWorkerAccepted() async {
    final worker = _selectedWorker!;
    _state = NearbyScreenState.onTheWay;
    _workerCurrentLocation = worker.location;
    _remainingDistanceKm = worker.distanceKm;
    _remainingEtaMins = worker.etaMinutes;

    // Per requirement: Add a Pending booking to the Bookings repository so it shows on the Bookings screen!
    final now = DateTime.now();
    BookingsRepository.instance.addBooking(
      BookingModel(
        id: 'book-live-${DateTime.now().millisecondsSinceEpoch}',
        providerName: worker.name,
        trade: worker.trade,
        issue: 'Direct on-demand dispatch via Nearby Workers',
        dateTime: now,
        timeSlot: 'Live dispatched (${worker.formattedEta})',
        pricePerHour: worker.formattedHourlyRate,
        status: BookingStatus.pending,
        avatarColor: worker.avatarColor,
      ),
    );

    // Compute route path
    _routePoints = await routingService.getRoute(
      origin: worker.location,
      destination: userLocation,
    );

    notifyListeners();

    // Start live tracking stream
    _locationSubscription?.cancel();
    _locationSubscription = liveLocationService
        .streamWorkerLocation(
          workerId: worker.id,
          routeWaypoints: _routePoints,
          updateInterval: const Duration(milliseconds: 1400),
        )
        .listen((newLocation) {
      if (_isDisposed) return;
      _onLocationUpdate(newLocation);
    });
  }

  /// Handle live marker movement along route
  void _onLocationUpdate(LatLng newLocation) {
    if (_workerCurrentLocation != null) {
      _workerHeading = _calculateHeading(_workerCurrentLocation!, newLocation);
    }
    _workerCurrentLocation = newLocation;

    // Recalculate remaining distance and ETA
    _remainingDistanceKm = _calculateDistanceKm(newLocation, userLocation);
    _remainingEtaMins = math.max(1, (_remainingDistanceKm / 25.0 * 60).round());

    // When worker reaches user (< 35 meters)
    if (_remainingDistanceKm <= 0.035) {
      _state = NearbyScreenState.arrived;
      _routePoints = [];
      _remainingDistanceKm = 0.0;
      _remainingEtaMins = 0;
      liveLocationService.stop();
      _locationSubscription?.cancel();
    }

    notifyListeners();
  }

  /// Toggle pause/resume on simulated location updates (for testing)
  void toggleSimulationPause() {
    if (liveLocationService.isPaused) {
      liveLocationService.resume();
    } else {
      liveLocationService.pause();
    }
    notifyListeners();
  }

  /// Cancel request at any stage
  void cancelRequest() {
    _requestTimer?.cancel();
    _locationSubscription?.cancel();
    liveLocationService.stop();
    _routePoints = [];
    _state = NearbyScreenState.browsing;
    notifyListeners();
  }

  /// Calculate geographic heading (bearing) in degrees
  double _calculateHeading(LatLng from, LatLng to) {
    final dLng = (to.longitude - from.longitude) * math.pi / 180.0;
    final lat1 = from.latitude * math.pi / 180.0;
    final lat2 = to.latitude * math.pi / 180.0;
    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    final headingRad = math.atan2(y, x);
    return (headingRad * 180.0 / math.pi + 360.0) % 360.0;
  }

  /// Calculate Haversine distance in kilometers
  double _calculateDistanceKm(LatLng a, LatLng b) {
    const earthRadiusKm = 6371.0;
    final dLat = (b.latitude - a.latitude) * math.pi / 180.0;
    final dLng = (b.longitude - a.longitude) * math.pi / 180.0;
    final lat1 = a.latitude * math.pi / 180.0;
    final lat2 = b.latitude * math.pi / 180.0;
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLng / 2) * math.sin(dLng / 2);
    return 2 * earthRadiusKm * math.asin(math.sqrt(math.min(1.0, h)));
  }

  @override
  void dispose() {
    _isDisposed = true;
    _requestTimer?.cancel();
    _locationSubscription?.cancel();
    liveLocationService.stop();
    super.dispose();
  }
}
