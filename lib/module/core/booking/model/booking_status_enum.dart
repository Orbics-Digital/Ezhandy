import 'package:ezhandy_user/utils/app_strings.dart';

enum BookingStatusEnum {
  Pending(1),
  Rejected(2),
  Assigned(3),
  InRoute(4),
  Started(5),
  Completed(6),
  UserVerifiedIsDone(7),
  Cancelled(8);

  const BookingStatusEnum(this.id);

  final int id;

  static BookingStatusEnum? fromId(int? statusId) {
    if (statusId == null) return null;

    for (final status in BookingStatusEnum.values) {
      if (status.id == statusId) return status;
    }
    return null;
  }

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
    switch (fromId(statusId)) {
      case BookingStatusEnum.Pending:
        return AppStrings.pending;
      case BookingStatusEnum.Rejected:
        return AppStrings.rejected;
      case BookingStatusEnum.Assigned:
        return AppStrings.assigned;
      case BookingStatusEnum.InRoute:
        return AppStrings.inRoute;
      case BookingStatusEnum.Started:
        return AppStrings.started;
      case BookingStatusEnum.Completed:
      case BookingStatusEnum.UserVerifiedIsDone:
        return AppStrings.completed;
      case BookingStatusEnum.Cancelled:
        return AppStrings.cancelled;
      default:
        return '-';
    }
  }

  static bool showsReason(int? statusId) {
    return statusId == Rejected.id || statusId == Cancelled.id;
  }

  static bool showsUnpaidTag(int? statusId) {
    return statusId == Completed.id || statusId == UserVerifiedIsDone.id;
  }

  static bool showsVerifiedTag(int? statusId) {
    return statusId == UserVerifiedIsDone.id;
  }

  static String reasonTitle(int? statusId) {
    switch (fromId(statusId)) {
      case BookingStatusEnum.Cancelled:
        return AppStrings.cancellationReason;
      case BookingStatusEnum.Rejected:
        return AppStrings.rejectionReason;
      default:
        return AppStrings.reason;
    }
  }
}
