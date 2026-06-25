class CategoryModel {
  final String? id;
  final String? name;
  final String? title;
  final String? iconImagePath;
  final String? imagePath;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoryModel({
    this.id,
    this.name,
    this.title,
    this.iconImagePath,
    this.imagePath,
    this.description,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  String get displayName {
    final value = title?.trim();
    if (value != null && value.isNotEmpty) return value;

    final fallback = name?.trim();
    if (fallback != null && fallback.isNotEmpty) return fallback;

    return '';
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      title: json['title']?.toString(),
      iconImagePath: json['iconImagePath']?.toString(),
      imagePath: json['imagePath']?.toString(),
      description: json['description']?.toString(),
      isActive: _readBool(json['isActive'], fallback: true),
      createdAt: _readDate(json['createdAt']),
      updatedAt: _readDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'title': title,
        'iconImagePath': iconImagePath,
        'imagePath': imagePath,
        'description': description,
        'isActive': isActive,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static bool _readBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value == null) return fallback;
    return value.toString().toLowerCase() == 'true';
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
