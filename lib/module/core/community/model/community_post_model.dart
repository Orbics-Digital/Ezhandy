class CommunityPostUserModel {
  final String? id;
  final String? fullName;
  final String? profileImage;

  const CommunityPostUserModel({
    this.id,
    this.fullName,
    this.profileImage,
  });

  factory CommunityPostUserModel.fromJson(Map<String, dynamic> json) {
    return CommunityPostUserModel(
      id: json['id']?.toString(),
      fullName: json['fullName']?.toString(),
      profileImage: json['profileImage']?.toString(),
    );
  }
}

class CommunityServiceTypeModel {
  final int? id;
  final String? name;

  const CommunityServiceTypeModel({this.id, this.name});

  factory CommunityServiceTypeModel.fromJson(Map<String, dynamic> json) {
    return CommunityServiceTypeModel(
      id: _readInt(json['id']),
      name: json['name']?.toString(),
    );
  }

  static int? _readInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class CommunityCategoryModel {
  final String? id;
  final String? name;
  final String? title;
  final String? imagePath;
  final String? iconImagePath;

  const CommunityCategoryModel({
    this.id,
    this.name,
    this.title,
    this.imagePath,
    this.iconImagePath,
  });

  factory CommunityCategoryModel.fromJson(Map<String, dynamic> json) {
    return CommunityCategoryModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      title: json['title']?.toString(),
      imagePath: json['imagePath']?.toString(),
      iconImagePath: json['iconImagePath']?.toString(),
    );
  }
}

class CommunityReactionCountsModel {
  final int thumb;
  final int heart;
  final int smile;
  final int total;

  const CommunityReactionCountsModel({
    this.thumb = 0,
    this.heart = 0,
    this.smile = 0,
    this.total = 0,
  });

  factory CommunityReactionCountsModel.fromJson(Map<String, dynamic> json) {
    return CommunityReactionCountsModel(
      thumb: _readInt(json['thumb']),
      heart: _readInt(json['heart']),
      smile: _readInt(json['smile']),
      total: _readInt(json['total']),
    );
  }

  static int _readInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}

class CommunityPostModel {
  final String? id;
  final String? userId;
  final String? description;
  final String? image;
  final String? video;
  final String? productcategoryId;
  final int? serviceTypeId;
  final CommunityServiceTypeModel? serviceType;
  final CommunityCategoryModel? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isOwner;
  final CommunityPostUserModel? user;
  final CommunityReactionCountsModel reactionCounts;
  final String? myReaction;
  final int commentCount;

  const CommunityPostModel({
    this.id,
    this.userId,
    this.description,
    this.image,
    this.video,
    this.productcategoryId,
    this.serviceTypeId,
    this.serviceType,
    this.category,
    this.createdAt,
    this.updatedAt,
    this.isOwner = false,
    this.user,
    this.reactionCounts = const CommunityReactionCountsModel(),
    this.myReaction,
    this.commentCount = 0,
  });

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    return CommunityPostModel(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      description: json['description']?.toString(),
      image: json['image']?.toString(),
      video: json['video']?.toString(),
      productcategoryId: json['productcategoryId']?.toString(),
      serviceTypeId: _readNullableInt(json['serviceTypeId']),
      serviceType: json['serviceType'] is Map
          ? CommunityServiceTypeModel.fromJson(
              Map<String, dynamic>.from(json['serviceType'] as Map),
            )
          : null,
      category: json['category'] is Map
          ? CommunityCategoryModel.fromJson(
              Map<String, dynamic>.from(json['category'] as Map),
            )
          : null,
      createdAt: _readDate(json['createdAt']),
      updatedAt: _readDate(json['updatedAt']),
      isOwner: _readBool(json['isOwner']),
      user: json['user'] is Map
          ? CommunityPostUserModel.fromJson(
              Map<String, dynamic>.from(json['user'] as Map),
            )
          : null,
      reactionCounts: json['reactionCounts'] is Map
          ? CommunityReactionCountsModel.fromJson(
              Map<String, dynamic>.from(json['reactionCounts'] as Map),
            )
          : const CommunityReactionCountsModel(),
      myReaction: json['myReaction']?.toString(),
      commentCount: CommunityReactionCountsModel._readInt(json['commentCount']),
    );
  }

  CommunityPostModel copyWith({int? commentCount}) {
    return CommunityPostModel(
      id: id,
      userId: userId,
      description: description,
      image: image,
      video: video,
      productcategoryId: productcategoryId,
      serviceTypeId: serviceTypeId,
      serviceType: serviceType,
      category: category,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isOwner: isOwner,
      user: user,
      reactionCounts: reactionCounts,
      myReaction: myReaction,
      commentCount: commentCount ?? this.commentCount,
    );
  }

  static int? _readNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value == null) return false;
    return value.toString().toLowerCase() == 'true';
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
