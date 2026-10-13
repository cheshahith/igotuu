import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/frosted_glass.dart';
import '../domain/models/worker_model.dart';
import 'controllers/nearby_controller.dart';
import 'widgets/custom_marker_generator.dart';
import 'widgets/map_view_widget.dart';

/// Full-screen Rapido-style "Nearby Workers" map flow.
/// Features live Google Maps tracking, custom runtime bitmap markers,
/// interactive glass bottom sheets, requesting pulse, and live arrival states.
class NearbyWorkersScreen extends StatefulWidget {
  final String trade;

  const NearbyWorkersScreen({
    super.key,
    this.trade = 'Electrician',
  });

  @override
  State<NearbyWorkersScreen> createState() => _NearbyWorkersScreenState();
}

class _NearbyWorkersScreenState extends State<NearbyWorkersScreen>
    with TickerProviderStateMixin {
  // Coimbatore default fallback coordinates per prompt
  static const LatLng _defaultCoimbatore = LatLng(11.0168, 76.9558);

  LatLng _userPosition = _defaultCoimbatore;
  bool _isLoadingLocation = true;

  late NearbyController _controller;
  GoogleMapController? _mapController;

  // Pulsing circle animation during `requesting` state
  late final AnimationController _pulseController;
  late final Animation<double> _pulseRadiusAnimation;

  // Custom marker cache
  final Map<String, BitmapDescriptor> _cachedDescriptors = {};

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _pulseRadiusAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOutQuad,
    );

    _initFlow();
  }

  Future<void> _initFlow() async {
    // 1. Resolve user location with graceful fallback
    final loc = await _resolveUserLocation();
    _userPosition = loc;

    // 2. Initialize controller
    _controller = NearbyController(
      trade: widget.trade,
      userLocation: _userPosition,
    );
    _controller.addListener(_onControllerUpdate);

    await _controller.init();

    // 3. Pre-generate custom marker bitmaps
    await _prepareMarkerDescriptors();

    if (mounted) {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<LatLng> _resolveUserLocation() async {
    try {
      // 1. Geolocator for real GPS position
      final position = await LocationService.instance.getCurrentPosition();
      if (position != null) {
        return LatLng(position.latitude, position.longitude);
      }

      // 2. Fall back to saved address from Home (shared_preferences)
      final savedAddress = await LocationService.instance.getSavedAddress();
      final coords = await LocationService.instance.getCoordinatesForAddress(savedAddress);
      if (coords != null && coords['latitude'] != null && coords['longitude'] != null) {
        return LatLng(coords['latitude']!, coords['longitude']!);
      }

      // 3. Fall back to default location in Coimbatore
      return _defaultCoimbatore;
    } catch (_) {
      return _defaultCoimbatore;
    }
  }

  Future<void> _prepareMarkerDescriptors() async {
    for (final worker in _controller.workers) {
      _cachedDescriptors['${worker.id}_false'] =
          await CustomMarkerGenerator.getWorkerMarker(
        worker: worker,
        isSelected: false,
      );
      _cachedDescriptors['${worker.id}_true'] =
          await CustomMarkerGenerator.getWorkerMarker(
        worker: worker,
        isSelected: true,
      );
    }
  }

  void _onControllerUpdate() {
    if (!mounted) return;

    // If worker is on the way, frame user and worker in camera
    if (_controller.state == NearbyScreenState.onTheWay &&
        _controller.workerCurrentLocation != null) {
      _fitCameraToWorkerAndUser();
    }

    setState(() {});
  }

  void _fitCameraToWorkerAndUser() {
    if (_mapController == null || _controller.workerCurrentLocation == null) {
      return;
    }

    final workerLoc = _controller.workerCurrentLocation!;
    final minLat = math.min(_userPosition.latitude, workerLoc.latitude);
    final maxLat = math.max(_userPosition.latitude, workerLoc.latitude);
    final minLng = math.min(_userPosition.longitude, workerLoc.longitude);
    final maxLng = math.max(_userPosition.longitude, workerLoc.longitude);

    final bounds = LatLngBounds(
      southwest: LatLng(minLat - 0.003, minLng - 0.003),
      northeast: LatLng(maxLat + 0.003, maxLng + 0.003),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  void _reCenterOnUser() {
    if (_mapController == null) return;
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _userPosition,
          zoom: 15.2,
        ),
      ),
    );
  }

  void _animateCameraToWorker(WorkerModel worker) {
    if (_mapController == null) return;
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: worker.location,
          zoom: 16.0,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLocation) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.sageDark),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Google Map Full-Screen Layer
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseRadiusAnimation,
              builder: (context, _) {
                return MapViewWidget(
                  initialCameraPosition: CameraPosition(
                    target: _userPosition,
                    zoom: 14.8,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  markers: _buildMapMarkers(),
                  polylines: _buildMapPolylines(),
                  circles: _buildMapCircles(),
                  myLocationEnabled: true,
                );
              },
            ),
          ),

          // 2. Floating Top Bar: Back Button & Title Chip
          _buildFloatingTopBar(),

          // 3. Floating Re-Center Button
          Positioned(
            right: 16,
            bottom: 330,
            child: _buildReCenterButton(),
          ),

          // 4. Debug Simulation Button (in debug builds only)
          if (kDebugMode && _controller.state == NearbyScreenState.onTheWay)
            Positioned(
              right: 16,
              bottom: 395,
              child: _buildDebugSimulationButton(),
            ),

          // 5. Draggable / Dynamic Frosted Glass Bottom Sheet
          _buildDraggableBottomSheet(),
        ],
      ),
    );
  }

  Set<Marker> _buildMapMarkers() {
    final markers = <Marker>{};

    if (_controller.state == NearbyScreenState.browsing) {
      for (final worker in _controller.workers) {
        final isSelected = worker.id == _controller.selectedWorker?.id;
        final descriptor =
            _cachedDescriptors['${worker.id}_$isSelected'] ??
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);

        markers.add(
          Marker(
            markerId: MarkerId(worker.id),
            position: worker.location,
            icon: descriptor,
            anchor: const Offset(0.5, 0.85),
            zIndexInt: isSelected ? 10 : 2,
            onTap: () {
              _controller.selectWorker(worker);
              _animateCameraToWorker(worker);
            },
          ),
        );
      }
    } else if (_controller.state == NearbyScreenState.requesting ||
        _controller.state == NearbyScreenState.onTheWay ||
        _controller.state == NearbyScreenState.arrived) {
      final worker = _controller.selectedWorker;
      if (worker != null) {
        final position = _controller.workerCurrentLocation ?? worker.location;
        final descriptor = _cachedDescriptors['${worker.id}_true'] ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);

        markers.add(
          Marker(
            markerId: MarkerId(worker.id),
            position: position,
            icon: descriptor,
            flat: true,
            rotation: _controller.workerHeading,
            anchor: const Offset(0.5, 0.5),
            zIndexInt: 20,
          ),
        );
      }
    }

    return markers;
  }

  Set<Polyline> _buildMapPolylines() {
    final polylines = <Polyline>{};
    if (_controller.state == NearbyScreenState.onTheWay &&
        _controller.routePoints.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('worker_route'),
          points: _controller.routePoints,
          color: AppColors.sageDark,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );
    }
    return polylines;
  }

  Set<Circle> _buildMapCircles() {
    final circles = <Circle>{};
    if (_controller.state == NearbyScreenState.requesting &&
        _controller.selectedWorker != null) {
      final worker = _controller.selectedWorker!;
      final pulseRadius = 70.0 + (_pulseRadiusAnimation.value * 140.0);
      final alpha = (1.0 - _pulseRadiusAnimation.value).clamp(0.0, 1.0);

      circles.add(
        Circle(
          circleId: const CircleId('requesting_pulse'),
          center: worker.location,
          radius: pulseRadius,
          strokeWidth: 2,
          strokeColor: AppColors.sage.withValues(alpha: alpha * 0.8),
          fillColor: AppColors.sage.withValues(alpha: alpha * 0.25),
        ),
      );
    }
    return circles;
  }

  Widget _buildFloatingTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              Semantics(
                button: true,
                label: 'Go back to Home',
                child: FrostedGlass(
                  borderRadius: 24,
                  blurSigma: 16,
                  padding: EdgeInsets.zero,
                  fillColor: Colors.white.withValues(alpha: 0.55),
                  borderColor: Colors.white.withValues(alpha: 0.8),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.textDark,
                      size: 22,
                    ),
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),

              // Title Chip ("Electricians near you")
              FrostedGlass(
                borderRadius: 20,
                blurSigma: 16,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                fillColor: Colors.white.withValues(alpha: 0.65),
                borderColor: Colors.white.withValues(alpha: 0.85),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: AppColors.sageDark,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.trade}s near you',
                      style: AppTypography.headingSmall(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),

              // Empty placeholder for balance
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReCenterButton() {
    return Semantics(
      button: true,
      label: 'Re-center map on your location',
      child: FrostedGlass(
        borderRadius: 24,
        blurSigma: 16,
        padding: EdgeInsets.zero,
        fillColor: Colors.white.withValues(alpha: 0.65),
        borderColor: Colors.white.withValues(alpha: 0.85),
        child: IconButton(
          icon: const Icon(
            Icons.my_location_rounded,
            color: AppColors.sageDark,
            size: 22,
          ),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: _reCenterOnUser,
        ),
      ),
    );
  }

  Widget _buildDebugSimulationButton() {
    final isPaused = _controller.isSimulationPaused;
    return FrostedGlass(
      borderRadius: 18,
      blurSigma: 16,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      fillColor: Colors.white.withValues(alpha: 0.7),
      borderColor: AppColors.sage,
      child: InkWell(
        onTap: _controller.toggleSimulationPause,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              color: isPaused ? AppColors.recordingRed : AppColors.sageDark,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              isPaused ? 'Resume sim' : 'Pause sim',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isPaused ? AppColors.recordingRed : AppColors.sageDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableBottomSheet() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FrostedGlass(
        borderRadius: 28,
        blurSigma: 24,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        fillColor: Colors.white.withValues(alpha: 0.68),
        borderColor: Colors.white.withValues(alpha: 0.88),
        shadows: const [
          BoxShadow(
            color: Color(0x1A26332A),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
        child: SafeArea(
          top: false,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: _buildSheetContentForState(),
          ),
        ),
      ),
    );
  }

  Widget _buildSheetContentForState() {
    switch (_controller.state) {
      case NearbyScreenState.browsing:
        return _buildBrowsingSheet();
      case NearbyScreenState.requesting:
        return _buildRequestingSheet();
      case NearbyScreenState.onTheWay:
        return _buildOnTheWaySheet();
      case NearbyScreenState.arrived:
        return _buildArrivedSheet();
      case NearbyScreenState.cancelled:
        return _buildBrowsingSheet();
    }
  }

  // --- STATE 1: Browsing ---
  Widget _buildBrowsingSheet() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 330),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textDark.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Busy notice if prior worker declined
          if (_controller.busyNotice != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.recordingRed.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.recordingRed.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.recordingRed,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _controller.busyNotice!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.recordingRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Sort chips row
          Row(
            children: [
              Text(
                'Sort by:',
                style: AppTypography.label(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 8),
              _buildSortChip('Nearest', WorkerSortMode.nearest),
              const SizedBox(width: 6),
              _buildSortChip('Top rated', WorkerSortMode.topRated),
              const SizedBox(width: 6),
              _buildSortChip('Lowest fee', WorkerSortMode.lowestFee),
            ],
          ),

          const SizedBox(height: 10),

          // Horizontal scroll of workers cards
          Flexible(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: _controller.workers.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final worker = _controller.workers[index];
                final isSelected = worker.id == _controller.selectedWorker?.id;
                return _buildWorkerCard(worker, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, WorkerSortMode mode) {
    final isSelected = _controller.sortMode == mode;
    return InkWell(
      onTap: () => _controller.setSortMode(mode),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        constraints: const BoxConstraints(minHeight: 32),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.sageDark
              : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.sageDark : const Color(0x303F5A3E),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkerCard(WorkerModel worker, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.sage.withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? AppColors.sageDark
              : Colors.white.withValues(alpha: 0.75),
          width: isSelected ? 1.8 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.sage.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: InkWell(
        onTap: () {
          _controller.selectWorker(worker);
          _animateCameraToWorker(worker);
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top: Avatar + Name + Verified Badge
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: worker.avatarColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      worker.initials,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              worker.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.headingSmall(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: AppColors.sageDark,
                          ),
                        ],
                      ),
                      Text(
                        '${worker.formattedDistance} • ETA ${worker.formattedEta}',
                        style: AppTypography.bodySmall(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Middle: Rating & Fees breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 15,
                      color: AppColors.starAmber,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${worker.rating}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      ' (${worker.reviewCount})',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'VISIT FEE: ${worker.formattedVisitFee}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      worker.formattedHourlyRate,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.sageDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Bottom: Request button if selected
            if (isSelected)
              SizedBox(
                width: double.infinity,
                height: 38,
                child: ElevatedButton(
                  onPressed: _controller.requestSelectedWorker,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sageDark,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Request ${worker.name.split(' ').first}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
            else
              Text(
                'Tap to select',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted.withValues(alpha: 0.8),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- STATE 2: Request and Waiting ---
  Widget _buildRequestingSheet() {
    final worker = _controller.selectedWorker!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 6),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.sage.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.sageDark,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Waiting for ${worker.name} to accept...',
          style: AppTypography.headingSmall(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Visit fee: ${worker.formattedVisitFee} • Rate: ${worker.formattedHourlyRate}',
          style: AppTypography.bodySmall(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            onPressed: _controller.cancelRequest,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textDark,
              side: BorderSide(color: AppColors.textDark.withValues(alpha: 0.25)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Cancel Request',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  // --- STATE 3: Worker on the Way ---
  Widget _buildOnTheWaySheet() {
    final worker = _controller.selectedWorker!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading with ETA badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${worker.name} is on the way',
                  style: AppTypography.headingSmall(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  '${_controller.remainingDistanceKm.toStringAsFixed(1)} km away • ETA ${_controller.remainingEtaMins} mins',
                  style: AppTypography.bodySmall(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.sageDark,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.sage.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.directions_bike_rounded,
                    size: 14,
                    color: AppColors.sageDark,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_controller.remainingEtaMins}m',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.sageDark,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Worker mini card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.65),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: worker.avatarColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    worker.initials,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worker.name,
                      style: AppTypography.headingSmall(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '★ ${worker.rating} • Visit Fee ${worker.formattedVisitFee}',
                      style: AppTypography.bodySmall(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Action Buttons: Call & Cancel
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Calling ${worker.name} (${worker.phone})...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.call_rounded, size: 18),
                  label: const Text(
                    'Call Worker',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sageDark,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: _controller.cancelRequest,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.recordingRed,
                    side: const BorderSide(color: Color(0x50E05353)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- STATE 4: Arrived ---
  Widget _buildArrivedSheet() {
    final worker = _controller.selectedWorker!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: Color(0xFFD7E5D6),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.sageDark,
            size: 30,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${worker.name} has arrived!',
          style: AppTypography.headingMedium(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your ${widget.trade.toLowerCase()} is outside your premises.',
          style: AppTypography.bodySmall(
            fontSize: 12.5,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Job started! OTP verified with worker.'),
                ),
              );
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sageDark,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Start job',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
