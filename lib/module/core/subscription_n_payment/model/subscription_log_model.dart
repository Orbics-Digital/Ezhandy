import 'package:intl/intl.dart';

class SubscriptionPlanModel {
  final int? id;
  final String? planId;
  final String? title;
  final String? duration;
  final String? packageType;
  final String? price;
  final String? priceValue;
  final String? originalPrice;
  final List<String> features;
  final String? color;
  final String? iconName;
  final bool popular;
  final bool isActive;

  const SubscriptionPlanModel({
    this.id,
    this.planId,
    this.title,
    this.duration,
    this.packageType,
    this.price,
    this.priceValue,
    this.originalPrice,
    this.features = const [],
    this.color,
    this.iconName,
    this.popular = false,
    this.isActive = false,
  });

  String get displayTitle {
    final value = title?.trim();
    if (value != null && value.isNotEmpty) return value;
    return _formatPackageType(packageType);
  }

  String get displayPrice {
    final value = (priceValue ?? price)?.trim();
    if (value == null || value.isEmpty) return '\$0.00';
    final parsed = double.tryParse(value);
    if (parsed != null) return '\$${parsed.toStringAsFixed(2)}';
    return value.startsWith('\$') ? value : '\$$value';
  }

  String? get displayOriginalPrice {
    final value = originalPrice?.trim();
    if (value == null || value.isEmpty) return null;
    final parsed = double.tryParse(value);
    if (parsed != null) return '\$${parsed.toStringAsFixed(2)}';
    return value.startsWith('\$') ? value : '\$$value';
  }

  String get displayDuration {
    final value = duration?.trim();
    if (value != null && value.isNotEmpty) return value;
    return _formatPackageType(packageType);
  }

  int get amountInCents {
    final value = (priceValue ?? price)?.trim();
    if (value == null || value.isEmpty) return 0;
    final parsed = double.tryParse(value.replaceAll('\$', '')) ?? 0;
    return (parsed * 100).round();
  }

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: _readInt(json['id']),
      planId: json['planId']?.toString(),
      title: json['title']?.toString(),
      duration: json['duration']?.toString(),
      packageType: json['packageType']?.toString(),
      price: json['price']?.toString(),
      priceValue: json['priceValue']?.toString(),
      originalPrice: json['originalPrice']?.toString(),
      features: _readStringList(json['features']),
      color: json['color']?.toString(),
      iconName: json['iconName']?.toString(),
      popular: _readBool(json['popular']),
      isActive: _readBool(json['isActive']),
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

List<String> _readStringList(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((item) => item?.toString().trim() ?? '')
      .where((item) => item.isNotEmpty)
      .toList();
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
