class AskProStatusModel {
  final int? roleId;
  final bool isAskPro;
  final bool askProActive;

  const AskProStatusModel({
    this.roleId,
    this.isAskPro = false,
    this.askProActive = false,
  });

  factory AskProStatusModel.fromJson(Map<String, dynamic> json) {
    return AskProStatusModel(
      roleId: _readInt(json['roleId']),
      isAskPro: _readBool(json['isAskPro']),
      askProActive: _readBool(json['askProActive']),
    );
  }

  static int? _readInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value == null) return false;
    return value.toString().toLowerCase() == 'true';
  }
}
