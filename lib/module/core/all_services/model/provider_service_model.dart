import 'package:ezhandy_user/module/core/service_types/model/service_type_model.dart';

class ProviderServiceModel {
  final String? id;
  final String? userId;
  final String? title;
  final String? description;
  final String? visitCharges;
  final String? hourlyRate;
  final String? imageUrl;
  final String? radius;
  final String? rating;
  final List<String> timeSlots;
  final List<String> calendar;
  final bool isServiceActive;
  final bool isDeleted;
  final String? serviceTypeId;
  final String? subServiceId;
  final bool isQuickService;
  final String? quickServiceExtraFee;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ServiceTypeModel? serviceType;

  const ProviderServiceModel({
    this.id,
    this.userId,
    this.title,
    this.description,
    this.visitCharges,
    this.hourlyRate,
    this.imageUrl,
    this.radius,
    this.rating,
    this.timeSlots = const [],
    this.calendar = const [],
    this.isServiceActive = true,
    this.isDeleted = false,
    this.serviceTypeId,
    this.subServiceId,
    this.isQuickService = false,
    this.quickServiceExtraFee,
    this.createdAt,
    this.updatedAt,
    this.serviceType,
  });

  String get displayVisitCharges {
    final value = visitCharges?.trim();
    if (value == null || value.isEmpty) return '-';
    return _formatMoney(value);
  }

  String get serviceTypeIconUrl => serviceType?.iconImagePath?.trim() ?? '';

  String get displayHourlyRate => _formatMoney(hourlyRate);

  String get displayQuickServiceExtraFee => _formatMoney(quickServiceExtraFee);

  String get displayRadius {
    final value = radius?.trim();
    if (value == null || value.isEmpty) return '-';
    return value;
  }

  String get displayTimeSlots {
    if (timeSlots.isEmpty) return '-';

    const labels = {
      'MORNING': 'Morning (8am - 12pm)',
      'AFTERNOON': 'Afternoon (12pm - 5pm)',
      'EVENING': 'Evening (5pm - 9:30pm)',
    };

    return timeSlots
        .map((slot) => labels[slot.toUpperCase()] ?? slot)
        .join(', ');
  }

  String get displayCalendar {
    if (calendar.isEmpty) return '-';
    return calendar.join(', ');
  }

  static String _formatMoney(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return '-';

    final parsed = double.tryParse(trimmed);
    if (parsed == null) return '\$$trimmed';
    if (parsed == parsed.roundToDouble()) {
      return '\$${parsed.toInt()}';
    }
    return '\$$trimmed';
  }

  factory ProviderServiceModel.fromJson(Map<String, dynamic> json) {
    return ProviderServiceModel(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      visitCharges: json['visitCharges']?.toString(),
      hourlyRate: json['hourlyRate']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      radius: json['radius']?.toString(),
      rating: json['rating']?.toString(),
      timeSlots: _readStringList(json['timeSlots']),
      calendar: _readStringList(json['calendar']),
      isServiceActive: _readBool(json['isServiceActive'], fallback: true),
      isDeleted: _readBool(json['isDeleted']),
      serviceTypeId: json['serviceTypeId']?.toString(),
      subServiceId: json['subServiceId']?.toString(),
      isQuickService: _readBool(json['isQuickService']),
      quickServiceExtraFee: json['quickServiceExtraFee']?.toString(),
      createdAt: _readDate(json['createdAt']),
      updatedAt: _readDate(json['updatedAt']),
      serviceType: json['serviceType'] is Map
          ? ServiceTypeModel.fromJson(
              Map<String, dynamic>.from(json['serviceType'] as Map),
            )
          : null,
    );
  }

  static List<String> _readStringList(dynamic value) {
    if (value is! List) return const [];

    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
  }

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
