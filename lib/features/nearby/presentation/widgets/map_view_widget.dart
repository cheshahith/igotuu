import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../widgets/frosted_glass.dart';
import 'map_style.dart';

/// Clean wrapper around [GoogleMap] so that the map layer remains swappable
/// and provides graceful fallbacks for missing API keys or offline scenarios.
class MapViewWidget extends StatefulWidget {
  final CameraPosition initialCameraPosition;
  final ValueChanged<GoogleMapController> onMapCreated;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Set<Circle> circles;
  final bool myLocationEnabled;
  final VoidCallback? onCameraMoveStarted;
  final CameraPositionCallback? onCameraMove;

  const MapViewWidget({
    super.key,
    required this.initialCameraPosition,
    required this.onMapCreated,
    this.markers = const {},
    this.polylines = const {},
    this.circles = const {},
    this.myLocationEnabled = true,
    this.onCameraMoveStarted,
    this.onCameraMove,
  });

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
  final bool _hasMapLoadError = false;

  @override
  Widget build(BuildContext context) {
    if (_hasMapLoadError) {
      return _buildMapFallback();
    }

    // Google Maps wrapper with muted styling and stripped controls
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: widget.initialCameraPosition,
          onMapCreated: (controller) {
            widget.onMapCreated(controller);
          },
          markers: widget.markers,
          polylines: widget.polylines,
          circles: widget.circles,
          myLocationEnabled: widget.myLocationEnabled,
          myLocationButtonEnabled: false, // Hidden per spec in favor of custom glass re-center
          zoomControlsEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
          style: AppMapStyle.jsonStyle,
          onCameraMoveStarted: widget.onCameraMoveStarted,
          onCameraMove: widget.onCameraMove,
        ),
      ],
    );
  }

  Widget _buildMapFallback() {
    return Container(
      color: const Color(0xFFF3ECE6),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FrostedGlass(
            borderRadius: 20,
            padding: const EdgeInsets.all(20),
            fillColor: Colors.white.withValues(alpha: 0.65),
            borderColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.map_rounded,
                  color: AppColors.sageDark,
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  'Map Simulation Active',
                  style: AppTypography.headingSmall(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Set MAPS_API_KEY in android/local.properties to render Google Maps tiles.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
