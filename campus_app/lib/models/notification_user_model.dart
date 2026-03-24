class NotificationUserModel {
  final int id;
  final String maskedName;
  final String department;

  const NotificationUserModel({
    required this.id,
    required this.maskedName,
    required this.department,
  });

  factory NotificationUserModel.fromJson(Map<String, dynamic> json) {
    return NotificationUserModel(
      id: json['id'] as int,
      maskedName: json['masked_name'] as String,
      department: json['department'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'masked_name': maskedName, 'department': department};
  }
}
