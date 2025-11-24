import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import '../auth/profile_auth.dart';

class LocationProvider extends ChangeNotifier {
  String _postcode = 'No postcode available';
  String _suburb = 'No suburb available';

  String get postcode => _postcode;
  String get suburb => _suburb;

  // Combined suburb and postcode for display
  String get suburbWithPostcode {
    if (_suburb == 'No suburb available' &&
        _postcode == 'No postcode available') {
      return 'No location available';
    } else if (_suburb == 'No suburb available') {
      return _postcode;
    } else if (_postcode == 'No postcode available') {
      return _suburb;
    }
    return '$_suburb ($_postcode)';
  }

  void setPostcode(String value) {
    _postcode = value;
    notifyListeners();
  }

  void setSuburb(String value) {
    _suburb = value;
    notifyListeners();
  }

  void setLocation(String suburb, String postcode) {
    _suburb = suburb;
    _postcode = postcode;
    notifyListeners();
  }

  // Start the periodic location updates
  void startLocationUpdates() {
    // Get initial location
    getPostcode();

    // Set up timer to get location every 30 minutes
    Timer.periodic(const Duration(minutes: 10), (timer) {
      getPostcode();
    });
  }

  Future<void> getPostcode() async {
    try {
      Position? position = await _getCurrentLocation();
      if (position != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          final postcode = placemark.postalCode ?? 'Unknown';
          final suburb =
              placemark.locality ??
              placemark.subLocality ??
              placemark.subAdministrativeArea ??
              'Unknown';

          _postcode = postcode;
          _suburb = suburb;

          // Upload location data to database
          if (suburb != 'Unknown' && postcode != 'Unknown') {
            setLocation(suburb, postcode);
            await ProfileAuth.updateLocation(suburb, postcode);
          }
        } else {
          _postcode = 'Unknown';
          _suburb = 'Unknown';
        }
      } else {
        _postcode = 'Location unavailable';
        _suburb = 'Location unavailable';
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      _postcode = 'Location unavailable';
      _suburb = 'Location unavailable';
    }
    notifyListeners();
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }
}
