import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import '../../../core/constants.dart';
import '../../../core/services/api_service.dart';
import '../../../models/notification_model.dart';
import '../../../models/status_model.dart';
import '../../../widgets/bottom_nav_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _showFilterMenu = false;
  String _currentFilter = 'all';
  NotificationModel? _selectedNotification;
  String? _selectedAddress;
  LatLng? _userMarkerPosition;

  static const LatLng _defaultCenter = LatLng(39.925533, 32.866287);
  LatLng _currentCenter = _defaultCenter;

  static const Map<String, Map<String, dynamic>> _categoryDetails = {
    'security': {
      'icon': Icons.shield,
      'color': Color(0xFFE53935),
      'bgColor': Color(0xFFFFEBEE),
      'text': 'Güvenlik',
    },
    'maintenance': {
      'icon': Icons.build,
      'color': Color(0xFFFB8C00),
      'bgColor': Color(0xFFFFF3E0),
      'text': 'Teknik Arıza',
    },
    'cleaning': {
      'icon': Icons.cleaning_services,
      'color': Color(0xFFFDD835),
      'bgColor': Color(0xFFFFFDE7),
      'text': 'Temizlik',
    },
    'infrastructure': {
      'icon': Icons.construction,
      'color': Color(0xFF1E88E5),
      'bgColor': Color(0xFFE3F2FD),
      'text': 'Altyapı',
    },
    'other': {
      'icon': Icons.help_outline,
      'color': Color(0xFF43A047),
      'bgColor': Color(0xFFE8F5E9),
      'text': 'Diğer',
    },
  };

  static const List<Map<String, dynamic>> _filterOptions = [
    {'key': 'all', 'text': 'Tüm Kategoriler', 'emoji': ''},
    {'key': 'security', 'text': 'Güvenlik', 'emoji': '🔴'},
    {'key': 'maintenance', 'text': 'Teknik Arıza', 'emoji': '🟠'},
    {'key': 'cleaning', 'text': 'Temizlik', 'emoji': '🟡'},
    {'key': 'infrastructure', 'text': 'Altyapı', 'emoji': '🔵'},
    {'key': 'other', 'text': 'Diğer', 'emoji': '🟢'},
  ];

  @override
  void initState() {
    super.initState();
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
        setState(() {
          _notifications = response.data!;
        });
        _buildMarkers();
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _buildMarkers() {
    _markers.clear();

    for (final notification in _notifications) {
      if (_currentFilter != 'all' &&
          notification.category.name != _currentFilter) {
        continue;
      }

      if (notification.location == null) continue;

      final categoryName = notification.category.name;
      final categoryData =
          _categoryDetails[categoryName] ?? _categoryDetails['other']!;
      final color = categoryData['color'] as Color;

      _markers.add(
        Marker(
          markerId: MarkerId('notification_${notification.id}'),
          position: LatLng(
            notification.location!.latitude,
            notification.location!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(_getHueFromColor(color)),
          onTap: () => _onMarkerTapped(notification),
          consumeTapEvents: true,
        ),
      );
    }

    if (_userMarkerPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('user_selection'),
          position: _userMarkerPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
  }

  double _getHueFromColor(Color color) {
    if (color == const Color(0xFFE53935)) return BitmapDescriptor.hueRed;
    if (color == const Color(0xFFFB8C00)) return BitmapDescriptor.hueOrange;
    if (color == const Color(0xFFFDD835)) return BitmapDescriptor.hueYellow;
    if (color == const Color(0xFF1E88E5)) return BitmapDescriptor.hueBlue;
    if (color == const Color(0xFF43A047)) return BitmapDescriptor.hueGreen;
    return BitmapDescriptor.hueViolet;
  }

  void _onMarkerTapped(NotificationModel notification) {
    setState(() {
      _selectedNotification = notification;
      _selectedAddress = null;
      _userMarkerPosition = null;
    });
    _buildMarkers();
    setState(() {});
  }

  Future<void> _onMapTapped(LatLng position) async {
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
          return;
        }
      }
    }

    _userMarkerPosition = position;
    _selectedNotification = null;
    _selectedAddress =
        '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
    _buildMarkers();
    setState(() {});
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
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  void _applyFilter(String category) {
    _currentFilter = category;
    _showFilterMenu = false;
    _buildMarkers();
    setState(() {});
  }

  Future<void> _goToMyLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Konum izni reddedildi');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Konum izni kalıcı olarak reddedildi. Ayarlardan açın.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newPosition = LatLng(position.latitude, position.longitude);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(newPosition, 17),
      );

      setState(() {
        _currentCenter = newPosition;
      });
    } catch (e) {
      _showSnackBar('Konum alınamadı: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentCenter,
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: _markers,
            onTap: _onMapTapped,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          if (_isLoading) const Center(child: CircularProgressIndicator()),

          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: _buildFilterFab(),
          ),

          if (_showFilterMenu)
            Positioned(
              top: MediaQuery.of(context).padding.top + 72,
              left: 16,
              child: _buildFilterMenu(),
            ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: _buildLocationFab(),
          ),

          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomSheet()),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildFilterFab() {
    return Material(
      elevation: 4,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () => setState(() => _showFilterMenu = !_showFilterMenu),
        customBorder: const CircleBorder(),
        child: Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.filter_alt, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildFilterMenu() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              _filterOptions.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final isSelected = _currentFilter == option['key'];
                final isLast = index == _filterOptions.length - 1;

                return InkWell(
                  onTap: () => _applyFilter(option['key'] as String),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.neutral100 : null,
                      border:
                          isLast
                              ? null
                              : const Border(
                                bottom: BorderSide(
                                  color: Color(0xFFF1F5F9),
                                  width: 1,
                                ),
                              ),
                    ),
                    child: Row(
                      children: [
                        if (option['emoji'] != '')
                          SizedBox(
                            width: 24,
                            child: Text(
                              option['emoji'] as String,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        Text(
                          option['text'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight:
                                isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(
                            Icons.check,
                            size: 16,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildLocationFab() {
    return Material(
      elevation: 4,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: _goToMyLocation,
        customBorder: const CircleBorder(),
        child: Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.my_location, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    if (_selectedNotification != null) {
      return _buildNotificationSheet(_selectedNotification!);
    } else if (_selectedAddress != null) {
      return _buildLocationSheet(_selectedAddress!);
    } else {
      return _buildDefaultSheet();
    }
  }

  Widget _buildDefaultSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.place, color: AppColors.textSecondary),
          SizedBox(width: 8),
          Text(
            'Konum seçmek için haritaya dokunun.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSheet(String address) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.place, color: AppColors.textPrimary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              address,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSheet(NotificationModel notification) {
    final categoryName = notification.category.name;
    final categoryData =
        _categoryDetails[categoryName] ?? _categoryDetails['other']!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryData['bgColor'] as Color,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(
                  categoryData['icon'] as IconData,
                  color: categoryData['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusBadge(notification.status),
                        Text(
                          _formatTimeAgo(notification.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      notification.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/notification-detail',
                            arguments: notification.id,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Detayı Gör',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(StatusModel status) {
    Color bgColor;
    Color textColor;

    switch (status.id) {
      case 1:
        bgColor = const Color(0xFFFEF9C3);
        textColor = const Color(0xFF854D0E);
        break;
      case 2:
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1E40AF);
        break;
      case 3:
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        break;
      case 4:
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        break;
      default:
        bgColor = AppColors.neutral100;
        textColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else {
      return '${difference.inDays} gün önce';
    }
  }
}
