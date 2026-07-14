import 'package:intl/intl.dart';

class MyChatUserModel {
  final String? id;
  final String? fullName;
  final String? name;
  final String? profileImage;
  final String? phoneNumber;
  final bool isOnline;
  final DateTime? lastSeen;

  const MyChatUserModel({
    this.id,
    this.fullName,
    this.name,
    this.profileImage,
    this.phoneNumber,
    this.isOnline = false,
    this.lastSeen,
  });

  String get displayName {
    final value = fullName?.trim();
    if (value != null && value.isNotEmpty) return value;

    final fallback = name?.trim();
    if (fallback != null && fallback.isNotEmpty) return fallback;

    return '-';
  }

  factory MyChatUserModel.fromJson(Map<String, dynamic> json) {
    return MyChatUserModel(
      id: json['id']?.toString(),
      fullName: json['fullName']?.toString(),
      name: json['name']?.toString(),
      profileImage: json['profileImage']?.toString(),
      phoneNumber: json['phoneNumber']?.toString() ??
          json['mobileNumber']?.toString(),
      isOnline: _readBool(json['isOnline']),
      lastSeen: _readDate(json['lastSeen']),
    );
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

class MyChatLastMessageModel {
  final String? content;
  final DateTime? createdAt;

  const MyChatLastMessageModel({
    this.content,
    this.createdAt,
  });

  factory MyChatLastMessageModel.fromJson(Map<String, dynamic> json) {
    return MyChatLastMessageModel(
      content: json['content']?.toString(),
      createdAt: _readDate(json['createdAt']),
    );
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

class MyChatModel {
  final String? chatId;
  final String? chatType;
  final int unreadCount;
  final bool isLocked;
  final MyChatUserModel? otherUser;
  final MyChatLastMessageModel? lastMessage;
  final DateTime? lastMessageTime;

  const MyChatModel({
    this.chatId,
    this.chatType,
    this.unreadCount = 0,
    this.isLocked = false,
    this.otherUser,
    this.lastMessage,
    this.lastMessageTime,
  });

  String get displayLastMessage => lastMessage?.content?.trim() ?? '';

  String get displayTime {
    final date = lastMessageTime ?? lastMessage?.createdAt;
    if (date == null) return '';

    final localDate = date.toLocal();
    final now = DateTime.now();
    final diff = now.difference(localDate);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays < 7) return '${diff.inDays} d ago';

    return DateFormat('MMM dd').format(localDate);
  }

  factory MyChatModel.fromJson(Map<String, dynamic> json) {
    return MyChatModel(
      chatId: json['chatId']?.toString(),
      chatType: json['chatType']?.toString(),
      unreadCount: _readInt(json['unreadCount']) ?? 0,
      isLocked: _readBool(json['isLocked']),
      otherUser: json['otherUser'] is Map
          ? MyChatUserModel.fromJson(
              Map<String, dynamic>.from(json['otherUser'] as Map),
            )
          : null,
      lastMessage: json['lastMessage'] is Map
          ? MyChatLastMessageModel.fromJson(
              Map<String, dynamic>.from(json['lastMessage'] as Map),
            )
          : null,
      lastMessageTime: _readDate(json['lastMessageTime']),
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

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
