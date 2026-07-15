import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
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
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    } finally {
      isChatHistoryLoading.value = false;
    }
  }

  void clearChatHistory() => chatHistory.clear();
}
