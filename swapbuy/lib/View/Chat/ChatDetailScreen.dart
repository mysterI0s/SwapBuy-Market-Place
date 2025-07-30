import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/View/Chat/Controller/ChatPageUserController.dart';
import 'package:swapbuy/Model/Conversation.dart';
import 'package:swapbuy/Model/Message.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Constant/colors.dart';

class ChatDetailScreen extends StatelessWidget {
  final Conversation conversation;
  final ChatPageUser1Controller chatController;
  const ChatDetailScreen({
    super.key,
    required this.conversation,
    required this.chatController,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: chatController,
      child: Consumer<ChatPageUser1Controller>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: AppBar(
              title: Builder(
                builder: (context) {
                  final currentUserId = chatController.user1Id;
                  final String receiverName =
                      (conversation.user1 == currentUserId)
                          ? (conversation.user2Name ?? 'Chat')
                          : (conversation.user1Name ?? 'Chat');
                  return Text(
                    receiverName,
                    style: TextStyles.header.copyWith(color: AppColors.black),
                  );
                },
              ),
              backgroundColor: AppColors.basic,
              elevation: 1,
              iconTheme: IconThemeData(color: AppColors.black),
            ),
            body: Column(
              children: [
                Expanded(
                  child:
                      controller.listMessage.isEmpty
                          ? Center(
                            child: Text(
                              'No messages yet.',
                              style: TextStyles.paraghraph,
                            ),
                          )
                          : ListView.builder(
                            controller: controller.scrollController,
                            itemCount: controller.listMessage.length,
                            itemBuilder: (context, index) {
                              final Message msg = controller.listMessage[index];
                              return Align(
                                alignment:
                                    msg.sender == controller.user1Id
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        msg.sender == controller.user1Id
                                            ? AppColors.primary.withOpacity(0.2)
                                            : AppColors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    msg.content ?? '',
                                    style: TextStyles.paraghraph.copyWith(
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                ),
                Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.controller,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: AppColors.primary),
                        onPressed: controller.sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
