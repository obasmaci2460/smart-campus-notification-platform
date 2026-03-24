import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants.dart';
import '../../../core/services/api_service.dart';
import '../../../models/notification_model.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../widgets/category_chip.dart';
import '../widgets/time_filter_chip.dart';
import '../widgets/notification_card.dart';
import '../widgets/shimmer_card.dart';
import '../widgets/pulsing_fab.dart';
import '../widgets/sos_bottom_sheet.dart';
import '../../profile/screens/followed_updates_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _isSendingSOS = false;
  int _updatesCount = 0;

  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasReachedMax = false;

  int? _selectedCategoryId;
  String _selectedTimeFilter = 'all';
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _loadUpdatesCount();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadUpdatesCount() async {
    try {
      final response = await ApiService.getFollowingUpdatesCount();
      if (response.success && response.data != null && mounted) {
        final data = response.data as Map<String, dynamic>;
        setState(() {
          _updatesCount = data['count'] ?? 0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _updatesCount = 0);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      _currentPage = 1;
      _hasReachedMax = false;
    });

    try {
      final response = await ApiService.getNotifications(
        page: 1,
        categoryId: _selectedCategoryId,
        timeFilter: _selectedTimeFilter,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (response.success) {
            _notifications = response.notifications;
            _totalPages = response.pagination.totalPages;
            _hasReachedMax = _currentPage >= _totalPages;
          } else {
            _hasError = true;
            _errorMessage = response.error?.message ?? 'Bir hata oluştu';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Bağlantı hatası';
        });
      }
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (_isLoadingMore || _hasReachedMax) return;

    setState(() => _isLoadingMore = true);

    try {
      final response = await ApiService.getNotifications(
        page: _currentPage + 1,
        categoryId: _selectedCategoryId,
        timeFilter: _selectedTimeFilter,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          if (response.success) {
            _currentPage++;
            _notifications.addAll(response.notifications);
            _hasReachedMax = _currentPage >= _totalPages;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreNotifications();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery != query) {
        setState(() {
          _searchQuery = query;
          _notifications = [];
        });
        _loadNotifications();
      }
    });
  }

  void _onCategorySelected(int? categoryId) {
    if (_selectedCategoryId != categoryId) {
      setState(() {
        _selectedCategoryId = categoryId;
        _notifications = [];
      });
      _loadNotifications();
    }
  }

  void _onTimeFilterSelected(String filter) {
    if (_selectedTimeFilter != filter) {
      setState(() {
        _selectedTimeFilter = filter;
        _notifications = [];
      });
      _loadNotifications();
    }
  }

  Future<void> _onRefresh() async {
    await _loadNotifications();
  }

  Future<void> _onNotificationTap(NotificationModel notification) async {
    await Navigator.pushNamed(
      context,
      '/notification-detail',
      arguments: notification.id,
    );

    if (mounted) {
      _loadNotifications();
      _loadUpdatesCount();
    }
  }

  Future<void> _onSosPressed() async {
    FocusScope.of(context).unfocus();
    final confirmed = await SosBottomSheet.show(context);
    if (confirmed == true && mounted) {
      _sendSOS();
    }
  }

  Future<void> _sendSOS() async {
    setState(() => _isSendingSOS = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Konum izni reddedildi');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Konum izni kalıcı olarak reddedildi');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final response = await ApiService.createSOS(
        latitude: position.latitude,
        longitude: position.longitude,
        address: 'Anlık Konum',
      );

      if (mounted) {
        setState(() => _isSendingSOS = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.success
                  ? 'SOS bildirimi gönderildi!'
                  : response.error?.message ?? 'Bir hata oluştu',
            ),
            backgroundColor:
                response.success ? AppColors.success : AppColors.error,
          ),
        );

        if (response.success) {
          _loadNotifications();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSendingSOS = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SOS gönderilemedi: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onCreatePressed() {
    Navigator.pushNamed(context, '/create');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchSection(),
          _buildCategoryChips(),
          const SizedBox(height: AppSpacing.sm),
          _buildTimeChips(),
          const SizedBox(height: AppSpacing.sm),

          Expanded(
            child: Stack(children: [_buildContent(), _buildFabButtons()]),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.surface,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      surfaceTintColor: Colors.transparent,
      title: const Text(
        'Bildirimler',
        style: TextStyle(
          fontSize: 18,
          fontWeight: AppFontWeights.semibold,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: false,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_active_outlined,
                color: AppColors.textSecondary,
              ),
              onPressed: () async {
                final count = _updatesCount;
                setState(() => _updatesCount = 0);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => FollowedUpdatesScreen(updateCount: count),
                  ),
                );
              },
            ),

            if (_updatesCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    _updatesCount > 9 ? '9+' : '$_updatesCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.search, color: AppColors.textSecondary),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Bildirim ara...',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                ),
                style: const TextStyle(
                  fontSize: AppFontSizes.small,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: SizedBox(
        height: 32,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            CategoryChip(
              categoryId: null,
              label: 'Tümü',
              isSelected: _selectedCategoryId == null,
              onTap: () => _onCategorySelected(null),
            ),
            const SizedBox(width: AppSpacing.sm),

            ...AppCategories.all.map((cat) {
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: CategoryChip(
                  categoryId: cat['id'] as int,
                  label: cat['display_name'] as String,
                  isSelected: _selectedCategoryId == cat['id'],
                  onTap: () => _onCategorySelected(cat['id'] as int),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChips() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: SizedBox(
        height: 32,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children:
              AppTimeFilters.all.map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: TimeFilterChip(
                    label: filter['label']!,
                    isSelected: _selectedTimeFilter == filter['value'],
                    onTap: () => _onTimeFilterSelected(filter['value']!),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const ShimmerList();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSpacing.sm),
        itemCount: _notifications.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _notifications.length) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          final notification = _notifications[index];
          return NotificationCard(
            notification: notification,
            onTap: () => _onNotificationTap(notification),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: AppColors.neutral300,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Bildirim Bulunamadı',
            style: TextStyle(
              fontSize: 18,
              fontWeight: AppFontWeights.semibold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _searchQuery.isNotEmpty || _selectedCategoryId != null
                ? 'Seçilen filtrelere uygun bildirim yok.'
                : 'Henüz bildirim oluşturulmamış.',
            style: const TextStyle(
              fontSize: AppFontSizes.small,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Bir Hata Oluştu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: AppFontWeights.semibold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _errorMessage ?? 'Bildirimler yüklenirken hata oluştu.',
            style: const TextStyle(
              fontSize: AppFontSizes.small,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh),
            label: const Text('Tekrar Dene'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFabButtons() {
    return Positioned(
      right: AppSpacing.md,
      bottom: AppSpacing.md,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PulsingFab(
            onPressed: _onSosPressed,
            icon: Icons.sos,
            backgroundColor: AppColors.accent,
            size: AppSizes.fabSizeSos,
          ),
          const SizedBox(height: AppSpacing.md),

          FloatingActionButton(
            onPressed: _onCreatePressed,
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
