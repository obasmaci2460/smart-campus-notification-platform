import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/constants.dart';
import '../../../core/services/api_service.dart';
import 'location_picker_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreateNotificationScreen extends StatefulWidget {
  const CreateNotificationScreen({super.key});

  @override
  State<CreateNotificationScreen> createState() =>
      _CreateNotificationScreenState();
}

class _CreateNotificationScreenState extends State<CreateNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  int? _selectedCategoryId;
  List<XFile> _selectedImages = [];
  bool _isLoading = false;
  LatLng _selectedLocation = const LatLng(39.925533, 32.866287);

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        if (_selectedImages.length + images.length > 5) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('En fazla 5 fotoğraf seçebilirsiniz.'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {}
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir kategori seçin.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.createNotification(
        categoryId: _selectedCategoryId!,
        title: _titleController.text,
        description: _descriptionController.text,
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
        address:
            _addressController.text.isNotEmpty
                ? _addressController.text
                : 'Konum Seçilmedi (Varsayılan)',
        imagePaths: _selectedImages.map((e) => e.path).toList(),
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bildirim başarıyla oluşturuldu!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pushReplacementNamed(context, '/notifications');
        } else {
          if (response.error?.code == 'RATE_LIMIT') {
            showDialog(
              context: context,
              builder:
                  (ctx) => AlertDialog(
                    title: const Text(
                      'Uyarı',
                      style: TextStyle(color: AppColors.error),
                    ),
                    content: Text(response.message ?? 'İşlem limiti aşıldı.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Tamam'),
                      ),
                    ],
                  ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.message ?? 'Hata oluştu'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed:
              () => Navigator.pushReplacementNamed(context, '/notifications'),
        ),
        title: const Text(
          'Yeni Bildirim',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionLabel('Kategori'),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.neutral200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedCategoryId,
                      hint: const Text('Kategori Seçiniz'),
                      isExpanded: true,
                      items:
                          AppCategories.all.map((cat) {
                            return DropdownMenuItem<int>(
                              value: cat['id'] as int,
                              child: Row(
                                children: [
                                  Icon(
                                    _getCategoryIcon(cat['name'] as String),
                                    size: 20,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(cat['display_name'] as String),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCategoryId = val;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                _buildSectionLabel('Başlık'),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _titleController,
                  decoration: _inputDecoration('Örn: Arızalı Klima'),
                  validator: (value) {
                    if (value == null || value.length < 5) {
                      return 'En az 5 karakter giriniz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                _buildSectionLabel('Açıklama'),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: _inputDecoration('Detaylı açıklama giriniz...'),
                  validator: (value) {
                    if (value == null || value.length < 10) {
                      return 'En az 10 karakter giriniz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                _buildSectionLabel('Fotoğraflar (${_selectedImages.length}/5)'),
                const SizedBox(height: AppSpacing.xs),
                _buildPhotoSection(),
                const SizedBox(height: AppSpacing.md),

                _buildSectionLabel('Konum'),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _addressController,
                  decoration: _inputDecoration('Adres (İsteğe bağlı)'),
                ),
                const SizedBox(height: AppSpacing.xs),
                const SizedBox(height: AppSpacing.xs),
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => LocationPickerScreen(
                              initialLat: _selectedLocation.latitude,
                              initialLong: _selectedLocation.longitude,
                            ),
                      ),
                    );
                    if (result != null && result is LatLng) {
                      setState(() {
                        _selectedLocation = result;
                        _addressController.text =
                            "${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}";
                      });
                    }
                  },
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.neutral200),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.map,
                            color: AppColors.primary,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Konum Seç (${_selectedLocation.latitude.toStringAsFixed(4)}, ${_selectedLocation.longitude.toStringAsFixed(4)})",
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Değiştirmek için dokunun",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Bildirim Oluştur',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(File(_selectedImages[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        if (_selectedImages.length < 5)
          OutlinedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Fotoğraf Ekle'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary),
          ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.neutral200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.neutral200),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'security':
        return Icons.security;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'technical':
        return Icons.build;
      case 'health':
        return Icons.local_hospital;
      case 'other':
        return Icons.category;
      default:
        return Icons.info_outline;
    }
  }
}
