class CertificateModel {
  final String? id;
  final String? institutionName;
  final String? certificationTitle;
  final String? certificatePath;

  const CertificateModel({
    this.id,
    this.institutionName,
    this.certificationTitle,
    this.certificatePath,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['id']?.toString(),
      institutionName: json['institutionName']?.toString(),
      certificationTitle: json['certificationTitle']?.toString(),
      certificatePath: json['certificatePath']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'institutionName': institutionName,
        'certificationTitle': certificationTitle,
        'certificatePath': certificatePath,
      };
}
