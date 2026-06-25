class ProductOwnerModel {
  final String? id;
  final String? fullName;
  final String? email;
  final String? mobileNumber;

  const ProductOwnerModel({
    this.id,
    this.fullName,
    this.email,
    this.mobileNumber,
  });

  factory ProductOwnerModel.fromJson(Map<String, dynamic> json) {
    return ProductOwnerModel(
      id: json['id']?.toString(),
      fullName: json['fullName']?.toString(),
      email: json['email']?.toString(),
      mobileNumber: json['mobileNumber']?.toString(),
    );
  }
}

class ProductCategoryModel {
  final String? id;
  final String? name;
  final String? title;
  final String? description;

  const ProductCategoryModel({
    this.id,
    this.name,
    this.title,
    this.description,
  });

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
    );
  }
}

class ProductModel {
  final String? id;
  final String? title;
  final String? description;
  final String? price;
  final String? mainImagePath;
  final List<String> additionalImages;
  final bool isActive;
  final double? avgRating;
  final int reviewsCount;
  final DateTime? createdAt;
  final ProductOwnerModel? owner;
  final ProductCategoryModel? category;

  const ProductModel({
    this.id,
    this.title,
    this.description,
    this.price,
    this.mainImagePath,
    this.additionalImages = const [],
    this.isActive = true,
    this.avgRating,
    this.reviewsCount = 0,
    this.createdAt,
    this.owner,
    this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      price: json['price']?.toString(),
      mainImagePath: json['mainImagePath']?.toString(),
      additionalImages: _readStringList(json['additionalImages']),
      isActive: _readBool(json['isActive'], fallback: true),
      avgRating: _readDouble(json['avgRating']),
      reviewsCount: _readInt(json['reviewsCount']),
      createdAt: _readDate(json['createdAt']),
      owner: json['owner'] is Map
          ? ProductOwnerModel.fromJson(
              Map<String, dynamic>.from(json['owner'] as Map),
            )
          : null,
      category: json['category'] is Map
          ? ProductCategoryModel.fromJson(
              Map<String, dynamic>.from(json['category'] as Map),
            )
          : null,
    );
  }

  static List<String> _readStringList(dynamic value) {
    if (value is! List) return const [];

    return value
        .map((item) => item?.toString())
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static bool _readBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value == null) return fallback;
    return value.toString().toLowerCase() == 'true';
  }

  static int _readInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double? _readDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
