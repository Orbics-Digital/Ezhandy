import 'dart:io';

class RegisterProviderParams {
  final String fullName;
  final String email;
  final String? mobileNumber;
  final int languageId;
  final String gender;
  final String password;
  final String address;
  final String aboutUs;
  final int experience;
  final String? referredBy;
  final File? profileImage;
  final List<String> institutionNames;
  final List<String> certificationTitles;
  final List<File> certificationImages;

  const RegisterProviderParams({
    required this.fullName,
    required this.email,
    this.mobileNumber,
    required this.languageId,
    required this.gender,
    required this.password,
    required this.address,
    required this.aboutUs,
    required this.experience,
    this.referredBy,
    this.profileImage,
    required this.institutionNames,
    required this.certificationTitles,
    required this.certificationImages,
  });
}

class SignUpFieldMapper {
  SignUpFieldMapper._();

  static int languageIdFromLabel(String? label) {
    switch (label) {
      case 'Spanish':
        return 2;
      case 'French':
        return 3;
      case 'English':
      default:
        return 1;
    }
  }

  static String genderCode(String? gender) {
    if (gender == 'Female') return 'F';
    return 'M';
  }
}
