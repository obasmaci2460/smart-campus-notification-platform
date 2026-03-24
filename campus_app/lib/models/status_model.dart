import 'package:flutter/material.dart';

class StatusModel {
  final int id;
  final String name;
  final String displayName;
  final String colorHex;

  const StatusModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.colorHex,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      id: json['id'] as int,
      name: json['name'] as String,
      displayName: json['display_name'] as String,
      colorHex: json['color_hex'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'color_hex': colorHex,
    };
  }

  Color get color {
    final hex = colorHex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
