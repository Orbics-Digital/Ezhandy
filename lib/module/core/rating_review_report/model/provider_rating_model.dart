import 'package:intl/intl.dart';

class ProviderRatingModel {
  final String? id;
  final String? ratedUserId;
  final String? ratingUserId;
  final int? rating;
  final String? review;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProviderRatingModel({
    this.id,
    this.ratedUserId,
    this.ratingUserId,
    this.rating,
    this.review,
    this.createdAt,
    this.updatedAt,
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
    );
  }

  double get ratingValue => (rating ?? 0).toDouble();

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
