import 'package:ezhandy_user/module/auth/model/certificate_model.dart';

class UserModel {
  final String? sub;
  final String? email;
  final String? fullName;
  final String? mobileNumber;
  final String? profileImage;
  final int? roleId;
  final int? languageId;
  final String? gender;
  final String? genderTitle;
  final String? languageTitle;
  final bool isEmailVerified;
  final bool isOtpVerified;
  final bool isOtpExpired;
  final bool isSubscription;
  final bool isQuickProvider;
  final String? address;
  final String? referralCode;
  final double? hourlyRate;
  final String? latitude;
  final String? longitude;
  final List<CertificateModel>? certificates;

  const UserModel({
    this.sub,
    this.email,
    this.fullName,
    this.mobileNumber,
    this.profileImage,
    this.roleId,
    this.languageId,
    this.gender,
    this.genderTitle,
    this.languageTitle,
    this.isEmailVerified = false,
    this.isOtpVerified = false,
    this.isOtpExpired = false,
    this.isSubscription = false,
    this.isQuickProvider = false,
    this.address,
    this.referralCode,
    this.hourlyRate,
    this.latitude,
    this.longitude,
    this.certificates,
  });

  List<CertificateModel> get certificateList => certificates ?? const [];

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      sub: json['sub']?.toString(),
      email: json['email']?.toString(),
      fullName: json['fullName']?.toString(),
      mobileNumber: json['mobileNumber']?.toString(),
      profileImage: json['profileImage']?.toString(),
      roleId: _readInt(json['roleId']),
      languageId: _readInt(json['languageId']),
      gender: json['gender']?.toString(),
      genderTitle: json['genderTitle']?.toString(),
      languageTitle: json['languageTitle']?.toString(),
      isEmailVerified: _readBool(json['isEmailVerified']),
      isOtpVerified: _readBool(json['isOtpVerified']),
      isOtpExpired: _readBool(json['isOtpExpired']),
      isSubscription: _readBool(json['isSubscription']),
      isQuickProvider: _readBool(json['isQuickProvider']),
      address: json['address']?.toString(),
      referralCode: json['referralCode']?.toString(),
      hourlyRate: _readDouble(json['hourlyRate']),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      certificates: _readCertificates(json),
    );
  }

  static List<CertificateModel> _readCertificates(Map<String, dynamic> json) {
    for (final key in ['certificates', 'certifications', 'certificateDetails']) {
      final value = json[key];
      if (value is List) {
        return value
            .whereType<Map>()
            .map((item) => CertificateModel.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList();
      }
    }
    return const [];
  }

  Map<String, dynamic> toJson() => {
        'sub': sub,
        'email': email,
        'fullName': fullName,
        'mobileNumber': mobileNumber,
        'profileImage': profileImage,
        'roleId': roleId,
        'languageId': languageId,
        'gender': gender,
        'genderTitle': genderTitle,
        'languageTitle': languageTitle,
        'isEmailVerified': isEmailVerified,
        'isOtpVerified': isOtpVerified,
        'isOtpExpired': isOtpExpired,
        'isSubscription': isSubscription,
        'isQuickProvider': isQuickProvider,
        'address': address,
        'referralCode': referralCode,
        'hourlyRate': hourlyRate,
        'latitude': latitude,
        'longitude': longitude,
        'certificates': certificateList.map((e) => e.toJson()).toList(),
      };

  static int? _readInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double? _readDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value == null) return false;
    return value.toString().toLowerCase() == 'true';
  }
}
