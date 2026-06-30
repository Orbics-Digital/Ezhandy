import 'package:ezhandy_user/utils/app_strings.dart';

enum BookingStatusEnum {
  pending(1),
  rejected(2),
  assigned(3),
  inRoute(4),
  started(5),
  completed(6),
  userVerifiedIsDone(7),
  cancelled(8);

  const BookingStatusEnum(this.id);

  final int id;

  static List<String> get dropdownLabels => [
        AppStrings.all,
        for (final status in BookingStatusEnum.values) label(status.id),
      ];

  static int? idFromLabel(String? value) {
    if (value == null || value == AppStrings.all) return null;

    for (final status in BookingStatusEnum.values) {
      if (label(status.id) == value) return status.id;
    }
    return null;
  }

  static String label(int? statusId) {
    switch (statusId) {
      case 1:
        return AppStrings.pending;
      case 2:
        return AppStrings.rejected;
      case 3:
        return AppStrings.assigned;
      case 4:
        return AppStrings.inRoute;
      case 5:
        return AppStrings.started;
      case 6:
        return AppStrings.completed;
      case 7:
        return AppStrings.verified;
      case 8:
        return AppStrings.cancelled;
      default:
        return '-';
    }
  }
}
