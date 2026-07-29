class BookingInvoiceItemModel {
  final int qty;
  final num total;
  final num unitPrice;
  final String description;

  const BookingInvoiceItemModel({
    required this.qty,
    required this.total,
    required this.unitPrice,
    required this.description,
  });

  factory BookingInvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return BookingInvoiceItemModel(
      qty: _readInt(json['qty']) ?? 0,
      total: _readNum(json['total']) ?? 0,
      unitPrice: _readNum(json['unitPrice']) ?? 0,
      description: json['description']?.toString() ?? '',
    );
  }

  static int? _readInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static num? _readNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    return num.tryParse(value.toString());
  }
}

class BookingInvoiceModel {
  final int? id;
  final int? bookingId;
  final String? userId;
  final String? providerId;
  final List<BookingInvoiceItemModel> items;
  final String? subtotal;
  final String? tax;
  final String? taxRate;
  final String? total;
  final String? extraAmount;
  final String? extraNote;
  final bool extraPaid;
  final String? status;
  final String? pdfPath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BookingInvoiceModel({
    this.id,
    this.bookingId,
    this.userId,
    this.providerId,
    this.items = const [],
    this.subtotal,
    this.tax,
    this.taxRate,
    this.total,
    this.extraAmount,
    this.extraNote,
    this.extraPaid = false,
    this.status,
    this.pdfPath,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingInvoiceModel.fromJson(Map<String, dynamic> json) {
    return BookingInvoiceModel(
      id: _readInt(json['id']),
      bookingId: _readInt(json['bookingId']),
      userId: json['userId']?.toString(),
      providerId: json['providerId']?.toString(),
      items: _readItems(json['items']),
      subtotal: json['subtotal']?.toString(),
      tax: json['tax']?.toString(),
      taxRate: json['taxRate']?.toString(),
      total: json['total']?.toString(),
      extraAmount: json['extraAmount']?.toString(),
      extraNote: json['extraNote']?.toString(),
      extraPaid: json['extraPaid'] == true,
      status: json['status']?.toString(),
      pdfPath: json['pdfPath']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  static List<BookingInvoiceItemModel> _readItems(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => BookingInvoiceItemModel.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }

  static int? _readInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
