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
  final File image;

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
    required this.image,
    this.quickServiceExtraFee,
  });
}

class ProviderServiceFieldMapper {
  ProviderServiceFieldMapper._();

  static const Map<String, String> timeSlotValues = {
    'Morning (8am - 12pm)': 'MORNING',
    'Afternoon (12pm - 5pm)': 'AFTERNOON',
    'Evening (5pm - 9:30pm)': 'EVENING',
  };

  static List<String> mapTimeSlots(List<String> selectedShifts) {
    return selectedShifts
        .map((shift) => timeSlotValues[shift])
        .whereType<String>()
        .toList();
  }

  static List<String> mapCalendarDates(List<DateTime> dates) {
    return dates
        .map(
          (date) =>
              '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        )
        .toList();
  }
}
