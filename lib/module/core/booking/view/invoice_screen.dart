import 'package:ezhandy_user/module/core/booking/controller/bookings_controller.dart';
import 'package:ezhandy_user/module/core/booking/model/booking_invoice_model.dart';
import 'package:ezhandy_user/module/core/booking/view/pdf.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';

class InvoiceScreen extends StatefulWidget {
  final int? bookingId;

  const InvoiceScreen({
    this.bookingId,
    super.key,
  });

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final BookingsController _bookingsController = BookingsController.i;

  @override
  void initState() {
    super.initState();
    final bookingId = widget.bookingId;
    if (bookingId != null) {
      _bookingsController.fetchBookingInvoice(bookingId);
      _bookingsController.fetchBookingDetail(bookingId);
    }
  }

  @override
  void dispose() {
    _bookingsController.clearBookingInvoice();
    super.dispose();
  }

  String _formatAmount(num? value) {
    if (value == null) return '\$0.00';
    return '\$${value.toStringAsFixed(2)}';
  }

  String _formatTotal(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return '\$0.00';
    if (trimmed.startsWith('\$')) return trimmed;
    return '\$$trimmed';
  }

  double? _parseExtraAmount(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return double.tryParse(trimmed.replaceAll('\$', ''));
  }

  bool _hasExtraTime(BookingInvoiceModel? invoice) {
    final amount = _parseExtraAmount(invoice?.extraAmount);
    return amount != null && amount > 0;
  }

  List<Map<String, String>> _costItemsFromInvoice(BookingInvoiceModel? invoice) {
    return (invoice?.items ?? const [])
        .map(
          (item) => {
            'description': item.description,
            'unitPrice': _formatAmount(item.unitPrice),
            'total': _formatAmount(item.total),
          },
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      leading: AssetPath.backIcon,
      onclickLead: () {
        Get.back();
      },
      title: AppStrings.invoice,
      actionWidget: downloadBtnWidget(),
      child: Obx(() {
        final isInvoiceLoading =
            _bookingsController.isBookingInvoiceLoading.value;
        final isDetailLoading =
            _bookingsController.isBookingDetailLoading.value;
        final invoice = _bookingsController.bookingInvoice.value;
        final detail = _bookingsController.bookingDetail.value;
        final costItems = _costItemsFromInvoice(invoice);
        final clientName = detail?.user?.displayName ?? '-';
        final bookingDate = detail?.displayBookingDate ?? '-';
        final serviceTitle = detail?.service?.displayTitle ?? '-';

        if ((isInvoiceLoading && invoice == null) ||
            (isDetailLoading && detail == null)) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.orange),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(
                invoiceNo:
                    (invoice?.bookingId ?? widget.bookingId)?.toString() ?? '-',
                clientName: clientName,
                bookingDate: bookingDate,
                serviceTitle: serviceTitle,
              ),
              const SizedBox(height: 20),
              CustomText(
                text: AppStrings.cost,
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
              10.verticalSpace,
              _buildCostTable(costItems),
              // const SizedBox(height: 20),
              // CustomText(
              //   text: AppStrings.other,
              //   fontWeight: FontWeight.w600,
              //   fontSize: 16.sp,
              // ),
              // 10.verticalSpace,
              // _buildOtherTable(const []),
              if (_hasExtraTime(invoice)) ...[
                const SizedBox(height: 20),
                _buildExtraTimeSection(invoice!),
              ],
              const SizedBox(height: 20),
              if (invoice != null) _buildBreakdownSection(invoice),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Total: ${_formatTotal(invoice?.total)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              25.verticalSpace
            ],
          ),
        );
      }),
    );
  }

  Padding downloadBtnWidget() {
    return Padding(
      padding: const EdgeInsets.only(right: AppPadding.padding12),
      child: CustomButton(
        width: 140.w,
        onclick: () async {
          final invoice = _bookingsController.bookingInvoice.value;
          final detail = _bookingsController.bookingDetail.value;
          final costItems = _costItemsFromInvoice(invoice);
          final pdfFile = await InvoicePdf.generate(
            invoiceNo:
                (invoice?.bookingId ?? widget.bookingId)?.toString() ?? '-',
            billTo: detail?.user?.displayName ?? '-',
            bookingDate: detail?.displayBookingDate ?? '-',
            serviceTitle: detail?.service?.displayTitle ?? '-',
            costItems: costItems,
            otherItems: const [],
            subtotal: invoice?.subtotal,
            total: invoice?.total,
            extraAmount: invoice?.extraAmount,
            extraNote: invoice?.extraNote,
            extraPaid: invoice?.extraPaid ?? false,
          );
          await Printing.layoutPdf(onLayout: (_) => pdfFile);
        },
        text: AppStrings.downloadPdf,
      ),
    );
  }

  Widget _buildHeader({
    required String invoiceNo,
    required String clientName,
    required String bookingDate,
    required String serviceTitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'INVOICE',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Invoice No: $invoiceNo'),
                  Text('Client Name: $clientName'),
                  Text('Service: $serviceTitle'),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Booking Date: $bookingDate'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBreakdownSection(BookingInvoiceModel invoice) {
    final rows = <MapEntry<String, String>>[
      MapEntry(AppStrings.subtotal, _formatTotal(invoice.subtotal)),
    ];

    if (_hasExtraTime(invoice)) {
      rows.add(
        MapEntry(AppStrings.extraTime, _formatTotal(invoice.extraAmount)),
      );
    }

    return Column(
      children: rows
          .map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    row.key,
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    row.value,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildExtraTimeSection(BookingInvoiceModel invoice) {
    final note = invoice.extraNote?.trim();
    final amount = _formatTotal(invoice.extraAmount);
    final paymentLabel =
        invoice.extraPaid ? AppStrings.paid : AppStrings.unpaid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomText(
          text: AppStrings.extraTime,
          fontWeight: FontWeight.w600,
          fontSize: 16.sp,
        ),
        10.verticalSpace,
        Table(
          border: TableBorder.all(),
          columnWidths: const {
            0: FlexColumnWidth(4),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
          },
          children: [
            _buildHeaderRow([
              AppStrings.notes,
              AppStrings.amount,
              AppStrings.paymentStatus,
            ]),
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFEFEFEF)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    (note == null || note.isEmpty) ? '-' : note,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(amount, textAlign: TextAlign.right),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(paymentLabel, textAlign: TextAlign.right),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCostTable(List<Map<String, String>> costItems) {
    return Table(
      border: TableBorder.all(),
      columnWidths: const {
        0: FlexColumnWidth(4),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
      },
      children: [
        _buildHeaderRow(['Service', 'Unit Price', 'Total Price']),
        ...costItems.map(
          (item) => TableRow(
            decoration: const BoxDecoration(color: Color(0xFFEFEFEF)),
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(item['description'] ?? ''),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  item['unitPrice'] ?? '',
                  textAlign: TextAlign.right,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  item['total'] ?? '',
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtherTable(List<Map<String, String>> otherItems) {
    return Table(
      border: TableBorder.all(),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
      },
      children: [
        _buildHeaderRow(['Item', 'Description', 'Price', 'Amount']),
        ...otherItems.map(
          (item) => TableRow(
            decoration: const BoxDecoration(color: Color(0xFFEFEFEF)),
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(item['item']!),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(item['description']!),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(item['price']!, textAlign: TextAlign.right),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(item['amount']!, textAlign: TextAlign.right),
              ),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _buildHeaderRow(List<String> headers) {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFEFEFEF)),
      children: headers
          .map(
            (h) => Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                h,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
          .toList(),
    );
  }
}
