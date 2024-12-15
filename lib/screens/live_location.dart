import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

class RealTimeLocationMap extends StatefulWidget {
  const RealTimeLocationMap({Key? key}) : super(key: key);

  @override
  _RealTimeLocationMapState createState() => _RealTimeLocationMapState();
}

class _RealTimeLocationMapState extends State<RealTimeLocationMap> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref('test');
  final DatabaseReference _pathRef = FirebaseDatabase.instance.ref('path_tracking');
  GoogleMapController? _mapController;

  LatLng? _currentLocation;
  String? _errorMessage;
  Set<Marker> _markers = {};

  // Path track
  List<LatLng> _pathPoints = [];
  Set<Polyline> _pathPolylines = {};
  bool _isTracking = false;
  DateTime? _trackingStartTime;
  double _totalDistance = 0.0;

  // Geofencing
  LatLng _geofenceCenter = LatLng(21.1912, 81.2996);
  double _geofenceRadius = 100.0; // in meters
  Set<Circle> _geofenceCircles = {};
  bool _isInsideGeofence = false;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _listenToLocationUpdates();
    _setupGeofence();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message: ${message.notification?.title}');
    });
  }

  void _setupGeofence() {
    setState(() {
      _geofenceCircles = {
        Circle(
          circleId: const CircleId('geofence'),
          center: LatLng(21.1913, 81.2998), // Center of the geofence
          radius: 30.0, // Radius in meters
          strokeColor: Colors.red.withOpacity(0.5),
          fillColor: Colors.red.withOpacity(0.2),
          strokeWidth: 2,
        )
      };
    });


  _moveMapCameraToGeofence();
  }

  void _moveMapCameraToGeofence() {
    if (_mapController != null) {
      double radiusInDegrees = _geofenceRadius / 111000.0; // Approx conversion for 1 degree ~ 111 km
      LatLng southwest = LatLng(
        _geofenceCenter.latitude - radiusInDegrees,
        _geofenceCenter.longitude - radiusInDegrees,
      );
      LatLng northeast = LatLng(
        _geofenceCenter.latitude + radiusInDegrees,
        _geofenceCenter.longitude + radiusInDegrees,
      );

      LatLngBounds bounds = LatLngBounds(southwest: southwest, northeast: northeast);

      // Move camera to the geofence bounds
      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50)).then((_) {
        // Set a custom zoom level explicitly
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _geofenceCenter,
              zoom: 17.0, // Adjust zoom level here
            ),
          ),
        );
      });
    }
  }



  void _startTracking() {
    setState(() {
      _isTracking = true;
      _pathPoints.clear();
      _pathPolylines.clear();
      _totalDistance = 0.0;
      _trackingStartTime = DateTime.now();

      if (_currentLocation != null) {
        _pathPoints.add(_currentLocation!);
      }
    });
  }

  void _stopTracking() {
    setState(() {
      _isTracking = false;
      _trackingStartTime = null;

      _saveFinalPathToFirebase();
    });
    _showTrackingSummary();
  }

  void _saveFinalPathToFirebase() {
    if (_pathPoints.isNotEmpty) {
      final pathId = _pathRef.push().key;
      _pathRef.child(pathId!).set({
        'points': _pathPoints.map((point) => {
          'lat': point.latitude,
          'lng': point.longitude,
        }).toList(),
        'startTime': _trackingStartTime?.toIso8601String(),
        'endTime': DateTime.now().toIso8601String(),
        'totalDistance': _totalDistance,
      });
    }
  }

  void _fetchHistoricalPaths() async {
    try {
      final snapshot = await _pathRef.get();
      if (snapshot.exists) {
        final historicalPaths = snapshot.value as Map?;

        if (historicalPaths != null) {
          List<Polyline> historicalPolylines = [];

          historicalPaths.forEach((key, pathData) {
            if (pathData is Map) {
              List<LatLng> points = (pathData['points'] as List)
                  .map((point) => LatLng(
                point['lat'] as double,
                point['lng'] as double,
              ))
                  .toList();

              historicalPolylines.add(
                Polyline(
                  polylineId: PolylineId('historical_path_$key'),
                  points: points,
                  color: Colors.grey,
                  width: 3,
                ),
              );
            }
          });

          setState(() {
            _pathPolylines.addAll(historicalPolylines);
          });
        }
      }
    } catch (e) {
      print('Error fetching historical paths: $e');
    }
  }

  void _showTrackingSummary() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tracking Summary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Distance: ${_totalDistance.toStringAsFixed(2)} km'),
              Text('Duration: ${_calculateTrackedDuration()}'),
              Text('Total Points: ${_pathPoints.length}'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  String _calculateTrackedDuration() {
    if (_trackingStartTime == null) return '0 mins';

    final duration = DateTime.now().difference(_trackingStartTime!);
    return '${duration.inMinutes} mins ${duration.inSeconds % 60} secs';
  }

  void _listenToLocationUpdates() {
    _databaseRef.onValue.listen((event) {
      try {
        final data = event.snapshot.value;

        if (data is Map) {
          final latitude = _parseDouble(data['lat']);
          final longitude = _parseDouble(data['lng']);

          if (latitude != null && longitude != null) {
            final newLocation = LatLng(latitude, longitude);
            _updateLocation(latitude, longitude);
            _checkGeofence(latitude, longitude);
            _updatePathTracking(newLocation);
          } else {
            _handleLocationError("Invalid coordinates");
          }
        } else {
          _handleLocationError("Invalid data format");
        }
      } catch (e) {
        _handleLocationError("Error processing location: ${e.toString()}");
      }
    });
  }

  void _updatePathTracking(LatLng newLocation) {
    if (!_isTracking) return;

    setState(() {
      if (_pathPoints.isNotEmpty) {
        final lastPoint = _pathPoints.last;

        // Add intermediate points for curves
        final curvedPoints = _generateCurvedPoints(lastPoint, newLocation, 20); // Adjust "20" for smoothness
        _pathPoints.addAll(curvedPoints);

        final distance = _calculateDistance(lastPoint, newLocation);
        _totalDistance += distance;
      }

      _pathPoints.add(newLocation);

      _pathPolylines = {
        Polyline(
          polylineId: const PolylineId('tracked_path'),
          points: _pathPoints,
          color: Colors.blue,
          width: 5,
        )
      };
    });
  }


  List<LatLng> _generateCurvedPoints(LatLng start, LatLng end, int segments) {
    List<LatLng> points = [];
    for (int i = 1; i <= segments; i++) {
      double t = i / (segments + 1);
      double lat = start.latitude + t * (end.latitude - start.latitude);
      double lng = start.longitude + t * (end.longitude - start.longitude);

      // Apply a slight curve offset based on a sine function
      double offset = sin(t * pi) * 0.0002; // Adjust "0.0002" for curve intensity
      points.add(LatLng(lat + offset, lng));
    }
    return points;
  }


  void _updateLocation(double latitude, double longitude) {
    setState(() {
      _currentLocation = LatLng(latitude, longitude);
      _errorMessage = null;

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
  }

  void _checkGeofence(double latitude, double longitude) {
    final distance = _calculateDistance(_geofenceCenter, LatLng(latitude, longitude)) * 1000; // convert to meters
    final bool inside = distance <= _geofenceRadius;
    setState(() {
      _isInsideGeofence = inside;
    });

    _onGeofenceEvent(inside);
  }

  void _onGeofenceEvent(bool entered) {
    if (entered) {
      print('Entered geofence');
    } else {
      print('Exited geofence');
    }
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const earthRadius = 6371;

    final lat1 = _degreesToRadians(point1.latitude);
    final lon1 = _degreesToRadians(point1.longitude);
    final lat2 = _degreesToRadians(point2.latitude);
    final lon2 = _degreesToRadians(point2.longitude);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

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

  void _handleLocationError(String message) {
    setState(() {
      _errorMessage = message;
      _currentLocation = null;
      _markers.clear();
    });
    print(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Location Tracking'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _fetchHistoricalPaths,
          ),
        ],
      ),
      body: _buildMapBody(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildTrackingControls(),
    );
  }

  Widget _buildTrackingControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          onPressed: _isTracking ? null : _startTracking,
          backgroundColor: _isTracking ? Colors.grey : Colors.green,
          child: const Icon(Icons.play_arrow),
        ),
        const SizedBox(width: 20),
        FloatingActionButton(
          onPressed: _isTracking ? _stopTracking : null,
          backgroundColor: _isTracking ? Colors.red : Colors.grey,
          child: const Icon(Icons.stop),
        ),
      ],
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

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentLocation!,
            zoom: 15,
          ),
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            _moveMapCameraToGeofence();
          },
          markers: _markers,
          polylines: _pathPolylines,
          circles: _geofenceCircles,
          zoomControlsEnabled: true,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
        ),
        Positioned(
          top: 10,
          left: 10,
          child: _buildTrackingInfoChip(),
        ),
      ],
    );
  }

  Widget _buildTrackingInfoChip() {
    if (!_isTracking) return const SizedBox.shrink();

    return Chip(
      label: Text(
        'Distance: ${_totalDistance.toStringAsFixed(2)} km | '
            'Duration: ${_calculateTrackedDuration()}',
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: Colors.white.withOpacity(0.7),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
