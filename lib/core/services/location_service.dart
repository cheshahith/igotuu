import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class LocationResult {
  final bool success;
  final String? address;
  final String? errorMessage;

  LocationResult.success(this.address)
      : success = true,
        errorMessage = null;

  LocationResult.failure(this.errorMessage)
      : success = false,
        address = null;
}

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();
  final Geocoding _geocoding = Geocoding();

  /// Retrieve persisted address or default fallback
  Future<String> getSavedAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.prefSavedAddress) ??
          AppConstants.defaultAddress;
    } catch (_) {
      return AppConstants.defaultAddress;
    }
  }

  /// Persist address to SharedPreferences
  Future<bool> saveAddress(String address) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(AppConstants.prefSavedAddress, address);
    } catch (_) {
      return false;
    }
  }

  /// Request GPS and reverse-geocode to human-readable address
  Future<LocationResult> fetchCurrentLocationAddress() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult.failure(
            'Location services are disabled on this device. Please enable GPS.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult.failure(
              'Location permission was denied. You can enter your address manually.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult.failure(
            'Location permissions are permanently denied. Please enable them in app settings or type manually.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );

      final placemarks = await _geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final street = place.street ?? place.name ?? '';
        final subLocality = place.subLocality ?? place.locality ?? '';
        final city = place.locality ?? place.administrativeArea ?? '';
        final postalCode = place.postalCode ?? '';

        final rawParts = <String>[street, subLocality, city, postalCode];
        final parts = rawParts
            .where((part) => part.trim().isNotEmpty)
            .toSet()
            .toList();

        final formattedAddress = parts.isNotEmpty
            ? parts.join(', ')
            : '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';

        return LocationResult.success(formattedAddress);
      } else {
        return LocationResult.success(
            'Lat: ${position.latitude.toStringAsFixed(3)}, Lng: ${position.longitude.toStringAsFixed(3)}');
      }
    } catch (e) {
      return LocationResult.failure(
          'Unable to acquire current location ($e). Please type your address manually.');
    }
  }
}
