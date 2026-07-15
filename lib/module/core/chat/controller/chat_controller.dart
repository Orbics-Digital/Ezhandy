import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/core/socket/socket_service.dart';
import 'package:ezhandy_user/module/auth/controller/auth_controller.dart';
import 'package:ezhandy_user/module/core/chat/data/chat_repository.dart';
import 'package:ezhandy_user/module/core/chat/model/chat_history_message_model.dart';
import 'package:ezhandy_user/module/core/chat/model/my_chat_model.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  static ChatController get i {
    if (!Get.isRegistered<ChatController>()) {
      Get.put(ChatController(), permanent: true);
    }
    return Get.find<ChatController>();
  }

  final ChatRepository _repository = ChatRepository();

  final RxList<MyChatModel> myChats = <MyChatModel>[].obs;
  final RxList<ChatHistoryMessageModel> chatHistory =
      <ChatHistoryMessageModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString proChatSearchQuery = ''.obs;
  final RxBool isMyChatsLoading = false.obs;
  final RxBool isChatHistoryLoading = false.obs;

  String? _activeChatId;
  String? _activeReceiverId;
  String? _activeOtherUserImage;

  @override
  void onInit() {
    super.onInit();
    final socket = SocketService.i;
    socket.onIncomingMessage = _onMessageReceived;
    socket.onChatUpdated = (_) => refreshMyChats();
    socket.onJoinChatError = (message) {
      AppDialogs.showToast(message: message);
    };
  }

  List<MyChatModel> get filteredMyChats => _filterChatsByType(
        chatType: 'private',
        query: searchQuery.value,
      );

  List<MyChatModel> get filteredProChats => _filterChatsByType(
        chatType: 'ask_pro',
        query: proChatSearchQuery.value,
      );

  List<MyChatModel> _filterChatsByType({
    required String chatType,
    required String query,
  }) {
    final typedChats = myChats.where(
      (chat) => chat.chatType?.trim().toLowerCase() == chatType,
    );

    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return typedChats.toList();

    return typedChats.where((chat) {
      final name = chat.otherUser?.displayName.trim().toLowerCase() ?? '';
      return name.contains(normalizedQuery);
    }).toList();
  }

  void setSearchQuery(String value) => searchQuery.value = value;

  void setProChatSearchQuery(String value) => proChatSearchQuery.value = value;

  Future<void> fetchMyChats() async {
    if (isMyChatsLoading.value) return;

    isMyChatsLoading.value = true;
    try {
      final chats = await _repository.getMyChats();
      myChats.assignAll(chats);
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    } finally {
      isMyChatsLoading.value = false;
    }
  }

  Future<void> refreshMyChats() async {
    try {
      final chats = await _repository.getMyChats();
      myChats.assignAll(chats);
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    }
  }

  Future<void> fetchChatHistory(
    String chatId, {
    int limit = 30,
    int offset = 0,
  }) async {
    final id = chatId.trim();
    if (id.isEmpty || isChatHistoryLoading.value) return;

    isChatHistoryLoading.value = true;
    try {
      final messages = await _repository.getChatHistory(
        id,
        limit: limit,
        offset: offset,
      );
      chatHistory.assignAll(messages);
      if (_activeChatId == id) {
        _activeOtherUserImage ??= _otherUserImageFromHistory();
      }
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    } finally {
      isChatHistoryLoading.value = false;
    }
  }

  void clearChatHistory() => chatHistory.clear();

  void setActiveChat(
    String? chatId, {
    String? receiverId,
    String? otherUserImage,
  }) {
    final next = chatId?.trim();
    final previous = _activeChatId;

    if (previous != null &&
        previous.isNotEmpty &&
        previous != next) {
      SocketService.i.leaveChat(previous);
    }

    _activeChatId = (next != null && next.isNotEmpty) ? next : null;
    _activeReceiverId = _resolveReceiverId(_activeChatId, receiverId);
    _activeOtherUserImage =
        _resolveOtherUserImage(_activeChatId, otherUserImage);

    if (_activeChatId != null) {
      SocketService.i.joinChat(_activeChatId!);
    }
  }

  void clearActiveChat() {
    final chatId = _activeChatId;
    if (chatId != null && chatId.isNotEmpty) {
      SocketService.i.leaveChat(chatId);
    }
    _activeChatId = null;
    _activeReceiverId = null;
    _activeOtherUserImage = null;
  }

  String? resolveSenderProfileImage(ChatHistoryMessageModel message) {
    final fromSender = message.sender?.profileImage?.trim();
    if (fromSender != null && fromSender.isNotEmpty) return fromSender;

    final userId = AuthController.i.user.value?.sub?.trim();
    if (message.isSentBy(userId)) {
      return AuthController.i.user.value?.profileImage?.trim();
    }

    final cached = _activeOtherUserImage?.trim();
    if (cached != null && cached.isNotEmpty) return cached;

    return _otherUserImageFromHistory();
  }

  void sendChatMessage(String content) {
    final chatId = _activeChatId;
    final text = content.trim();
    if (chatId == null || chatId.isEmpty || text.isEmpty) return;

    final currentUser = AuthController.i.user.value;
    final userId = currentUser?.sub?.trim();
    if (userId == null || userId.isEmpty) return;

    final optimistic = ChatHistoryMessageModel(
      content: text,
      messageType: 'text',
      createdAt: DateTime.now().toUtc(),
      senderId: userId,
      chatId: chatId,
      sender: currentUser == null
          ? null
          : MyChatUserModel(
              id: userId,
              fullName: currentUser.fullName,
              profileImage: currentUser.profileImage,
            ),
    );
    chatHistory.add(optimistic);
    chatHistory.refresh();

    SocketService.i.sendMessage(
      chatId: chatId,
      content: text,
      senderId: userId,
      receiverId: _activeReceiverId,
    );
  }

  void _onMessageReceived(Map<String, dynamic> data) {
    final messageJson = _extractMessageJson(data);
    if (messageJson == null) return;

    final message = _withSenderImage(ChatHistoryMessageModel.fromJson(messageJson));
    final chatId = message.chatId?.trim() ?? _activeChatId;
    if (_activeChatId == null || chatId != _activeChatId) return;

    if (message.id != null &&
        chatHistory.any((item) => item.id == message.id)) {
      return;
    }

    final userId = AuthController.i.user.value?.sub?.trim();
    if (message.isSentBy(userId)) {
      final optimisticIndex = chatHistory.lastIndexWhere(
        (item) =>
            item.id == null &&
            item.isSentBy(userId) &&
            item.displayContent == message.displayContent,
      );
      if (optimisticIndex >= 0) {
        final preservedImage =
            chatHistory[optimisticIndex].sender?.profileImage;
        chatHistory[optimisticIndex] = _withSenderImage(
          message,
          preserveSenderImage: preservedImage,
        );
        chatHistory.refresh();
        return;
      }
    }

    chatHistory.add(message);
    chatHistory.refresh();
  }

  ChatHistoryMessageModel _withSenderImage(
    ChatHistoryMessageModel message, {
    String? preserveSenderImage,
  }) {
    final image = resolveSenderProfileImage(message) ??
        preserveSenderImage?.trim();
    if (image == null || image.isEmpty) return message;

    final sender = message.sender;
    return ChatHistoryMessageModel(
      id: message.id,
      content: message.content,
      messageType: message.messageType,
      isRead: message.isRead,
      createdAt: message.createdAt,
      senderId: message.senderId,
      chatId: message.chatId,
      sender: MyChatUserModel(
        id: sender?.id ?? message.senderId,
        fullName: sender?.fullName,
        name: sender?.name,
        profileImage: image,
        phoneNumber: sender?.phoneNumber,
        isOnline: sender?.isOnline ?? false,
        lastSeen: sender?.lastSeen,
      ),
    );
  }

  String? _resolveOtherUserImage(String? chatId, String? otherUserImage) {
    final explicit = otherUserImage?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;

    final id = chatId?.trim();
    if (id == null || id.isEmpty) return null;

    for (final chat in myChats) {
      if (chat.chatId?.trim() == id) {
        return chat.otherUser?.profileImage?.trim();
      }
    }

    return null;
  }

  String? _otherUserImageFromHistory() {
    final userId = AuthController.i.user.value?.sub?.trim();
    for (final item in chatHistory) {
      if (item.isSentBy(userId)) continue;
      final image = item.sender?.profileImage?.trim();
      if (image != null && image.isNotEmpty) return image;
    }
    return null;
  }

  String? _resolveReceiverId(String? chatId, String? receiverId) {
    final explicit = receiverId?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;

    final id = chatId?.trim();
    if (id == null || id.isEmpty) return null;

    for (final chat in myChats) {
      if (chat.chatId?.trim() == id) {
        return chat.otherUser?.id?.trim();
      }
    }

    return null;
  }

  Map<String, dynamic>? _extractMessageJson(Map<String, dynamic> data) {
    if (data.containsKey('content') || data.containsKey('id')) return data;

    final nested = data['data'];
    if (nested is Map) {
      return Map<String, dynamic>.from(nested);
    }

    final message = data['message'];
    if (message is Map) {
      return Map<String, dynamic>.from(message);
    }

    return null;
  }
}
