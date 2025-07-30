import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:swapbuy/Model/Conversation.dart';
import 'package:swapbuy/Model/Message.dart';
import 'package:swapbuy/Services/ChatService.dart';
import 'package:swapbuy/Services/NetworkClient.dart';
import 'package:swapbuy/Constant/url.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';
import 'package:http/http.dart' as http;

class ChatPageUser1Controller with ChangeNotifier {
  /// Resets chat state before starting a new chat/conversation
  void resetChatState() {
    listMessage.clear();
    chatService?.close();
    chatService = null;
    conversationId = null;
    user2Id = null;
    notifyListeners();
  }

  late final NetworkClient client;
  List<Conversation> listConversation = [];
  List<Message> listMessage = [];
  ScrollController scrollController = ScrollController();
  ChatService? chatService;
  final TextEditingController controller = TextEditingController();
  String? conversationId;
  int? user1Id;
  int? user2Id;

  ChatPageUser1Controller(this.user1Id) {
    client = NetworkClient(http.Client(), ServicesProvider());
  }

  @override
  void dispose() {
    chatService?.close();
    controller.dispose();
    super.dispose();
  }

  void sendMessage() {
    if (controller.text.isNotEmpty && user1Id != null && user2Id != null) {
      if (chatService == null) {
      } else {}
      chatService?.sendMessage(controller.text, user1Id!, user2Id!);
      controller.clear();
    } else {}
  }

  void startListeningToMessages() {
    chatService?.stream.listen(
      (data) {
        final messageData = jsonDecode(data.toString());
        final messageContent = messageData['message'];
        final senderName = messageData['sender_name'];
        final senderId = messageData['sender_id'];
        final message = Message(
          senderName: senderName,
          content: messageContent,
          sender: senderId,
        );
        addMessageIfNotExists(message);
      },
      onError: (e) {},
      onDone: () {},
    );
  }

  void addMessageIfNotExists(Message message) {
    if (!listMessage.any(
      (msg) =>
          msg.senderName == message.senderName &&
          msg.content == message.content,
    )) {
      listMessage.add(message);
      Future.delayed(Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
      notifyListeners();
    } else {}
  }

  Future<void> getAllConversations() async {
    final response = await client.request(
      requestType: RequestType.GET,
      path: AppApi.GetAllConversations(user1Id!),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      listConversation =
          data.map<Conversation>((e) => Conversation.fromJson(e)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to get conversations');
    }
  }

  Future<void> createConversation(int user1Id, int user2Id) async {
    this.user1Id = user1Id;
    this.user2Id = user2Id;
    try {
      final response = await client.request(
        requestType: RequestType.POST,
        path: AppApi.CreateConversation(user1Id, user2Id),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        chatService = ChatService(data['conversation_id'].toString());
        await getAllMessagesForConversation(data['conversation_id']);
        startListeningToMessages();
        notifyListeners();
      } else {
        throw Exception('Failed to create conversation');
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> getAllMessagesForConversation(int conversationId) async {
    listMessage.clear();
    try {
      final response = await client.request(
        requestType: RequestType.GET,
        path: AppApi.GetAllMessagesForConversation(conversationId),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        listMessage = data.map<Message>((e) => Message.fromJson(e)).toList();
        Future.delayed(Duration(milliseconds: 100), () {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
        notifyListeners();
      } else {
        throw Exception('Failed to get messages');
      }
    } catch (e) {
      log(e.toString());
    }
  }

  void initChatForConversation(int conversationId) {
    chatService = ChatService(conversationId.toString());
    startListeningToMessages();
  }
}
