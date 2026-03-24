import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import '../../../../models/notification_model.dart';
import '../../../../core/services/api_service.dart';
import '../widgets/detail_header.dart';
import '../widgets/action_buttons.dart';
import '../widgets/meta_section.dart';
import '../widgets/status_badge.dart';
import '../widgets/admin_note_section.dart';
import '../widgets/photo_gallery.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'full_screen_map_screen.dart';

class NotificationDetailScreen extends StatefulWidget {
  final int notificationId;

  const NotificationDetailScreen({super.key, required this.notificationId});

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  bool _isLoading = true;
  NotificationModel? _notification;
  String? _errorMessage;
  bool _isEditingDescription = false;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _loadNotificationDetail();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitDescriptionUpdate() async {
    if (_descriptionController.text.trim().isEmpty) return;

    final response = await ApiService.updateNotification(
      widget.notificationId,
      description: _descriptionController.text.trim(),
    );

    if (response.success && mounted) {
      setState(() => _isEditingDescription = false);
      _loadNotificationDetail();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Açıklama güncellendi"),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message ?? "Hata")));
      }
    }
  }

  Future<void> _loadNotificationDetail() async {
    try {
      final response = await ApiService.getNotificationDetail(
        widget.notificationId,
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (response.success && response.data != null) {
            _notification = response.data;
            if (!_isEditingDescription) {
              _descriptionController.text = _notification!.description;
            }
          } else {
            _errorMessage = response.message ?? 'Bildirim bulunamadı';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Bağlantı hatası';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        actions: [
          if (_notification != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: StatusBadge.fromStatusId(
                statusId: _notification!.status.id,
                displayName: _notification!.status.displayName,
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, color: AppColors.textPrimary),
              onSelected: (value) {
                if (value == 'share') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Paylaşılıyor... (Demo)")),
                  );
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(
                            Icons.share,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                          SizedBox(width: 8),
                          Text("Paylaş"),
                        ],
                      ),
                    ),
                  ],
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar:
          _notification == null
              ? null
              : SafeArea(
                child: ActionButtons(
                  notification: _notification!,
                  onUpdate: (_) => _loadNotificationDetail(),
                ),
              ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text(_errorMessage!));
    if (_notification == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailHeader(notification: _notification!),
          const SizedBox(height: AppSpacing.lg),
          MetaSection(notification: _notification!),
          const SizedBox(height: AppSpacing.lg),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Açıklama',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: AppFontWeights.semibold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: Icon(
                  _isEditingDescription ? Icons.check : Icons.edit,
                  size: 20,
                  color: AppColors.primary,
                ),
                onPressed:
                    _isEditingDescription
                        ? _submitDescriptionUpdate
                        : () => setState(() => _isEditingDescription = true),
                tooltip: _isEditingDescription ? 'Kaydet' : 'Düzenle',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.neutral200),
            ),
            child:
                _isEditingDescription
                    ? TextField(
                      controller: _descriptionController,
                      maxLines: null,
                      autofocus: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    )
                    : Text(
                      _notification!.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 📍 İŞTE SİHİRLİ DOKUNUŞ: Eğer konum varsa haritayı göster, yoksa uyarı ver!
          if (_notification!.location != null) ...[
            const Text(
              'Konum',
              style: TextStyle(
                fontSize: 16,
                fontWeight: AppFontWeights.semibold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 192,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.neutral200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Stack(
                  children: [
                    GoogleMap(
                      key: ValueKey('map_${_notification!.id}'),
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          _notification!.location!.latitude,
                          _notification!.location!.longitude,
                        ),
                        zoom: 15.0,
                      ),
                      onMapCreated: (controller) {
                        Future.delayed(const Duration(milliseconds: 500), () {
                          try {
                            controller.animateCamera(
                              CameraUpdate.newLatLng(
                                LatLng(
                                  _notification!.location!.latitude,
                                  _notification!.location!.longitude,
                                ),
                              ),
                            );
                          } catch (e) {}
                        });
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId('notification_location'),
                          position: LatLng(
                            _notification!.location!.latitude,
                            _notification!.location!.longitude,
                          ),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed,
                          ),
                        ),
                      },
                      zoomControlsEnabled: false,
                      scrollGesturesEnabled: false,
                      zoomGesturesEnabled: false,
                      rotateGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      myLocationButtonEnabled: false,
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMapActionButton(
                            icon: Icons.fullscreen,
                            label: 'Tam Ekran',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => FullScreenMapScreen(
                                        latitude:
                                            _notification!.location!.latitude,
                                        longitude:
                                            _notification!.location!.longitude,
                                        title: _notification!.title,
                                      ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildMapActionButton(
                            icon: Icons.directions,
                            label: 'Yol Tarifi',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Yol Tarifi açılıyor... (Demo)'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _notification!.location?.address ?? 'Adres yok',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: AppFontWeights.medium,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ] else ...[
            // 🛑 EĞER KONUM YOKSA BURASI ÇALIŞACAK VE ÇÖKMEYİ ENGELLEYECEK
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Row(
                children: [
                  Icon(Icons.location_off, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Text(
                    'Bu bildirim için konum bilgisi bulunmuyor.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          if (_notification!.photos.isNotEmpty) ...[
            PhotoGallery(photoUrls: _notification!.photos),
            const SizedBox(height: AppSpacing.lg),
          ],

          AdminNoteSection(
            notification: _notification!,
            onNoteAdded: _loadNotificationDetail,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMapActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.textPrimary),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}