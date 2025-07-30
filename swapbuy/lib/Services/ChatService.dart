import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatService {
  final WebSocketChannel channel;

  ChatService(String conversationId)
    : channel = WebSocketChannel.connect(
        Uri.parse('ws://10.0.2.2:8000/ws/chat/$conversationId/'),
      );

  void sendMessage(String message, int user1Id, int user2Id) {
    final data = jsonEncode({
      'message': message,
      'user1_id': user1Id,
      'user2_id': user2Id,
    });
    channel.sink.add(data);
  }

  Stream get stream => channel.stream;

  void close() {
    channel.sink.close();
  }
}
