import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../locator.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = getIt<LocationService>();
  
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLocationLoading = false;
  bool _isWithinRange = false;
  String? _locationError;
  double? _distanceFromOffice;

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get isLocationLoading => _isLocationLoading;
  bool get isWithinRange => _isWithinRange;
  String? get locationError => _locationError;
  double? get distanceFromOffice => _distanceFromOffice;

  Future<void> getCurrentLocation() async {
    _setLocationLoading(true);
    try {
      _currentPosition = await _locationService.getCurrentLocation();
      _distanceFromOffice = await _locationService.getDistanceFromOffice(_currentPosition!);
      _isWithinRange = await _locationService.isWithinOfficeRadius(_currentPosition!);
      await _getCurrentAddress();
      _locationError = null;
    } catch (e) {
      _locationError = e.toString();
      _currentPosition = null;
      _currentAddress = null;
      _isWithinRange = false;
      _distanceFromOffice = null;
    } finally {
      _setLocationLoading(false);
    }
  }

  Future<void> _getCurrentAddress() async {
    if (_currentPosition == null) return;
    
    try {
      final address = await _locationService.getAddressFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      _currentAddress = address;
    } catch (e) {
      _currentAddress = 'Address not available';
    }
  }

  Future<bool> requestLocationPermission() async {
    try {
      final permission = await _locationService.requestLocationPermission();
      if (!permission) {
        _locationError = 'Location permission denied';
      }
      notifyListeners();
      return permission;
    } catch (e) {
      _locationError = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _setLocationLoading(bool loading) {
    _isLocationLoading = loading;
    notifyListeners();
  }

  void clearLocationError() {
    _locationError = null;
    notifyListeners();
  }

  void resetLocation() {
    _currentPosition = null;
    _currentAddress = null;
    _isWithinRange = false;
    _distanceFromOffice = null;
    _locationError = null;
    notifyListeners();
  }

  String getLocationStatusMessage() {
    if (_locationError != null) {
      return _locationError!;
    }
    
    if (_currentPosition == null) {
      return 'Location not available';
    }
    
    if (_isWithinRange) {
      return 'You are within office range (${_distanceFromOffice?.toStringAsFixed(0)}m)';
    } else {
      return 'You are outside office range (${_distanceFromOffice?.toStringAsFixed(0)}m away)';
    }
  }
}
