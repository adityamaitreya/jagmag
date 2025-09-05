import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/jagmag_location_service.dart';

class LocationPermissionHelper {
  static Future<bool> requestLocationPermission(BuildContext context) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled =
          await JagmagLocationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context.mounted) {
          _showLocationServiceDialog(context);
        }
        return false;
      }

      // Check current permission
      LocationPermission permission =
          await JagmagLocationService.checkLocationPermission();

      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await JagmagLocationService.requestLocationPermission();

        if (permission == LocationPermission.denied) {
          if (context.mounted) {
            _showPermissionDeniedDialog(context);
          }
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (context.mounted) {
          _showPermissionDeniedForeverDialog(context);
        }
        return false;
      }

      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, 'Error requesting location permission: $e');
      }
      return false;
    }
  }

  static void _showLocationServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
            'Please enable location services in your device settings to use this feature.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'This app needs location permission to report streetlight issues accurately. Please grant location permission.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                requestLocationPermission(context);
              },
              child: const Text('Try Again'),
            ),
          ],
        );
      },
    );
  }

  static void _showPermissionDeniedForeverDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Permanently Denied'),
          content: const Text(
            'Location permission has been permanently denied. Please go to Settings > Apps > Jagmag > Permissions and enable location access.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Error'),
          content: Text(error),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
