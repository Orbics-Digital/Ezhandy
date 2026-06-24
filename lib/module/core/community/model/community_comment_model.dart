import 'package:ezhandy_user/module/core/community/model/community_post_model.dart';

class CommunityCommentModel {
  final String? id;
  final String? postId;
  final String? userId;
  final String? text;
  final DateTime? createdAt;
  final CommunityPostUserModel? user;

  const CommunityCommentModel({
    this.id,
    this.postId,
    this.userId,
    this.text,
    this.createdAt,
    this.user,
  });

  factory CommunityCommentModel.fromJson(Map<String, dynamic> json) {
    return CommunityCommentModel(
      id: json['id']?.toString(),
      postId: json['postId']?.toString(),
      userId: json['userId']?.toString(),
      text: json['text']?.toString(),
      createdAt: _readDate(json['createdAt']),
      user: json['user'] is Map
          ? CommunityPostUserModel.fromJson(
              Map<String, dynamic>.from(json['user'] as Map),
            )
          : null,
    );
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
