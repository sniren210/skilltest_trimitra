import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LocationService {
  // Office location coordinates from environment variables
  double get officeLatitude => double.parse(dotenv.env['OFFICE_LATITUDE'] ?? '-6.200000');
  double get officeLongitude => double.parse(dotenv.env['OFFICE_LONGITUDE'] ?? '106.816666');
  double get validRadius => double.parse(dotenv.env['OFFICE_RADIUS'] ?? '100.0');
  String get officeName => dotenv.env['OFFICE_NAME'] ?? 'Office';
  String get officeAddress => dotenv.env['OFFICE_ADDRESS'] ?? 'Unknown Location';

  Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
    }

    return true;
  }

  Future<Position> getCurrentLocation() async {
    await requestLocationPermission();

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  bool isLocationValid(double latitude, double longitude) {
    double distance = calculateDistance(
      latitude,
      longitude,
      officeLatitude,
      officeLongitude,
    );
    return distance <= validRadius;
  }

  Future<bool> isWithinOfficeRadius(Position position) async {
    double distance = calculateDistance(
      position.latitude,
      position.longitude,
      officeLatitude,
      officeLongitude,
    );
    return distance <= validRadius;
  }

  Future<double> getDistanceFromOffice(Position position) async {
    return calculateDistance(
      position.latitude,
      position.longitude,
      officeLatitude,
      officeLongitude,
    );
  }

  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        List<String> addressParts = [];

        if (place.name != null && place.name!.isNotEmpty) {
          addressParts.add(place.name!);
        }
        if (place.street != null && place.street!.isNotEmpty && place.street != place.name) {
          addressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }

        if (addressParts.isNotEmpty) {
          return addressParts.join(', ');
        }
      }
    } catch (e) {
      // Handle error silently
    }
    return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
  }

  Map<String, String> getDetailedAddress(Placemark place) {
    return {
      'name': place.name ?? '',
      'street': place.street ?? '',
      'subLocality': place.subLocality ?? '',
      'locality': place.locality ?? '',
      'administrativeArea': place.administrativeArea ?? '',
      'postalCode': place.postalCode ?? '',
      'country': place.country ?? '',
    };
  }
}
