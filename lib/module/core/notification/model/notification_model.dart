class NotificationModel {
  final String? id;
  final String? type;
  final String? title;
  final String? description;
  final Map<String, dynamic>? data;
  final bool isRead;
  final bool isDeleted;
  final DateTime? createdAt;

  const NotificationModel({
    this.id,
    this.type,
    this.title,
    this.description,
    this.data,
    this.isRead = false,
    this.isDeleted = false,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString(),
      type: json['type']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      data: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
      isRead: _readBool(json['isRead']),
      isDeleted: _readBool(json['isDeleted']),
      createdAt: _readDate(json['createdAt']),
    );
  }

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value == null) return false;
    return value.toString().toLowerCase() == 'true';
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      type: type,
      title: title,
      description: description,
      data: data,
      isRead: isRead ?? this.isRead,
      isDeleted: isDeleted,
      createdAt: createdAt,
    );
  }
}
