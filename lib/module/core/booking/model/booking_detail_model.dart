import 'package:ezhandy_user/module/core/booking/model/booking_status_enum.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:intl/intl.dart';

class BookingDetailUserModel {
  final String? id;
  final String? fullName;
  final String? email;
  final String? mobileNumber;
  final String? profileImage;
  final String? address;
  final String? latitude;
  final String? longitude;

  const BookingDetailUserModel({
    this.id,
    this.fullName,
    this.email,
    this.mobileNumber,
    this.profileImage,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory BookingDetailUserModel.fromJson(Map<String, dynamic> json) {
    return BookingDetailUserModel(
      id: json['id']?.toString(),
      fullName: json['fullName']?.toString(),
      email: json['email']?.toString(),
      mobileNumber: json['mobileNumber']?.toString(),
      profileImage: json['profileImage']?.toString(),
      address: json['address']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }

  String get displayName {
    final value = fullName?.trim();
    if (value != null && value.isNotEmpty) return value;
    return '-';
  }

  String get displayEmail {
    final value = email?.trim();
    if (value != null && value.isNotEmpty) return value;
    return '-';
  }

  String get displayPhone {
    final value = mobileNumber?.trim();
    if (value != null && value.isNotEmpty) return value;
    return '-';
  }

  String get displayAddress {
    final value = address?.trim();
    if (value != null && value.isNotEmpty) return value;
    return '-';
  }
}

class BookingDetailProviderModel {
  final String? id;
  final String? fullName;
  final String? email;
  final String? mobileNumber;
  final String? profileImage;
  final String? address;
  final String? location;
  final String? latitude;
  final String? longitude;

  const BookingDetailProviderModel({
    this.id,
    this.fullName,
    this.email,
    this.mobileNumber,
    this.profileImage,
    this.address,
    this.location,
    this.latitude,
    this.longitude,
  });

  factory BookingDetailProviderModel.fromJson(Map<String, dynamic> json) {
    return BookingDetailProviderModel(
      id: json['id']?.toString(),
      fullName: json['fullName']?.toString(),
      email: json['email']?.toString(),
      mobileNumber: json['mobileNumber']?.toString(),
      profileImage: json['profileImage']?.toString(),
      address: json['address']?.toString(),
      location: json['location']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }
}

class BookingDetailServiceModel {
  final int? id;
  final String? title;
  final String? description;
  final String? visitCharges;
  final String? hourlyRate;
  final bool isQuickService;

  const BookingDetailServiceModel({
    this.id,
    this.title,
    this.description,
    this.visitCharges,
    this.hourlyRate,
    this.isQuickService = false,
  });

  factory BookingDetailServiceModel.fromJson(Map<String, dynamic> json) {
    return BookingDetailServiceModel(
      id: _readInt(json['id']),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      visitCharges: json['visitCharges']?.toString(),
      hourlyRate: json['hourlyRate']?.toString(),
      isQuickService: _readBool(json['isQuickService']),
    );
  }

  String get displayTitle {
    final value = title?.trim();
    if (value != null && value.isNotEmpty) return value;
    return '-';
  }

  String get displayVisitCharges => _formatMoney(visitCharges);

  String get displayHourlyRate => _formatMoney(hourlyRate);
}

class BookingWorkDocumentsModel {
  final List<String> before;
  final List<String> after;

  const BookingWorkDocumentsModel({
    this.before = const [],
    this.after = const [],
  });

  factory BookingWorkDocumentsModel.fromJson(Map<String, dynamic> json) {
    return BookingWorkDocumentsModel(
      before: _readStringList(json['before']),
      after: _readStringList(json['after']),
    );
  }
}

class BookingDetailModel {
  final int? id;
  final int? status;
  final String? statusLabel;
  final String? statusReason;
  final String? bookingDate;
  final List<String> timeSlots;
  final String? totalAmount;
  final int? duration;
  final String? bookingType;
  final String? notes;
  final bool isPaid;
  final String? paymentId;
  final DateTime? createdAt;
  final BookingDetailUserModel? user;
  final BookingDetailProviderModel? provider;
  final BookingDetailServiceModel? service;
  final BookingWorkDocumentsModel workDocuments;
  final dynamic invoice;

  const BookingDetailModel({
    this.id,
    this.status,
    this.statusLabel,
    this.statusReason,
    this.bookingDate,
    this.timeSlots = const [],
    this.totalAmount,
    this.duration,
    this.bookingType,
    this.notes,
    this.isPaid = false,
    this.paymentId,
    this.createdAt,
    this.user,
    this.provider,
    this.service,
    this.workDocuments = const BookingWorkDocumentsModel(),
    this.invoice,
  });

  String get displayBookingId {
    if (id != null) return '#$id';
    return '-';
  }

  String get displayBookingDate => _formatDate(bookingDate);

  String get displayServiceDate => _formatDate(bookingDate);

  String get displayServiceTime => _formatTimeSlots(timeSlots);

  String get displayStatusLabel => jobStatusLabel;

  String get displayReason {
    final value = statusReason?.trim();
    if (value != null && value.isNotEmpty) return value;
    return '-';
  }

  String get jobStatusLabel {
    switch (BookingStatusEnum.fromId(status)) {
      case BookingStatusEnum.Assigned:
        return AppStrings.approved;
      case BookingStatusEnum.Completed:
      case BookingStatusEnum.UserVerifiedIsDone:
        return isPaid
            ? AppStrings.completedPaid
            : AppStrings.completedUnPaid;
      default:
        final label = statusLabel?.trim();
        if (label != null && label.isNotEmpty) {
          return _normalizeStatusLabel(label);
        }
        return BookingStatusEnum.label(status);
    }
  }

  factory BookingDetailModel.fromJson(Map<String, dynamic> json) {
    return BookingDetailModel(
      id: _readInt(json['id']),
      status: _readInt(json['status']),
      statusLabel: json['statusLabel']?.toString(),
      statusReason: json['statusReason']?.toString(),
      bookingDate: json['bookingDate']?.toString(),
      timeSlots: _readStringList(json['timeSlots']),
      totalAmount: json['totalAmount']?.toString(),
      duration: _readInt(json['duration']),
      bookingType: json['bookingType']?.toString(),
      notes: json['notes']?.toString(),
      isPaid: _readBool(json['isPaid']),
      paymentId: json['paymentId']?.toString(),
      createdAt: _readDate(json['createdAt']),
      user: json['user'] is Map
          ? BookingDetailUserModel.fromJson(
              Map<String, dynamic>.from(json['user'] as Map),
            )
          : null,
      provider: json['provider'] is Map
          ? BookingDetailProviderModel.fromJson(
              Map<String, dynamic>.from(json['provider'] as Map),
            )
          : null,
      service: json['service'] is Map
          ? BookingDetailServiceModel.fromJson(
              Map<String, dynamic>.from(json['service'] as Map),
            )
          : null,
      workDocuments: json['workDocuments'] is Map
          ? BookingWorkDocumentsModel.fromJson(
              Map<String, dynamic>.from(json['workDocuments'] as Map),
            )
          : const BookingWorkDocumentsModel(),
      invoice: json['invoice'],
    );
  }
}

String _normalizeStatusLabel(String label) {
  final normalized = label.trim().toLowerCase();
  if (normalized == 'cancelled') return AppStrings.cancelled;
  if (normalized == 'rejected') return AppStrings.rejected;
  if (normalized == 'pending') return AppStrings.pending;
  if (normalized == 'assigned' || normalized == 'approved') {
    return AppStrings.approved;
  }
  if (normalized == 'in route' || normalized == 'in-route') {
    return AppStrings.inRoute;
  }
  if (normalized == 'started') return AppStrings.started;
  if (normalized == 'completed') {
    return AppStrings.completedPaid;
  }
  return label;
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

List<String> _readStringList(dynamic value) {
  if (value is! List) return const [];

  return value
      .map((item) => item?.toString().trim() ?? '')
      .where((item) => item.isNotEmpty)
      .toList();
}

String _formatDate(String? value) {
  if (value == null || value.trim().isEmpty) return '-';

  final parsed = DateTime.tryParse(value);
  if (parsed != null) {
    return DateFormat('MM/dd/yyyy').format(parsed.toLocal());
  }

  return value;
}

String _formatTimeSlots(List<String> slots) {
  if (slots.isEmpty) return '-';

  return slots.map(_formatTimeSlot).join(', ');
}

String _formatTimeSlot(String value) {
  final normalized = value.trim().toLowerCase().replaceAll('_', ' ');
  if (normalized.isEmpty) return '-';

  return normalized
      .split(' ')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}

String _formatMoney(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return '-';

  final parsed = double.tryParse(trimmed);
  if (parsed != null) {
    return '\$${parsed.toStringAsFixed(2)}';
  }

  return trimmed.startsWith('\$') ? trimmed : '\$$trimmed';
}
