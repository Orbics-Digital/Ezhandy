import 'package:ezhandy_user/module/core/community/model/community_post_model.dart';

class CommunityReactionsCountsModel {
  final int all;
  final int thumb;
  final int heart;
  final int smile;

  const CommunityReactionsCountsModel({
    this.all = 0,
    this.thumb = 0,
    this.heart = 0,
    this.smile = 0,
  });

  factory CommunityReactionsCountsModel.fromJson(Map<String, dynamic> json) {
    return CommunityReactionsCountsModel(
      all: _readInt(json['all']),
      thumb: _readInt(json['thumb']),
      heart: _readInt(json['heart']),
      smile: _readInt(json['smile']),
    );
  }

  static int _readInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}

class CommunityReactionItemModel {
  final String? id;
  final String? userId;
  final String? reactionType;
  final DateTime? createdAt;
  final CommunityPostUserModel? user;

  const CommunityReactionItemModel({
    this.id,
    this.userId,
    this.reactionType,
    this.createdAt,
    this.user,
  });

  factory CommunityReactionItemModel.fromJson(Map<String, dynamic> json) {
    return CommunityReactionItemModel(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      reactionType: json['reactionType']?.toString(),
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

class CommunityReactionsData {
  final CommunityReactionsCountsModel counts;
  final List<CommunityReactionItemModel> reactions;

  const CommunityReactionsData({
    required this.counts,
    required this.reactions,
  });
}
