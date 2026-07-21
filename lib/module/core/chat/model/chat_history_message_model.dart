import 'package:ezhandy_user/module/core/chat/model/my_chat_model.dart';

class ChatHistoryMessageModel {
  final int? id;
  final String? content;
  final String? filePath;
  final String? clientMsgId;
  final String? messageType;
  final bool isRead;
  final DateTime? createdAt;
  final String? senderId;
  final String? chatId;
  final MyChatUserModel? sender;

  const ChatHistoryMessageModel({
    this.id,
    this.content,
    this.filePath,
    this.clientMsgId,
    this.messageType,
    this.isRead = false,
    this.createdAt,
    this.senderId,
    this.chatId,
    this.sender,
  });

  String get displayContent => content?.trim() ?? '';

  String get displayFilePath => filePath?.trim() ?? '';

  bool get hasImage => displayFilePath.isNotEmpty;

  String get senderDisplayName => sender?.displayName ?? '-';

  bool isSentBy(String? currentUserId) {
    final userId = currentUserId?.trim();
    if (userId == null || userId.isEmpty) return false;
    return senderId?.trim() == userId;
  }

  factory ChatHistoryMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatHistoryMessageModel(
      id: _readInt(json['id']),
      content: json['content']?.toString(),
      filePath: json['filePath']?.toString(),
      clientMsgId: json['clientMsgId']?.toString(),
      messageType: json['messageType']?.toString(),
      isRead: _readBool(json['isRead']),
      createdAt: _readDate(json['createdAt']),
      senderId: json['senderId']?.toString(),
      chatId: json['chatId']?.toString(),
      sender: json['sender'] is Map
          ? MyChatUserModel.fromJson(
              Map<String, dynamic>.from(json['sender'] as Map),
            )
          : null,
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
