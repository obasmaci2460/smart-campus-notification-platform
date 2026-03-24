import 'package:flutter/material.dart';

class CategoryModel {
  final int id;
  final String name;
  final String displayName;
  final String icon;
  final String colorHex;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.icon,
    required this.colorHex,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      displayName: json['display_name'] as String,
      icon: json['icon'] as String,
      colorHex: json['color_hex'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'icon': icon,
      'color_hex': colorHex,
    };
  }

  Color get color {
    final hex = colorHex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  IconData get iconData {
    switch (icon) {
      case 'security':
        return Icons.security;
      case 'build':
        return Icons.build;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'construction':
        return Icons.construction;
      case 'school':
        return Icons.school;
      case 'search':
        return Icons.search;
      case 'more_horiz':
        return Icons.more_horiz;
      default:
        return Icons.info;
    }
  }
}
