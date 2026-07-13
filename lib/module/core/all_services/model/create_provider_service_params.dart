import 'dart:io';

class CreateProviderServiceParams {
  final String title;
  final String description;
  final String visitCharges;
  final String hourlyRate;
  final String radius;
  final String serviceTypeId;
  final bool isQuickService;
  final bool isServiceActive;
  final List<String> timeSlots;
  final List<String> calendar;
  final String? quickServiceExtraFee;
  final File? image;

  const CreateProviderServiceParams({
    required this.title,
    required this.description,
    required this.visitCharges,
    required this.hourlyRate,
    required this.radius,
    required this.serviceTypeId,
    required this.isQuickService,
    required this.isServiceActive,
    required this.timeSlots,
    required this.calendar,
    this.image,
    this.quickServiceExtraFee,
  });
}

class ProviderServiceFieldMapper {
  ProviderServiceFieldMapper._();

  static const List<String> uiTimeSlotOptions = [
    'Morning (8am - 12pm)',
    'Afternoon (12pm - 5pm)',
    'Evening (5pm - 9:30pm)',
  ];

  static const List<String> apiTimeSlotOrder = [
    'MORNING',
    'AFTERNOON',
    'EVENING',
  ];

  static const Map<String, String> timeSlotValues = {
    'Morning (8am - 12pm)': 'MORNING',
    'Afternoon (12pm - 5pm)': 'AFTERNOON',
    'Evening (5pm - 9:30pm)': 'EVENING',
  };

  static const Map<String, String> timeSlotLabels = {
    'MORNING': 'Morning (8am - 12pm)',
    'AFTERNOON': 'Afternoon (12pm - 5pm)',
    'EVENING': 'Evening (5pm - 9:30pm)',
  };

  static String? toApiTimeSlot(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final fromUi = timeSlotValues[trimmed];
    if (fromUi != null) return fromUi;

    final upper = trimmed.toUpperCase();
    if (apiTimeSlotOrder.contains(upper)) return upper;

    return null;
  }

  static List<String> mapTimeSlots(List<String> selectedShifts) {
    final mapped = <String>{};

    for (final shift in selectedShifts) {
      final apiValue = toApiTimeSlot(shift);
      if (apiValue != null) {
        mapped.add(apiValue);
      }
    }

    return apiTimeSlotOrder.where(mapped.contains).toList();
  }

  static List<String> mapTimeSlotsToUi(List<String> apiSlots) {
    final mapped = <String>{};

    for (final slot in apiSlots) {
      final apiValue = toApiTimeSlot(slot);
      if (apiValue == null) continue;

      final uiLabel = timeSlotLabels[apiValue];
      if (uiLabel != null) {
        mapped.add(uiLabel);
      }
    }

    return uiTimeSlotOptions.where(mapped.contains).toList();
  }

  static List<String> mapCalendarDates(List<DateTime> dates) {
    return dates
        .map(
          (date) =>
              '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        )
        .toList();
  }

  static List<DateTime> parseCalendarDates(List<String> dates) {
    return dates
        .map(DateTime.tryParse)
        .whereType<DateTime>()
        .map((date) => DateTime(date.year, date.month, date.day))
        .toList();
  }

  static String formatInputAmount(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return '';

    final parsed = double.tryParse(trimmed);
    if (parsed == null) return trimmed;
    if (parsed == parsed.roundToDouble()) {
      return parsed.toInt().toString();
    }
    return trimmed;
  }
}
