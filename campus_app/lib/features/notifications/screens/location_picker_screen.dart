import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants.dart';
import '../../../core/services/api_service.dart';
import '../../../models/notification_model.dart';
import 'dart:math' as math;

class LocationPickerScreen extends StatefulWidget {
  final double initialLat;
  final double initialLong;

  const LocationPickerScreen({
    super.key,
    this.initialLat = 39.925533,
    this.initialLong = 32.866287,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late LatLng _currentCenter;
  List<NotificationModel> _notifications = [];
  Set<Marker> _markers = {};
  bool _isLoading = false;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _currentCenter = LatLng(widget.initialLat, widget.initialLong);
    _selectedLocation = _currentCenter;
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getNearbyNotifications(
        latitude: _currentCenter.latitude,
        longitude: _currentCenter.longitude,
        radius: 5000,
      );

      if (response.success && response.data != null) {
        if (mounted) {
          setState(() {
            _notifications =
                (response.data as List)
                    .map((e) => NotificationModel.fromApiJson(e))
                    .toList();
            _buildMarkers();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _buildMarkers() {
    _markers = {};

    for (var notification in _notifications) {
      if (notification.location != null) {
        final color = _getCategoryColor(notification.category.name);
        _markers.add(
          Marker(
            markerId: MarkerId('notification_${notification.id}'),
            position: LatLng(
              notification.location!.latitude,
              notification.location!.longitude,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _getHueFromColor(color),
            ),
            consumeTapEvents: true,
          ),
        );
      }
    }

    if (_selectedLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('user_selection'),
          position: _selectedLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'security':
        return AppColors.error;
      case 'cleaning':
        return AppColors.warning;
      case 'infrastructure':
        return AppColors.info;
      case 'technical':
        return AppColors.secondary;
      case 'health':
        return AppColors.error;
      default:
        return AppColors.success;
    }
  }

  double _getHueFromColor(Color color) {
    if (color == AppColors.error) return BitmapDescriptor.hueRed;
    if (color == AppColors.warning) return BitmapDescriptor.hueYellow;
    if (color == AppColors.info) return BitmapDescriptor.hueBlue;
    if (color == AppColors.success) return BitmapDescriptor.hueGreen;
    if (color == AppColors.secondary) return BitmapDescriptor.hueOrange;
    return BitmapDescriptor.hueRed;
  }

  void _onMapTapped(LatLng position) {
    const double minDistanceMeters = 5.0;
    for (final notification in _notifications) {
      if (notification.location != null) {
        final distance = _calculateDistance(
          position.latitude,
          position.longitude,
          notification.location!.latitude,
          notification.location!.longitude,
        );

        if (distance < minDistanceMeters) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Bu konuma çok yakın başka bir bildirim var. Lütfen en az 5 metre mesafe bırakın.',
              ),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
      }
    }

    setState(() {
      _selectedLocation = position;
      _buildMarkers();
    });
  }

  void _confirmSelection() {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir konum seçiniz.')),
      );
      return;
    }
    Navigator.pop(context, _selectedLocation);
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000;
    const double pi = 3.141592653589793;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * pi / 180) *
            math.cos(lat2 * pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Konum Seç',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _confirmSelection,
            ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentCenter,
          zoom: 15.0,
        ),

        onTap: _onMapTapped,
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
      ),
    );
  }
}
