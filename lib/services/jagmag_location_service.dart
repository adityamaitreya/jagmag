import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class JagmagLocationService {
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return {
            'success': false,
            'error': 'Location permission denied',
          };
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return {
          'success': false,
          'error': 'Location permission permanently denied',
        };
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = 'Unknown Location';
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        address = [
          placemark.street,
          placemark.subLocality,
          placemark.locality,
          placemark.administrativeArea,
        ].where((element) => element != null && element.isNotEmpty).join(', ');
      }

      return {
        'success': true,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
        'timestamp': DateTime.now(),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error getting location: $e',
      };
    }
  }

  static Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        return [
          placemark.street,
          placemark.subLocality,
          placemark.locality,
          placemark.administrativeArea,
        ].where((element) => element != null && element.isNotEmpty).join(', ');
      }

      return 'Unknown Location';
    } catch (e) {
      return 'Location Unavailable';
    }
  }

  static Future<double> calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}
