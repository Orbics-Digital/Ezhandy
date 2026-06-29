class ProviderBookingModel {
  final int? bookingId;
  final String? bookingDate;
  final int? status;
  final bool isPaid;
  final String? paymentId;
  final String? amount;
  final String? customerName;
  final String? customerEmail;
  final String? serviceName;
  final bool isQuickService;
  final bool isQuick;
  final String? paymentStatus;
  final DateTime? createdAt;

  const ProviderBookingModel({
    this.bookingId,
    this.bookingDate,
    this.status,
    this.isPaid = false,
    this.paymentId,
    this.amount,
    this.customerName,
    this.customerEmail,
    this.serviceName,
    this.isQuickService = false,
    this.isQuick = false,
    this.paymentStatus,
    this.createdAt,
  });

  factory ProviderBookingModel.fromJson(Map<String, dynamic> json) {
    return ProviderBookingModel(
      bookingId: _readInt(json['bookingId']),
      bookingDate: json['bookingDate']?.toString(),
      status: _readInt(json['status']),
      isPaid: _readBool(json['isPaid']),
      paymentId: json['paymentId']?.toString(),
      amount: json['amount']?.toString(),
      customerName: json['customerName']?.toString(),
      customerEmail: json['customerEmail']?.toString(),
      serviceName: json['serviceName']?.toString(),
      isQuickService: _readBool(json['isQuickService']),
      isQuick: _readBool(json['isQuick']),
      paymentStatus: json['paymentStatus']?.toString(),
      createdAt: _readDate(json['createdAt']),
    );
  }

  static int? _readInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
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
}
