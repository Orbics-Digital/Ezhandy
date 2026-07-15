class PageModel {
  final String? id;
  final String? slug;
  final String? title;
  final String? content;
  final DateTime? updatedAt;

  const PageModel({
    this.id,
    this.slug,
    this.title,
    this.content,
    this.updatedAt,
  });

  factory PageModel.fromJson(Map<String, dynamic> json) {
    return PageModel(
      id: json['id']?.toString(),
      slug: json['slug']?.toString(),
      title: json['title']?.toString(),
      content: json['content']?.toString(),
      updatedAt: _readDate(json['updatedAt']),
    );
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
