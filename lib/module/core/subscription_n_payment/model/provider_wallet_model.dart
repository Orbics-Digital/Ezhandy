import 'package:intl/intl.dart';

class ProviderWalletInfoModel {
  final double availableBalance;
  final double totalEarned;
  final double totalWithdrawn;
  final String? currency;

  const ProviderWalletInfoModel({
    this.availableBalance = 0,
    this.totalEarned = 0,
    this.totalWithdrawn = 0,
    this.currency,
  });

  factory ProviderWalletInfoModel.fromJson(Map<String, dynamic> json) {
    return ProviderWalletInfoModel(
      availableBalance: _readDouble(json['availableBalance']),
      totalEarned: _readDouble(json['totalEarned']),
      totalWithdrawn: _readDouble(json['totalWithdrawn']),
      currency: json['currency']?.toString(),
    );
  }
}

class ProviderWalletSummaryModel {
  final double grossTotal;
  final double commissionTotal;
  final double netTotal;

  const ProviderWalletSummaryModel({
    this.grossTotal = 0,
    this.commissionTotal = 0,
    this.netTotal = 0,
  });

  factory ProviderWalletSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProviderWalletSummaryModel(
      grossTotal: _readDouble(json['grossTotal']),
      commissionTotal: _readDouble(json['commissionTotal']),
      netTotal: _readDouble(json['netTotal']),
    );
  }
}

class ProviderPaymentLogModel {
  final String? id;
  final int? bookingId;
  final List<int> bookingIds;
  final String? bookingRef;
  final String? customer;
  final String? customerEmail;
  final double grossAmount;
  final double commission;
  final double netAmount;
  final String? currency;
  final String? status;
  final DateTime? date;

  const ProviderPaymentLogModel({
    this.id,
    this.bookingId,
    this.bookingIds = const [],
    this.bookingRef,
    this.customer,
    this.customerEmail,
    this.grossAmount = 0,
    this.commission = 0,
    this.netAmount = 0,
    this.currency,
    this.status,
    this.date,
  });

  String get displayBookingId {
    final ref = bookingRef?.trim();
    if (ref != null && ref.isNotEmpty) return ref;

    if (bookingId != null) return '#$bookingId';
    return '-';
  }

  String get displayPaymentDate {
    if (date == null) return '-';
    return DateFormat('MM/dd/yyyy').format(date!.toLocal());
  }

  String get displayCustomerName {
    final value = customer?.trim();
    if (value != null && value.isNotEmpty) return value;
    return '-';
  }

  String get displayCustomerEmail {
    final value = customerEmail?.trim();
    if (value != null && value.isNotEmpty) return value;
    return '-';
  }

  String get displayGrossAmount => _formatMoney(grossAmount, currency);

  String get displayCommission => _formatMoney(commission, currency);

  String get displayPaymentAmount => _formatMoney(netAmount, currency);

  factory ProviderPaymentLogModel.fromJson(Map<String, dynamic> json) {
    return ProviderPaymentLogModel(
      id: json['id']?.toString(),
      bookingId: _readInt(json['bookingId']),
      bookingIds: _readIntList(json['bookingIds']),
      bookingRef: json['bookingRef']?.toString(),
      customer: json['customer']?.toString(),
      customerEmail: json['customerEmail']?.toString(),
      grossAmount: _readDouble(json['grossAmount']),
      commission: _readDouble(json['commission']),
      netAmount: _readDouble(json['netAmount']),
      currency: json['currency']?.toString(),
      status: json['status']?.toString(),
      date: _readDate(json['date']),
    );
  }
}

class ProviderWalletModel {
  final ProviderWalletInfoModel wallet;
  final ProviderWalletSummaryModel summary;
  final List<ProviderPaymentLogModel> logs;

  const ProviderWalletModel({
    this.wallet = const ProviderWalletInfoModel(),
    this.summary = const ProviderWalletSummaryModel(),
    this.logs = const [],
  });

  String get displayTotalEarned =>
      _formatMoney(wallet.totalEarned, wallet.currency);

  factory ProviderWalletModel.fromJson(Map<String, dynamic> json) {
    return ProviderWalletModel(
      wallet: json['wallet'] is Map
          ? ProviderWalletInfoModel.fromJson(
              Map<String, dynamic>.from(json['wallet'] as Map),
            )
          : const ProviderWalletInfoModel(),
      summary: json['summary'] is Map
          ? ProviderWalletSummaryModel.fromJson(
              Map<String, dynamic>.from(json['summary'] as Map),
            )
          : const ProviderWalletSummaryModel(),
      logs: _readLogs(json['logs']),
    );
  }

  static List<ProviderPaymentLogModel> _readLogs(dynamic value) {
    if (value is! List) return const [];

    return value
        .whereType<Map>()
        .map(
          (item) => ProviderPaymentLogModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
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

List<int> _readIntList(dynamic value) {
  if (value is! List) return const [];

  return value
      .map((item) => _readInt(item))
      .whereType<int>()
      .toList();
}

DateTime? _readDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

String _formatMoney(num value, String? currency) {
  final symbol = currency?.trim().toLowerCase() == 'usd' ? '\$' : '\$';
  return '$symbol${value.toStringAsFixed(2)}';
}
