import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/chat/data/chat_repository.dart';
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
  final RxString searchQuery = ''.obs;
  final RxBool isMyChatsLoading = false.obs;

  List<MyChatModel> get filteredMyChats {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return myChats;

    return myChats.where((chat) {
      final name = chat.otherUser?.displayName.trim().toLowerCase() ?? '';
      return name.contains(query);
    }).toList();
  }

  void setSearchQuery(String value) => searchQuery.value = value;

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
}
