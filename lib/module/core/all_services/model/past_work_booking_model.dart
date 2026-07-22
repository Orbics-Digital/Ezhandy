import 'package:ezhandy_user/module/core/booking/model/booking_detail_model.dart';
import 'package:intl/intl.dart';

class PastWorkBookingModel {
  final int? bookingId;
  final int? status;
  final String? statusLabel;
  final String? statusReason;
  final String? bookingDate;
  final List<String> timeSlots;
  final String? totalAmount;
  final int? duration;
  final String? notes;
  final bool isPaid;
  final DateTime? createdAt;
  final BookingDetailUserModel? customer;
  final BookingDetailServiceModel? service;
  final BookingWorkDocumentsModel workDocuments;

  const PastWorkBookingModel({
    this.bookingId,
    this.status,
    this.statusLabel,
    this.statusReason,
    this.bookingDate,
    this.timeSlots = const [],
    this.totalAmount,
    this.duration,
    this.notes,
    this.isPaid = false,
    this.createdAt,
    this.customer,
    this.service,
    this.workDocuments = const BookingWorkDocumentsModel(),
  });

  factory PastWorkBookingModel.fromJson(Map<String, dynamic> json) {
    return PastWorkBookingModel(
      bookingId: _readInt(json['bookingId']),
      status: _readInt(json['status']),
      statusLabel: json['statusLabel']?.toString(),
      statusReason: json['statusReason']?.toString(),
      bookingDate: json['bookingDate']?.toString(),
      timeSlots: _readStringList(json['timeSlots']),
      totalAmount: json['totalAmount']?.toString(),
      duration: _readInt(json['duration']),
      notes: json['notes']?.toString(),
      isPaid: _readBool(json['isPaid']),
      createdAt: _readDate(json['createdAt']),
      customer: json['customer'] is Map
          ? BookingDetailUserModel.fromJson(
              Map<String, dynamic>.from(json['customer'] as Map),
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
    );
  }

  String get displayTitle {
    final serviceTitle = service?.displayTitle;
    if (serviceTitle != null && serviceTitle != '-') return serviceTitle;

    final customerName = customer?.displayName;
    if (customerName != null && customerName != '-') {
      return customerName;
    }

    if (bookingId != null) return 'Booking #$bookingId';
    return '-';
  }

  String get displayDetail {
    final note = notes?.trim();
    if (note != null && note.isNotEmpty) return note;

    final description = service?.description?.trim();
    if (description != null && description.isNotEmpty) return description;

    final label = statusLabel?.trim();
    if (label != null && label.isNotEmpty) return label;

    return displayBookingDate;
  }

  String get displayBookingDate {
    final value = bookingDate?.trim();
    if (value == null || value.isEmpty) return '-';

    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return DateFormat('MM/dd/yyyy').format(parsed.toLocal());
    }

    return value;
  }

  List<WorkDocumentItemModel> get allWorkImages {
    return [
      ...workDocuments.before,
      ...workDocuments.after,
    ].where((item) => item.hasImage).toList();
  }
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
