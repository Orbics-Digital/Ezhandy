import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:ezhandy_user/core/socket/socket_constants.dart';
import 'package:ezhandy_user/core/storage/session_storage.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService extends GetxService {
  static SocketService get i {
    if (!Get.isRegistered<SocketService>()) {
      Get.put(SocketService(), permanent: true);
    }
    return Get.find<SocketService>();
  }

  io.Socket? _socket;
  String? _userId;
  String? _joinedChatId;
  final List<String> _pendingJoinChatIds = [];

  final RxBool isConnected = false.obs;
  final RxBool isUserOnline = false.obs;

  bool get isReady => isConnected.value && isUserOnline.value;

  void Function(Map<String, dynamic> data)? onIncomingMessage;
  void Function(Map<String, dynamic> data)? onChatUpdated;
  void Function(String message)? onJoinChatError;

  Future<void> connect() async {
    final session = await SessionStorage.i.load();
    if (session == null) return;

    final token = session.token.trim();
    final userId = session.user.sub?.trim();
    if (token.isEmpty || userId == null || userId.isEmpty) return;

    _userId = userId;

    if (_socket?.connected == true) {
      if (!isUserOnline.value) {
        _emitUserOnline();
      }
      return;
    }

    disconnect(clearPending: false);

    _socket = io.io(
      SocketConstants.socketBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .enableReconnection()
          .build(),
    );

    _registerListeners();
    _socket!.connect();
  }

  void _registerListeners() {
    final socket = _socket;
    if (socket == null) return;

    socket.onConnect((_) {
      isConnected.value = true;
      isUserOnline.value = false;
      _emitUserOnline();
    });

    socket.onDisconnect((_) {
      isConnected.value = false;
      isUserOnline.value = false;
    });

    socket.onConnectError((_) {
      isConnected.value = false;
      isUserOnline.value = false;
    });

    socket.on(SocketConstants.connected, (_) {});

    socket.on(SocketConstants.onlineStatus, (data) {
      final map = _asMap(data);
      if (map['status']?.toString().toLowerCase() == 'success') {
        isUserOnline.value = true;
        _processPendingJoins();
      }
    });

    socket.on(SocketConstants.joinChatError, (data) {
      final map = _asMap(data);
      onJoinChatError?.call(
        map['message']?.toString() ?? 'Failed to join chat',
      );
    });

    socket.on(SocketConstants.messageReceived, (data) {
      final map = _asMap(data);
      if (map.isNotEmpty) {
        onIncomingMessage?.call(map);
      }
    });

    socket.on(SocketConstants.chatUpdated, (data) {
      final map = _asMap(data);
      if (map.isNotEmpty) {
        onChatUpdated?.call(map);
      }
    });
  }

  void _emitUserOnline() {
    final userId = _userId?.trim();
    if (userId == null || userId.isEmpty) return;
    _socket?.emit(SocketConstants.userOnline, {'userId': userId});
  }

  Future<bool> waitUntilReady({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (isReady) return true;

    await connect();
    if (isReady) return true;

    final completer = Completer<bool>();
    late Worker worker;
    Timer? timer;

    void complete(bool value) {
      if (completer.isCompleted) return;
      timer?.cancel();
      worker.dispose();
      completer.complete(value);
    }

    worker = everAll([isConnected, isUserOnline], (_) {
      if (isReady) {
        complete(true);
      }
    });

    timer = Timer(timeout, () => complete(isReady));
    return completer.future;
  }

  void joinChat(String chatId) {
    final id = chatId.trim();
    if (id.isEmpty) return;

    if (!isUserOnline.value) {
      if (!_pendingJoinChatIds.contains(id)) {
        _pendingJoinChatIds.add(id);
      }
      return;
    }

    _emitJoinChat(id);
  }

  void _emitJoinChat(String chatId) {
    _socket?.emit(SocketConstants.joinChat, {'chatId': chatId});
    _joinedChatId = chatId;
    _pendingJoinChatIds.remove(chatId);
  }

  Future<bool> ensureReadyForChat(
    String chatId, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final id = chatId.trim();
    if (id.isEmpty) return false;

    final ready = await waitUntilReady(timeout: timeout);
    if (!ready) return false;

    joinChat(id);
    return true;
  }

  void _processPendingJoins() {
    final ids = <String>[
      ..._pendingJoinChatIds,
      if (_joinedChatId != null) _joinedChatId!,
    ];
    _pendingJoinChatIds.clear();

    final seen = <String>{};
    for (final id in ids) {
      if (seen.add(id)) {
        _emitJoinChat(id);
      }
    }
  }

  void leaveChat(String chatId) {
    final id = chatId.trim();
    if (id.isEmpty) return;

    _pendingJoinChatIds.remove(id);
    _socket?.emit(SocketConstants.leaveChat, {'chatId': id});
    if (_joinedChatId == id) {
      _joinedChatId = null;
    }
  }

  void sendMessage({
    required String chatId,
    required String senderId,
    String content = '',
    String? receiverId,
  }) {
    final id = chatId.trim();
    final from = senderId.trim();
    final text = content.trim();
    if (id.isEmpty || from.isEmpty || text.isEmpty) return;

    final payload = <String, dynamic>{
      'chatId': id,
      'messageType': 'text',
      'senderId': from,
      'content': text,
    };

    final to = receiverId?.trim();
    if (to != null && to.isNotEmpty) {
      payload['receiverId'] = to;
    }

    _socket?.emit(SocketConstants.sendMessage, payload);
  }

  Future<void> uploadFile({
    required String chatId,
    required String receiverId,
    required String clientMsgId,
    required File file,
    required String fileName,
    required String mimeType,
  }) async {
    final id = chatId.trim();
    final to = receiverId.trim();
    final msgId = clientMsgId.trim();
    if (id.isEmpty || to.isEmpty || msgId.isEmpty) return;

    final bytes = await file.readAsBytes();

    _socket?.emit(SocketConstants.uploadFile, {
      'receiverId': to,
      'chatId': id,
      'clientMsgId': msgId,
      'fileName': fileName,
      'mimeType': mimeType,
      'data': Uint8List.fromList(bytes),
    });
  }

  void disconnect({bool clearPending = true}) {
    if (clearPending) {
      _pendingJoinChatIds.clear();
      _joinedChatId = null;
    }

    _socket?.dispose();
    _socket = null;
    _userId = null;
    isConnected.value = false;
    isUserOnline.value = false;
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}
