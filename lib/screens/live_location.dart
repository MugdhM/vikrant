import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RealTimeLocationMap extends StatefulWidget {
  const RealTimeLocationMap({Key? key}) : super(key: key);

  @override
  _RealTimeLocationMapState createState() => _RealTimeLocationMapState();
}

class _RealTimeLocationMapState extends State<RealTimeLocationMap> {
  final DatabaseReference _databaseRef =
  FirebaseDatabase.instance.ref('test');
  GoogleMapController? _mapController;

  LatLng? _currentLocation;
  String? _errorMessage;
  Set<Marker> _markers = {}; // Use a Set for markers

  @override
  void initState() {
    super.initState();
    _listenToLocationUpdates();
  }

  void _listenToLocationUpdates() {
    _databaseRef.onValue.listen((event) {
      try {
        final data = event.snapshot.value;

        // Add more robust null and type checking
        if (data is Map) {
          final latitude = _parseDouble(data['lat']);
          final longitude = _parseDouble(data['lng']);

          if (latitude != null && longitude != null) {
            _updateLocation(latitude, longitude);
          } else {
            _handleLocationError("Invalid coordinates");
          }
        } else {
          _handleLocationError("Invalid data format");
        }
      } catch (e) {
        _handleLocationError("Error processing location: ${e.toString()}");
      }
    }, onError: (error) {
      _handleLocationError("Database error: ${error.toString()}");
    });
  }

  // Safe double parsing method
  double? _parseDouble(dynamic value) {
    if (value == null) return null;

    try {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    } catch (e) {
      return null;
    }
  }

  void _updateLocation(double latitude, double longitude) {
    setState(() {
      _currentLocation = LatLng(latitude, longitude);
      _errorMessage = null;

      // Create a new marker set each time
      _markers = {
        Marker(
          markerId: const MarkerId("current_location"),
          position: _currentLocation!,
          infoWindow: const InfoWindow(
            title: "Current Location",
            snippet: "Real-time updates",
          ),
        ),
      };
    });

    // Safely move camera
    _moveMapCamera();
  }

  void _moveMapCamera() {
    if (_mapController != null && _currentLocation != null) {
      try {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(_currentLocation!),
        );
      } catch (e) {
        _handleLocationError("Camera update failed: ${e.toString()}");
      }
    }
  }

  void _handleLocationError(String message) {
    setState(() {
      _errorMessage = message;
      _currentLocation = null;
      _markers.clear();
    });
    // Optionally log the error
    print(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Location Map'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: _buildMapBody(),
    );
  }

  Widget _buildMapBody() {
    if (_currentLocation == null) {
      return Center(
        child: _errorMessage == null
            ? const CircularProgressIndicator()
            : Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _currentLocation!,
        zoom: 15,
      ),
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
      markers: _markers,
      zoomControlsEnabled: true,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}