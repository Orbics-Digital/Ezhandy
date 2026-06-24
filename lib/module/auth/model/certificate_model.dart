class CertificateModel {
  final String? instituteName;
  final String? title;
  final String? pictureUrl;

  const CertificateModel({
    this.instituteName,
    this.title,
    this.pictureUrl,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      instituteName: json['instituteName']?.toString() ??
          json['institute_name']?.toString() ??
          json['insituteName']?.toString(),
      title: json['title']?.toString() ??
          json['certificateTitle']?.toString(),
      pictureUrl: json['pictureUrl']?.toString() ??
          json['picture']?.toString() ??
          json['certificatePicture']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'instituteName': instituteName,
        'title': title,
        'pictureUrl': pictureUrl,
      };
}
