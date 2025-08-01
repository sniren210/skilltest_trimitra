import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:skilltest_trimitra/locator.dart';
import '../services/location_service.dart';

class LocationMapWidget extends StatefulWidget {
  final double? userLatitude;
  final double? userLongitude;
  final bool showUserLocation;
  final double height;

  const LocationMapWidget({
    super.key,
    this.userLatitude,
    this.userLongitude,
    this.showUserLocation = true,
    this.height = 300,
  });

  @override
  State<LocationMapWidget> createState() => _LocationMapWidgetState();
}

class _LocationMapWidgetState extends State<LocationMapWidget> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  
  final LocationService _locationService = getIt<LocationService>();

  @override
  void initState() {
    super.initState();
    _setupMapElements();
  }

  @override
  void didUpdateWidget(LocationMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userLatitude != widget.userLatitude ||
        oldWidget.userLongitude != widget.userLongitude) {
      _setupMapElements();
    }
  }

  void _setupMapElements() {
    _markers.clear();
    _circles.clear();

    // Office marker
    _markers.add(
      Marker(
        markerId: const MarkerId('office'),
        position: LatLng(_locationService.officeLatitude, _locationService.officeLongitude),
        infoWindow: InfoWindow(
          title: _locationService.officeName,
          snippet: _locationService.officeAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // Office radius circle
    _circles.add(
      Circle(
        circleId: const CircleId('office_radius'),
        center: LatLng(_locationService.officeLatitude, _locationService.officeLongitude),
        radius: _locationService.validRadius,
        fillColor: Colors.blue.withOpacity(0.2),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      ),
    );

    // User marker if location is available
    if (widget.showUserLocation && 
        widget.userLatitude != null && 
        widget.userLongitude != null) {
      
      bool isInRange = _locationService.isLocationValid(
        widget.userLatitude!,
        widget.userLongitude!,
      );

      _markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: LatLng(widget.userLatitude!, widget.userLongitude!),
          infoWindow: InfoWindow(
            title: 'Your Location',
            snippet: isInRange ? 'Within office radius' : 'Outside office radius',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isInRange ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
          ),
        ),
      );

      // User accuracy circle
      _circles.add(
        Circle(
          circleId: const CircleId('user_accuracy'),
          center: LatLng(widget.userLatitude!, widget.userLongitude!),
          radius: 10, // Approximate GPS accuracy
          fillColor: (isInRange ? Colors.green : Colors.red).withOpacity(0.3),
          strokeColor: isInRange ? Colors.green : Colors.red,
          strokeWidth: 1,
        ),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            if (isDark) {
              controller.setMapStyle(_darkMapStyle);
            }
          },
          initialCameraPosition: CameraPosition(
            target: widget.userLatitude != null && widget.userLongitude != null
                ? LatLng(widget.userLatitude!, widget.userLongitude!)
                : LatLng(_locationService.officeLatitude, _locationService.officeLongitude),
            zoom: 16,
          ),
          markers: _markers,
          circles: _circles,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: true,
          mapToolbarEnabled: false,
          compassEnabled: true,
          tiltGesturesEnabled: false,
          mapType: MapType.normal,
        ),
      ),
    );
  }

  // Dark map style
  static const String _darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#212121"
        }
      ]
    },
    {
      "elementType": "labels.icon",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [
        {
          "color": "#212121"
        }
      ]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "featureType": "road",
      "elementType": "geometry.fill",
      "stylers": [
        {
          "color": "#2c2c2c"
        }
      ]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#000000"
        }
      ]
    }
  ]
  ''';
}
