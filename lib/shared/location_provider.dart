import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class LocationProvider extends ChangeNotifier {
  String _postcode = 'No postcode available';

  String get postcode => _postcode;

  void setPostcode(String value) {
    _postcode = value;
    notifyListeners();
  }

  // Start the periodic location updates
  void startLocationUpdates() {
    // Get initial location
    getPostcode();

    // Set up timer to get location every 30 minutes
    Timer.periodic(const Duration(minutes: 30), (timer) {
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
          _postcode = postcode;
        } else {
          _postcode = 'Unknown';
        }
      } else {
        _postcode = 'Location unavailable';
      }
    } catch (e) {
      print('Error getting postcode: $e');
      _postcode = 'Location unavailable';
    }
    setPostcode(_postcode);
    notifyListeners();
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }
}
