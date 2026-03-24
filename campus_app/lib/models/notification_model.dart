import 'category_model.dart';
import 'status_model.dart';
import 'location_model.dart';
import 'notification_user_model.dart';

class NotificationModel {
  final int id;
  final String title;
  final String description;
  final CategoryModel category;
  final StatusModel status;
  final LocationModel? location;
  final NotificationUserModel user;
  final int photoCount;
  final int followerCount;
  final bool isFollowing;
  final bool isSos;
  final bool isHighPriority;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<AdminNoteModel> adminNotes;
  final List<String> photos;
  final bool? hasUpdates;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    this.location,
    required this.user,
    required this.photoCount,
    required this.followerCount,
    required this.isFollowing,
    required this.isSos,
    required this.isHighPriority,
    required this.createdAt,
    this.updatedAt,
    this.adminNotes = const [],
    this.photos = const [],
    this.hasUpdates,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category:
          json['category'] != null
              ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
              : _defaultCategory(),
      status:
          json['status'] != null
              ? StatusModel.fromJson(json['status'] as Map<String, dynamic>)
              : _defaultStatus(),
      location:
          json['location'] != null
              ? LocationModel.fromJson(json['location'] as Map<String, dynamic>)
              : null,
      user:
          json['user'] != null
              ? NotificationUserModel.fromJson(
                json['user'] as Map<String, dynamic>,
              )
              : _defaultUser(),
      photoCount: json['photo_count'] as int? ?? 0,
      followerCount: json['follower_count'] as int? ?? 0,
      isFollowing: json['is_following'] as bool? ?? false,
      isSos: json['is_sos'] as bool? ?? false,
      isHighPriority: json['is_high_priority'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString())
              : null,
      adminNotes: _parseAdminNotes(json['admin_notes']),
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      hasUpdates: json['has_updates'] as bool?,
    );
  }

 factory NotificationModel.fromApiJson(Map<String, dynamic> json) {
    final locMap = json['location'] as Map<String, dynamic>?;
    
    final lat = (locMap?['latitude'] ?? locMap?['lat'] ?? json['latitude'] ?? json['lat']) as num?;
    final lng = (locMap?['longitude'] ?? locMap?['lng'] ?? json['longitude'] ?? json['lng']) as num?;
    final address = (locMap?['address'] ?? json['address']) as String? ?? '';

    LocationModel? parsedLocation;
    if (lat != null && lng != null) {
      parsedLocation = LocationModel(
        latitude: lat.toDouble(),
        longitude: lng.toDouble(),
        address: address,
      );
    }

    return NotificationModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: CategoryModel(
        id: json['category']?['id'] as int? ?? json['category_id'] as int? ?? 0,
        name:
            json['category']?['name'] as String? ??
            _getCategoryName(json['category_id'] as int? ?? 0),
        displayName:
            json['category']?['display_name'] as String? ??
            json['category_name'] as String? ??
            'Diğer',
        icon: _getCategoryIcon(
          json['category']?['id'] as int? ?? json['category_id'] as int? ?? 0,
        ),
        colorHex:
            json['category']?['color_hex'] as String? ??
            _getCategoryColorHex(json['category_id'] as int? ?? 0),
      ),
      status: StatusModel(
        id: json['status']?['id'] as int? ?? json['status_id'] as int? ?? 1,
        name: json['status']?['name'] as String? ?? 'unknown',
        displayName:
            json['status']?['display_name'] as String? ??
            json['status_name'] as String? ??
            'Açık',
        colorHex:
            json['status']?['color_hex'] as String? ??
            _getStatusColorHex(json['status_id'] as int? ?? 1),
      ),
      location: parsedLocation, // <-- DÜZELTİLEN YER BURASI!
      user: NotificationUserModel(
        id: json['user_id'] as int? ?? 0,
        maskedName:
            '${json['user_first_name'] ?? ''} ${json['user_last_name'] ?? ''}'
                .trim(),
        department: '',
      ),
      photoCount: json['photo_count'] as int? ?? 0,
      followerCount: json['follower_count'] as int? ?? 0,
      isFollowing: json['is_following'] as bool? ?? false,
      isSos: json['is_sos'] as bool? ?? false,
      isHighPriority: json['is_high_priority'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString())
              : null,
      adminNotes: _parseAdminNotes(json['admin_notes']),
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  factory NotificationModel.fromNearbyJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: CategoryModel(
        id: json['category_id'] as int? ?? 0,
        name: _getCategoryName(json['category_id'] as int? ?? 0),
        displayName: json['category_name'] as String? ?? 'Diğer',
        icon: _getCategoryIcon(json['category_id'] as int? ?? 0),
        colorHex: _getCategoryColorHex(json['category_id'] as int? ?? 0),
      ),
      status: StatusModel(
        id: json['status_id'] as int? ?? 1,
        name: 'unknown',
        displayName:
            json['status_name'] as String? ??
            _getStatusDisplayName(json['status_id'] as int? ?? 1),
        colorHex: _getStatusColorHex(json['status_id'] as int? ?? 1),
      ),
      location: LocationModel(
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        address: '',
      ),
      user: _defaultUser(),
      photoCount: 0,
      followerCount: 0,
      isFollowing: false,
      isSos: json['is_sos'] as bool? ?? false,
      isHighPriority: false,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static List<AdminNoteModel> _parseAdminNotes(dynamic jsonNotes) {
    if (jsonNotes == null) return [];
    if (jsonNotes is List) {
      return jsonNotes.map((e) {
        if (e is Map<String, dynamic>) {
          return AdminNoteModel.fromJson(e);
        } else if (e is Map) {
          return AdminNoteModel.fromJson(Map<String, dynamic>.from(e));
        }
        return AdminNoteModel.empty();
      }).toList();
    }
    return [];
  }

  static CategoryModel _defaultCategory() {
    return const CategoryModel(
      id: 0,
      name: 'other',
      displayName: 'Diğer',
      icon: 'more_horiz',
      colorHex: '#9E9E9E',
    );
  }

  static StatusModel _defaultStatus() {
    return const StatusModel(
      id: 1,
      name: 'open',
      displayName: 'Açık',
      colorHex: '#F59E0B',
    );
  }

  static NotificationUserModel _defaultUser() {
    return const NotificationUserModel(
      id: 0,
      maskedName: 'Anonim',
      department: '',
    );
  }

  static String _getCategoryIcon(int categoryId) {
    switch (categoryId) {
      case 1:
        return 'school';
      case 2:
        return 'build';
      case 3:
        return 'cleaning_services';
      case 4:
        return 'security';
      case 5:
        return 'search';
      default:
        return 'more_horiz';
    }
  }

  static String _getCategoryColorHex(int categoryId) {
    switch (categoryId) {
      case 1:
        return '#E53935';
      case 2:
        return '#FB8C00';
      case 3:
        return '#FDD835';
      case 4:
        return '#1E88E5';
      default:
        return '#43A047';
    }
  }

  static String _getCategoryName(int categoryId) {
    switch (categoryId) {
      case 1:
        return 'security';
      case 2:
        return 'maintenance';
      case 3:
        return 'cleaning';
      case 4:
        return 'infrastructure';
      case 5:
        return 'other';
      default:
        return 'other';
    }
  }

  static String _getStatusColorHex(int statusId) {
    switch (statusId) {
      case 1:
        return '#F59E0B';
      case 2:
        return '#3B82F6';
      case 3:
        return '#16A34A';
      case 4:
        return '#6B7280';
      default:
        return '#F59E0B';
    }
  }

  static String _getStatusDisplayName(int statusId) {
    switch (statusId) {
      case 1:
        return 'Açık';
      case 2:
        return 'İnceleniyor';
      case 3:
        return 'Çözüldü';
      case 4:
        return 'Spam';
      default:
        return 'Açık';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.toJson(),
      'status': status.toJson(),
      if (location != null) 'location': location!.toJson(),
      'user': user.toJson(),
      'photo_count': photoCount,
      'follower_count': followerCount,
      'is_following': isFollowing,
      'is_sos': isSos,
      'is_high_priority': isHighPriority,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      'admin_notes': adminNotes.map((e) => e.toJson()).toList(),
      'photos': photos,
    };
  }

  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    if (difference.inMinutes < 1) return 'Az önce';
    if (difference.inMinutes < 60) return '${difference.inMinutes} dk önce';
    if (difference.inHours < 24) return '${difference.inHours} saat önce';
    if (difference.inDays < 7) return '${difference.inDays} gün önce';
    return '${createdAt.day}.${createdAt.month}.${createdAt.year}';
  }
}

class AdminNoteModel {
  final int id;
  final String noteContent;
  final DateTime createdAt;
  final String? adminName;

  const AdminNoteModel({
    required this.id,
    required this.noteContent,
    required this.createdAt,
    this.adminName,
  });

  factory AdminNoteModel.empty() {
    return AdminNoteModel(id: 0, noteContent: '', createdAt: DateTime.now());
  }

  factory AdminNoteModel.fromJson(Map<String, dynamic> json) {
    return AdminNoteModel(
      id: json['id'] as int? ?? 0,
      noteContent: json['note_content'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      adminName: json['admin_name'] as String? ?? 'Yönetici',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'note_content': noteContent,
      'created_at': createdAt.toIso8601String(),
      'admin_name': adminName,
    };
  }
}
