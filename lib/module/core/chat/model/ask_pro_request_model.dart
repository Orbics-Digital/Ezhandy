import 'package:ezhandy_user/module/core/service_types/model/service_type_model.dart';

class AskProRequestUserModel {
  final String? id;
  final String? fullName;
  final String? profileImage;
  final String? mobileNumber;
  final String? email;

  const AskProRequestUserModel({
    this.id,
    this.fullName,
    this.profileImage,
    this.mobileNumber,
    this.email,
  });

  String get displayName {
    final value = fullName?.trim();
    if (value != null && value.isNotEmpty) return value;
    return '-';
  }

  factory AskProRequestUserModel.fromJson(Map<String, dynamic> json) {
    return AskProRequestUserModel(
      id: json['id']?.toString(),
      fullName: json['fullName']?.toString(),
      profileImage: json['profileImage']?.toString(),
      mobileNumber: json['mobileNumber']?.toString(),
      email: json['email']?.toString(),
    );
  }
}

class AskProRequestModel {
  final String? id;
  final String? userId;
  final int? serviceTypeId;
  final String? question;
  final List<String> imagePaths;
  final String? videoPath;
  final String? status;
  final DateTime? createdAt;
  final ServiceTypeModel? serviceType;
  final AskProRequestUserModel? user;

  const AskProRequestModel({
    this.id,
    this.userId,
    this.serviceTypeId,
    this.question,
    this.imagePaths = const [],
    this.videoPath,
    this.status,
    this.createdAt,
    this.serviceType,
    this.user,
  });

  String get displayTitle {
    final serviceName = serviceType?.displayName.trim();
    if (serviceName != null && serviceName.isNotEmpty) {
      return 'You Have A New $serviceName Request';
    }
    return 'You Have A New Job Request';
  }

  String get displayQuestion {
    final value = question?.trim();
    if (value != null && value.isNotEmpty) return value;
    return '-';
  }

  factory AskProRequestModel.fromJson(Map<String, dynamic> json) {
    return AskProRequestModel(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      serviceTypeId: _readInt(json['serviceTypeId']),
      question: json['question']?.toString(),
      imagePaths: _readStringList(json['imagePaths']),
      videoPath: json['videoPath']?.toString(),
      status: json['status']?.toString(),
      createdAt: _readDate(json['createdAt']),
      serviceType: json['serviceType'] is Map
          ? ServiceTypeModel.fromJson(
              Map<String, dynamic>.from(json['serviceType'] as Map),
            )
          : null,
      user: json['user'] is Map
          ? AskProRequestUserModel.fromJson(
              Map<String, dynamic>.from(json['user'] as Map),
            )
          : null,
    );
  }

  static int? _readInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static List<String> _readStringList(dynamic value) {
    if (value is! List) return const [];

    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
