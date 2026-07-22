import 'package:intl/intl.dart';

class ProviderRatingUserModel {
  final String? id;
  final String? fullName;
  final String? profileImage;
  final String? email;

  const ProviderRatingUserModel({
    this.id,
    this.fullName,
    this.profileImage,
    this.email,
  });

  factory ProviderRatingUserModel.fromJson(Map<String, dynamic> json) {
    return ProviderRatingUserModel(
      id: json['id']?.toString(),
      fullName: json['fullName']?.toString(),
      profileImage: json['profileImage']?.toString(),
      email: json['email']?.toString(),
    );
  }
}

class ProviderRatingModel {
  final String? id;
  final String? ratedUserId;
  final String? ratingUserId;
  final int? rating;
  final String? review;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ProviderRatingUserModel? ratingUser;

  const ProviderRatingModel({
    this.id,
    this.ratedUserId,
    this.ratingUserId,
    this.rating,
    this.review,
    this.createdAt,
    this.updatedAt,
    this.ratingUser,
  });

  factory ProviderRatingModel.fromJson(Map<String, dynamic> json) {
    return ProviderRatingModel(
      id: json['id']?.toString(),
      ratedUserId: json['ratedUserId']?.toString(),
      ratingUserId: json['ratingUserId']?.toString(),
      rating: _readInt(json['rating']),
      review: json['review']?.toString(),
      createdAt: _readDate(json['createdAt']),
      updatedAt: _readDate(json['updatedAt']),
      ratingUser: _readRatingUser(json['ratingUser'] ?? json['user']),
    );
  }

  double get ratingValue => (rating ?? 0).toDouble();

  String get displayUserName {
    final value = ratingUser?.fullName?.trim();
    if (value != null && value.isNotEmpty) return value;
    return '-';
  }

  String get displayReview {
    final value = review?.trim();
    if (value != null && value.isNotEmpty) return value;
    return '-';
  }

  String get displayDate {
    final value = createdAt;
    if (value == null) return '-';
    return DateFormat('MM/dd/yyyy').format(value.toLocal());
  }
}

int? _readInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

DateTime? _readDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

ProviderRatingUserModel? _readRatingUser(dynamic value) {
  if (value is! Map) return null;

  return ProviderRatingUserModel.fromJson(
    Map<String, dynamic>.from(value),
  );
}
