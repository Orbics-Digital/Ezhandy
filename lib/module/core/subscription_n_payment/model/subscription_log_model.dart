import 'package:intl/intl.dart';

class SubscriptionPlanModel {
  final int? id;
  final String? planId;
  final String? title;
  final String? duration;
  final String? packageType;
  final String? price;
  final String? priceValue;

  const SubscriptionPlanModel({
    this.id,
    this.planId,
    this.title,
    this.duration,
    this.packageType,
    this.price,
    this.priceValue,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: _readInt(json['id']),
      planId: json['planId']?.toString(),
      title: json['title']?.toString(),
      duration: json['duration']?.toString(),
      packageType: json['packageType']?.toString(),
      price: json['price']?.toString(),
      priceValue: json['priceValue']?.toString(),
    );
  }
}

class SubscriptionLogModel {
  final String? id;
  final int? planId;
  final String? packageType;
  final String? status;
  final double amount;
  final String? currency;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool isActive;
  final bool isExpired;
  final SubscriptionPlanModel? plan;

  const SubscriptionLogModel({
    this.id,
    this.planId,
    this.packageType,
    this.status,
    this.amount = 0,
    this.currency,
    this.startsAt,
    this.endsAt,
    this.isActive = false,
    this.isExpired = false,
    this.plan,
  });

  bool get isCurrent => !isExpired;

  String get displaySubscribedOn => _formatDate(startsAt);

  String get displayExpiresOn => _formatDate(endsAt);

  String get displayAmountPaid {
    final planPrice = plan?.price?.trim();
    if (planPrice != null && planPrice.isNotEmpty) {
      final parsed = double.tryParse(planPrice);
      if (parsed != null) {
        return _formatMoney(parsed, currency);
      }
    }

    final normalizedAmount = amount >= 100 ? amount / 100 : amount;
    return _formatMoney(normalizedAmount, currency);
  }

  String get displayDuration {
    final duration = plan?.duration?.trim();
    if (duration != null && duration.isNotEmpty) return duration;

    return _formatPackageType(packageType);
  }

  factory SubscriptionLogModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionLogModel(
      id: json['id']?.toString(),
      planId: _readInt(json['planId']),
      packageType: json['packageType']?.toString(),
      status: json['status']?.toString(),
      amount: _readDouble(json['amount']),
      currency: json['currency']?.toString(),
      startsAt: _readDate(json['startsAt']),
      endsAt: _readDate(json['endsAt']),
      isActive: _readBool(json['isActive']),
      isExpired: _readBool(json['isExpired']),
      plan: json['plan'] is Map
          ? SubscriptionPlanModel.fromJson(
              Map<String, dynamic>.from(json['plan'] as Map),
            )
          : null,
    );
  }
}

double _readDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

int? _readInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

bool _readBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }
  return false;
}

DateTime? _readDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

String _formatDate(DateTime? value) {
  if (value == null) return '-';
  return DateFormat('MM/dd/yyyy').format(value.toLocal());
}

String _formatMoney(num value, String? currency) {
  final symbol = currency?.trim().toLowerCase() == 'usd' ? '\$' : '\$';
  return '$symbol${value.toStringAsFixed(2)}';
}

String _formatPackageType(String? value) {
  final normalized = value?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) return '-';

  return normalized
      .split('_')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}
