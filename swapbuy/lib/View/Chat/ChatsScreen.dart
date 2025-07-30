import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/View/Chat/Controller/ChatPageUserController.dart';
import 'package:swapbuy/View/Chat/ChatDetailScreen.dart';
import 'package:swapbuy/Model/Conversation.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userIdForChat = context.read<ServicesProvider>().userIdForChat;
    return ChangeNotifierProvider(
      create:
          (_) => ChatPageUser1Controller(userIdForChat)..getAllConversations(),
      builder: (context, child) {
        final controller = Provider.of<ChatPageUser1Controller>(context);
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Chats',
              style: TextStyles.header.copyWith(color: AppColors.black),
            ),
            backgroundColor: AppColors.basic,
            elevation: 1,
            iconTheme: IconThemeData(color: AppColors.black),
          ),
          body:
              controller.listConversation.isEmpty
                  ? Center(
                    child: Text(
                      'No conversations yet.',
                      style: TextStyles.paraghraph,
                    ),
                  )
                  : ListView.separated(
                    itemCount: controller.listConversation.length,
                    separatorBuilder: (_, __) => Divider(),
                    itemBuilder: (context, index) {
                      final Conversation convo =
                          controller.listConversation[index];
                      final int currentUserId = userIdForChat;
                      // Show the other participant's name
                      final String receiverName =
                          (convo.user1 == currentUserId)
                              ? (convo.user2Name ?? 'User')
                              : (convo.user1Name ?? 'User');
                      return ListTile(
                        leading: SvgPicture.asset(
                          'assets/SVG/Chat.svg',
                          height: 32,
                          width: 32,
                        ),
                        title: Text(
                          receiverName,
                          style: TextStyles.paraghraph.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                        onTap: () async {
                          final chatController = ChatPageUser1Controller(
                            context.read<ServicesProvider>().userIdForChat,
                          );
                          chatController.user2Id =
                              (convo.user1 == chatController.user1Id)
                                  ? convo.user2
                                  : convo.user1;
                          await chatController.getAllMessagesForConversation(
                            convo.id!,
                          );
                          chatController.initChatForConversation(convo.id!);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ChatDetailScreen(
                                    conversation: convo,
                                    chatController: chatController,
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  ),
        );
      },
    );
  }
}
