import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;

class InvoicePdf {
  static Future<Uint8List> generate({
    required String invoiceNo,
    required String billTo,
    String? bookingDate,
    String? serviceTitle,
    required List<Map<String, String>> costItems,
    required List<Map<String, String>> otherItems,
    String? subtotal,
    String? total,
    String? extraAmount,
    String? extraNote,
    bool extraPaid = false,
  }) async {
    final pdf = pw.Document();
    final hasExtraTime = _hasExtraTime(extraAmount);
    final formattedSubtotal = _formatMoney(subtotal);
    final formattedTotal = _formatMoney(total);
    final formattedExtraAmount = _formatMoney(extraAmount);

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          final widgets = <pw.Widget>[
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'INVOICE',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Invoice No: $invoiceNo'),
                    pw.Text(
                      'Booking Date: ${bookingDate?.trim().isNotEmpty == true ? bookingDate : '-'}',
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Client Name: $billTo',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Service: ${serviceTitle?.trim().isNotEmpty == true ? serviceTitle : '-'}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Cost',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Table.fromTextArray(
              headers: ['Service', 'Unit Price', 'Total Price'],
              data: costItems
                  .map(
                    (item) => [
                      item['description'] ?? '',
                      item['unitPrice'] ?? '',
                      item['total'] ?? '',
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              border: pw.TableBorder.all(width: 0.5),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerRight,
                2: pw.Alignment.centerRight,
              },
              columnWidths: {
                0: const pw.FlexColumnWidth(5),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
              },
            ),
          ];

          if (hasExtraTime) {
            final note = extraNote?.trim();
            widgets.addAll([
              pw.SizedBox(height: 20),
              pw.Text(
                'Extra Time',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                headers: ['Notes', 'Amount', 'Payment Status'],
                data: [
                  [
                    (note == null || note.isEmpty) ? '-' : note,
                    formattedExtraAmount,
                    extraPaid ? 'Paid' : 'Unpaid',
                  ],
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                border: pw.TableBorder.all(width: 0.5),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerRight,
                  2: pw.Alignment.centerRight,
                },
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                },
              ),
            ]);
          }

          widgets.addAll([
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Sub Total'),
                pw.Text(formattedSubtotal),
              ],
            ),
          ]);

          if (hasExtraTime) {
            widgets.add(
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 6),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Extra Time'),
                    pw.Text(formattedExtraAmount),
                  ],
                ),
              ),
            );
          }

          widgets.addAll([
            pw.SizedBox(height: 12),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Total: ',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  formattedTotal.isEmpty
                      ? _calculateTotal(costItems, otherItems)
                      : formattedTotal,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ]);

          return widgets;
        },
      ),
    );

    return pdf.save();
  }

  static bool _hasExtraTime(String? extraAmount) {
    final amount = double.tryParse(
      (extraAmount ?? '').trim().replaceAll('\$', ''),
    );
    return amount != null && amount > 0;
  }

  static String _formatMoney(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return '\$0.00';
    if (trimmed.startsWith('\$')) return trimmed;
    return '\$$trimmed';
  }

  static String _calculateTotal(
    List<Map<String, String>> costItems,
    List<Map<String, String>> otherItems,
  ) {
    double total = 0;
    for (final c in costItems) {
      total += double.tryParse(
            (c['total'] ?? c['price'] ?? '').replaceAll('\$', ''),
          ) ??
          0;
    }
    for (final o in otherItems) {
      total += double.tryParse(
            (o['amount'] ?? '').replaceAll('\$', ''),
          ) ??
          0;
    }
    return '\$${total.toStringAsFixed(2)}';
  }
}
