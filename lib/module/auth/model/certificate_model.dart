class CertificateModel {
  final String? institutionName;
  final String? certificationTitle;
  final String? certificatePath;

  const CertificateModel({
    this.institutionName,
    this.certificationTitle,
    this.certificatePath,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      institutionName: json['institutionName']?.toString(),
      certificationTitle: json['certificationTitle']?.toString(),
      certificatePath: json['certificatePath']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'institutionName': institutionName,
        'certificationTitle': certificationTitle,
        'certificatePath': certificatePath,
      };
}
