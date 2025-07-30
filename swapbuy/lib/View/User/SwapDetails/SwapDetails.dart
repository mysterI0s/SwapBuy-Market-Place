import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Model/Address.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:gap/gap.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';
import 'package:swapbuy/View/Chat/Controller/ChatPageUserController.dart';
import 'package:swapbuy/View/User/SwapDetails/Controller/SwapDetailsController.dart';
import 'package:swapbuy/Widgets/Button/ButtonCustom.dart';
import 'package:swapbuy/Widgets/Dropdown/DropdownCustom.dart';
import 'package:swapbuy/Widgets/RatingStars.dart';
import 'package:swapbuy/Widgets/StatusIndicator/StatusIndicator.dart';
import 'package:swapbuy/Constant/status_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swapbuy/View/Chat/ChatDetailScreen.dart';
import 'package:swapbuy/Model/Conversation.dart';
import 'package:url_launcher/url_launcher.dart';

class SwapDetails extends StatelessWidget {
  const SwapDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => ChatPageUser1Controller(
            context.read<ServicesProvider>().userIdForChat,
          ),
      child: Consumer<SwapDetailsController>(
        builder:
            (context, controller, child) => SafeArea(
              child: Scaffold(
                appBar: AppBar(centerTitle: true, title: Text("Details")),
                body:
                    controller.incomingRequestsController == null
                        ? AcceptanceCaseWidget(controller)
                        : IncomingRequestsWidget(controller),
                // bottomNavigationBar: ChatButtonsBar(controller: controller),
              ),
            ),
      ),
    );
  }
}

// Add a new widget for the chat buttons bar
class ChatButtonsBar extends StatelessWidget {
  final dynamic
  controller; // Accepts BuyDetailsController or SwapDetailsController
  const ChatButtonsBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<ServicesProvider>().userIdForChat;
    int? buyerUserIdForChat;
    int? sellerUserIdForChat;
    String buyerPhone = '';

    // Type check for BuyDetailsController
    if (controller.runtimeType.toString().contains('BuyDetailsController')) {
      final buyOrder = controller.buyOrder;
      buyerUserIdForChat = _parseUserId(buyOrder?.buyer?.userIdForChat);
      sellerUserIdForChat = _parseUserId(buyOrder?.seller?.userIdForChat);
    } else if (controller.runtimeType.toString().contains(
      'SwapDetailsController',
    )) {
      final swapOrder = controller.swapOrder;
      buyerUserIdForChat = _parseUserId(swapOrder?.buyer?.userIdForChat);
      sellerUserIdForChat = _parseUserId(swapOrder?.seller?.userIdForChat);
      buyerPhone = '${swapOrder?.buyer?.phone ?? ''}';
    }

    // Always use a non-null string for phone in WhatsApp URL
    final safeBuyerPhone = (buyerPhone).replaceAll('+', '');

    int? otherUserId;
    if (buyerUserIdForChat != null && sellerUserIdForChat != null) {
      otherUserId =
          (currentUserId == buyerUserIdForChat)
              ? sellerUserIdForChat
              : buyerUserIdForChat;
    }
    if (otherUserId == null) return SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(Icons.chat_bubble_outline, color: AppColors.green),
            tooltip: 'Chat on WhatsApp',
            onPressed: () async {
              final url = Uri.parse('https://wa.me/$safeBuyerPhone');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not open WhatsApp.')),
                );
              }
            },
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/SVG/Chat.svg',
              height: 28,
              width: 28,
            ),
            tooltip: 'Chat in app',
            onPressed: () async {
              final chatController = Provider.of<ChatPageUser1Controller>(
                context,
                listen: false,
              );
              chatController.resetChatState();
              await chatController.getAllConversations();
              Conversation? existing;
              for (final c in chatController.listConversation) {
                if ((c.user1 != null && c.user1 == otherUserId) ||
                    (c.user2 != null && c.user2 == otherUserId)) {
                  existing = c;
                  break;
                }
              }
              if (existing != null) {
                await chatController.getAllMessagesForConversation(
                  existing.id!,
                );
                chatController.user2Id =
                    (existing.user1 == chatController.user1Id)
                        ? existing.user2
                        : existing.user1;
                chatController.initChatForConversation(existing.id!);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ChatDetailScreen(
                          conversation: existing!,
                          chatController: chatController,
                        ),
                  ),
                );
              } else {
                await chatController.createConversation(
                  currentUserId,
                  otherUserId!,
                );
                if (chatController.listConversation.isNotEmpty) {
                  final newConvo = chatController.listConversation.last;
                  await chatController.getAllMessagesForConversation(
                    newConvo.id!,
                  );
                  chatController.user2Id =
                      (newConvo.user1 == chatController.user1Id)
                          ? newConvo.user2
                          : newConvo.user1;
                  chatController.initChatForConversation(newConvo.id!);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ChatDetailScreen(
                            conversation: newConvo,
                            chatController: chatController,
                          ),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  int? _parseUserId(dynamic id) {
    if (id == null) return null;
    if (id is int) return id;
    if (id is String && id.isNotEmpty) return int.tryParse(id);
    return null;
  }
}

class AcceptanceCaseWidget extends StatelessWidget {
  SwapDetailsController controller;
  AcceptanceCaseWidget(this.controller);

  @override
  Widget build(BuildContext context) {
    final buyerPhone = controller.getBuyerPhoneInternational();
    return Form(
      key: controller.keyform,
      child: ListView(
        padding: EdgeInsets.all(16),
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0x1A000000),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        height: 150,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child:
                              controller.productrequest?.product?.image !=
                                          null &&
                                      controller
                                          .productrequest!
                                          .product!
                                          .image!
                                          .isNotEmpty
                                  ? FadeInImage.assetNetwork(
                                    placeholder: "assets/PNG/Logo.png",
                                    image:
                                        "${controller.productrequest?.product!.image}",
                                    fit: BoxFit.cover,
                                    imageErrorBuilder: (
                                      context,
                                      error,
                                      stackTrace,
                                    ) {
                                      return Image.asset("assets/PNG/Logo.png");
                                    },
                                    placeholderErrorBuilder: (
                                      context,
                                      error,
                                      stackTrace,
                                    ) {
                                      return Image.asset("assets/PNG/Logo.png");
                                    },
                                  )
                                  : Image.asset("assets/PNG/Logo.png"),
                        ),
                      ),
                      Gap(10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Product: ${controller.productrequest?.product?.name! ?? ""}",
                            style: TextStyles.pramed.copyWith(
                              color: AppColors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Owner: ${controller.rawSwapDetails?['product_requested']['buyer']['user']['name']! ?? ""}",
                            style: TextStyles.smallpra.copyWith(
                              color: AppColors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Gap(10),
              Icon(Icons.swap_horiz_outlined, size: 32, color: AppColors.black),
              Gap(10),

              Expanded(
                child: SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0x1A000000),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        height: 150,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child:
                              controller.productoffered?.product?.image !=
                                          null &&
                                      controller
                                          .productoffered!
                                          .product!
                                          .image!
                                          .isNotEmpty
                                  ? FadeInImage.assetNetwork(
                                    placeholder: "assets/PNG/Logo.png",
                                    image:
                                        "${controller.productoffered?.product!.image}",
                                    fit: BoxFit.cover,
                                    imageErrorBuilder: (
                                      context,
                                      error,
                                      stackTrace,
                                    ) {
                                      return Image.asset("assets/PNG/Logo.png");
                                    },
                                    placeholderErrorBuilder: (
                                      context,
                                      error,
                                      stackTrace,
                                    ) {
                                      return Image.asset("assets/PNG/Logo.png");
                                    },
                                  )
                                  : Image.asset("assets/PNG/Logo.png"),
                        ),
                      ),
                      Gap(10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Product: ${controller.productoffered?.product!.name! ?? ""}",
                            style: TextStyles.pramed.copyWith(
                              color: AppColors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Owner: You",

                            style: TextStyles.smallpra.copyWith(
                              color: AppColors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Gap(10),
          Gap(28),
          Text(
            "Delivery Location",
            style: TextStyles.header.copyWith(color: AppColors.black),
          ),
          Gap(10),
          Container(
            decoration: BoxDecoration(
              color: Color(0x0D000000),
              borderRadius: BorderRadius.circular(15),

              border: Border.all(color: Color(0x1A000000), width: .5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select Address",
                    style: TextStyles.pramed.copyWith(color: Color(0x80000000)),
                  ),
                  Gap(10),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: AppColors.black,
                        size: 35,
                      ),
                      Gap(10),
                      Expanded(
                        child: DropdownCustom<Address>(
                          hint: "Address",
                          isrequierd: true,

                          fillcolor: Color(0xff000000),
                          bordercolor: Color(0x1A000000),
                          value: controller.address,
                          items:
                              controller.adresses
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        "${e.buildingNumber!}${e.buildingNumber != "" ? ',' : ""}${e.street!}${e.street != "" ? ',' : ""}${e.neighborhood!}${e.neighborhood != "" ? ',' : ""}${e.city}${e.city != "" ? ',' : ""}${e.postalCode}${e.postalCode != "" ? ',' : ""}${e.country}",

                                        style: TextStyles.paraghraph.copyWith(
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (p0) {
                            controller.Selectaddress(p0!);
                          },
                        ),
                      ),
                    ],
                  ),
                  Gap(15),
                  Text(
                    "Delivery Method",
                    style: TextStyles.pramed.copyWith(color: Color(0x80000000)),
                  ),
                  Gap(10),
                  Row(
                    children: [
                      Icon(
                        Icons.delivery_dining_outlined,
                        color: AppColors.black,
                        size: 35,
                      ),
                      Gap(10),
                      Expanded(
                        child: DropdownCustom<String>(
                          isrequierd: true,
                          hint: "Method",

                          fillcolor: Color(0xff000000),
                          bordercolor: Color(0x1A000000),
                          value: controller.deliverymethod,
                          items:
                              controller.deliverymethods
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: TextStyles.paraghraph.copyWith(
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (p0) {
                            controller.Selectdeliverymethod(p0!);
                          },
                        ),
                      ),
                    ],
                  ),
                  Gap(15),
                  Text(
                    "Payment Method",
                    style: TextStyles.pramed.copyWith(color: Color(0x80000000)),
                  ),
                  Gap(10),
                  Row(
                    children: [
                      Icon(Icons.payment, color: AppColors.black, size: 35),
                      Gap(10),
                      Expanded(
                        child: DropdownCustom<String>(
                          isrequierd: true,
                          hint: "Method",

                          fillcolor: Color(0xff000000),
                          bordercolor: Color(0x1A000000),
                          value: controller.paymentmethod,
                          items:
                              controller.paymentmethods
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: TextStyles.paraghraph.copyWith(
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (p0) {
                            controller.Selectpaymentmethod(p0!);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Gap(20),
          Container(
            decoration: BoxDecoration(
              color: Color(0x0D000000),
              borderRadius: BorderRadius.circular(15),

              border: Border.all(color: Color(0x1A000000), width: .5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    "Payment Status",
                    style: TextStyles.pramed.copyWith(color: Color(0x80000000)),
                  ),
                  Text(
                    controller.swapmodel?.swapRequest?.paymentStatus ??
                        "Unkown",
                    style: TextStyles.smallpra.copyWith(
                      color: Color(0xff000000),
                    ),
                  ),
                  Gap(10),
                  Text(
                    "Request Status",
                    style: TextStyles.pramed.copyWith(color: Color(0x80000000)),
                  ),
                  StatusIndicator(
                    status:
                        controller.swapmodel?.swapRequest?.status ?? "Unknown",
                  ),
                  Gap(10),
                  Text(
                    "Order Status",
                    style: TextStyles.pramed.copyWith(color: Color(0x80000000)),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: AppColors.black,
                        size: 35,
                      ),
                      Gap(10),

                      Text(
                        controller.swapOrder?.orderStatus ?? "Unkown",
                        style: TextStyles.smallpra.copyWith(
                          color: Color(0xff000000),
                        ),
                      ),
                    ],
                  ),
                  if (buyerPhone != null) ...[
                    Gap(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.chat_bubble_outline,
                            color: AppColors.green,
                          ),
                          tooltip: 'Chat on WhatsApp',
                          onPressed: () async {
                            final url = Uri.parse(
                              'https://wa.me/${buyerPhone.replaceAll('+', '')}',
                            );
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Could not open WhatsApp.'),
                                ),
                              );
                            }
                          },
                        ),
                        Builder(
                          builder: (context) {
                            return IconButton(
                              icon: SvgPicture.asset(
                                'assets/SVG/Chat.svg',
                                height: 28,
                                width: 28,
                              ),
                              tooltip: 'Chat in app',
                              onPressed: () async {
                                // Get current user ID from provider
                                final currentUserId =
                                    Provider.of<ServicesProvider>(
                                      context,
                                      listen: false,
                                    ).userIdForChat;

                                // Get seller's userIdForChat from product.buyer.user.userIdForChat
                                final sellerId =
                                    controller
                                        .swapmodel
                                        ?.productOffered
                                        ?.seller
                                        ?.user
                                        ?.userIdForChat;

                                if (sellerId == null || currentUserId == 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Could not determine valid user IDs for chat.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                final chatController = ChatPageUser1Controller(
                                  currentUserId,
                                );
                                chatController.resetChatState();
                                await chatController.getAllConversations();
                                Conversation? existing;
                                for (final c
                                    in chatController.listConversation) {
                                  if ((c.user1 == sellerId &&
                                          c.user2 == currentUserId) ||
                                      (c.user2 == sellerId &&
                                          c.user1 == currentUserId)) {
                                    existing = c;
                                    break;
                                  }
                                }
                                if (existing != null) {
                                  await chatController
                                      .getAllMessagesForConversation(
                                        existing.id!,
                                      );
                                  chatController.user1Id = currentUserId;
                                  chatController.user2Id = sellerId;
                                  chatController.initChatForConversation(
                                    existing.id!,
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => ChangeNotifierProvider.value(
                                            value: chatController,
                                            child: ChatDetailScreen(
                                              conversation: existing!,
                                              chatController: chatController,
                                            ),
                                          ),
                                    ),
                                  );
                                } else {
                                  await chatController.createConversation(
                                    currentUserId,
                                    sellerId,
                                  );
                                  if (chatController
                                      .listConversation
                                      .isNotEmpty) {
                                    final newConvo =
                                        chatController.listConversation.last;
                                    await chatController
                                        .getAllMessagesForConversation(
                                          newConvo.id!,
                                        );
                                    chatController.user1Id = currentUserId;
                                    chatController.user2Id = sellerId;
                                    chatController.initChatForConversation(
                                      newConvo.id!,
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => ChangeNotifierProvider.value(
                                              value: chatController,
                                              child: ChatDetailScreen(
                                                conversation: newConvo,
                                                chatController: chatController,
                                              ),
                                            ),
                                      ),
                                    );
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    Gap(12),
                  ],
                ],
              ),
            ),
          ),

          Gap(30),
          // Update Swap Button - Only enabled for pending requests
          ButtonCustom(
            fullWidth: false,
            fullheight: false,
            color:
                StatusHelper.isActionable(
                      controller.swapmodel?.swapRequest?.status ?? "",
                    )
                    ? AppColors.thirdy
                    : AppColors.grey,
            onTap: () async {
              if (!StatusHelper.isActionable(
                controller.swapmodel?.swapRequest?.status ?? "",
              )) {
                return; // Early return if not actionable
              }
              if (controller.keyform.currentState!.validate()) {
                EasyLoading.show();
                try {
                  final res = await controller.UpdateSwap(context);
                  res.fold(
                    (l) {
                      EasyLoading.showError(l.message);
                      EasyLoading.dismiss();
                    },
                    (r) {
                      EasyLoading.dismiss();
                    },
                  );
                } catch (e) {
                  EasyLoading.dismiss();
                }
              }
            },
            child: Text(
              "Update Swap",
              style: TextStyles.button.copyWith(
                color:
                    StatusHelper.isActionable(
                          controller.swapmodel?.swapRequest?.status ?? "",
                        )
                        ? AppColors.white
                        : AppColors.white.withOpacity(0.6),
              ),
            ),
          ),
          Gap(20),
          // Cancel Swap Button - Only enabled for pending requests
          ButtonCustom(
            fullWidth: false,
            fullheight: false,
            color:
                StatusHelper.isActionable(
                      controller.swapmodel?.swapRequest?.status ?? "",
                    )
                    ? AppColors.red
                    : AppColors.grey,
            onTap: () async {
              if (!StatusHelper.isActionable(
                controller.swapmodel?.swapRequest?.status ?? "",
              )) {
                return; // Early return if not actionable
              }
              if (controller.keyform.currentState!.validate()) {
                EasyLoading.show();
                try {
                  final res = await controller.CanceleSwap(context);
                  res.fold(
                    (l) {
                      EasyLoading.showError(l.message);
                      EasyLoading.dismiss();
                    },
                    (r) {
                      EasyLoading.dismiss();
                    },
                  );
                } catch (e) {
                  EasyLoading.dismiss();
                }
              }
            },
            child: Text(
              "Cancel Swap",
              style: TextStyles.button.copyWith(
                color:
                    StatusHelper.isActionable(
                          controller.swapmodel?.swapRequest?.status ?? "",
                        )
                        ? AppColors.white
                        : AppColors.white.withOpacity(0.6),
              ),
            ),
          ),

          // Show message when buttons are disabled
          if (!StatusHelper.isActionable(
            controller.swapmodel?.swapRequest?.status ?? "",
          )) ...[
            Gap(15),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.grey.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.grey, size: 20),
                  Gap(8),
                  Expanded(
                    child: Text(
                      "This request has been ${controller.swapmodel?.swapRequest?.status?.toLowerCase()}. Updates and cancellations are no longer allowed.",
                      style: TextStyles.smallpra.copyWith(
                        color: AppColors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Gap(32),

          // ===== RATING SYSTEM UI ===== (FIXED CONDITION)
          if (controller.canRateOrder) ...[
            Gap(30),
            Text(
              "Rate Your Experience",
              style: TextStyles.header.copyWith(color: AppColors.black),
            ),
            Gap(20),
            // Rate the other user (buyer or seller)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0x0D000000),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Color(0x1A000000), width: .5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.currentUserRole == 'seller'
                        ? "Rate the Buyer"
                        : "Rate the Seller",
                    style: TextStyles.pramed.copyWith(color: AppColors.black),
                  ),
                  Gap(10),
                  if (!controller.sellerAlreadyRated) ...[
                    RatingStars(
                      rating: controller.sellerRating,
                      editable: true,
                      showLabel: true,
                      showCommentField: true,
                      comment: controller.sellerComment,
                      onRatingChanged: controller.setSellerRating,
                      onCommentChanged: controller.setSellerComment,
                    ),
                    Gap(15),
                    ButtonCustom(
                      fullWidth: true,
                      fullheight: false,
                      color: AppColors.primary,
                      onTap: () => controller.submitSellerRating(context),
                      child: Text(
                        "Submit Rating",
                        style: TextStyles.button.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ] else ...[
                    RatingStars(
                      rating: controller.currentUserOtherRating,
                      editable: false,
                      showLabel: true,
                      showCommentField: true,
                      comment: controller.currentUserOtherComment,
                    ),
                    Gap(10),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.green),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.green),
                          Gap(10),
                          Text(
                            "Rating submitted Successfully",
                            style: TextStyles.paraghraph.copyWith(
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Gap(20),
            // --- DELIVERY RATING SECTION ---
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0x0D000000),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Color(0x1A000000), width: .5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rate the Delivery Service",
                    style: TextStyles.pramed.copyWith(color: AppColors.black),
                  ),
                  Gap(10),
                  if (!controller.deliveryAlreadyRated) ...[
                    RatingStars(
                      rating: controller.deliveryRating,
                      editable: true,
                      showLabel: true,
                      showCommentField: true,
                      comment: controller.deliveryComment,
                      onRatingChanged: controller.setDeliveryRating,
                      onCommentChanged: controller.setDeliveryComment,
                    ),
                    Gap(15),
                    ButtonCustom(
                      fullWidth: true,
                      fullheight: false,
                      color: AppColors.primary,
                      onTap: () => controller.submitDeliveryRating(context),
                      child: Text(
                        "Submit Delivery Rating",
                        style: TextStyles.button.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ] else ...[
                    RatingStars(
                      rating: controller.currentUserDeliveryRating,
                      editable: false,
                      showLabel: true,
                      showCommentField: true,
                      comment: controller.currentUserDeliveryComment,
                    ),
                    Gap(10),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.green),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.green),
                          Gap(10),
                          Text(
                            "Delivery rating submitted Successfully",
                            style: TextStyles.paraghraph.copyWith(
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class IncomingRequestsWidget extends StatelessWidget {
  SwapDetailsController controller;
  IncomingRequestsWidget(this.controller);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.keyform,
      child: ListView(
        padding: EdgeInsets.all(16),
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0x1A000000),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        height: 150,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: FadeInImage.assetNetwork(
                            placeholder: "assets/PNG/Logo.png",
                            image:
                                "${controller.productoffered?.product!.image}",
                            fit: BoxFit.cover,
                            imageErrorBuilder:
                                (context, error, stackTrace) =>
                                    Image.asset("assets/PNG/Logo.png"),
                            placeholderErrorBuilder:
                                (context, error, stackTrace) =>
                                    Image.asset("assets/PNG/Logo.png"),
                          ),
                        ),
                      ),
                      Gap(10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Product: ${controller.productoffered?.product!.name! ?? ""}",
                            style: TextStyles.pramed.copyWith(
                              color: AppColors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Owner: ${controller.swapmodel?.requester?.user?.name! ?? ""}",

                            style: TextStyles.smallpra.copyWith(
                              color: AppColors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Gap(10),
              Icon(Icons.swap_horiz_outlined, size: 32, color: AppColors.black),
              Gap(10),
              Expanded(
                child: SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0x1A000000),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        height: 150,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: FadeInImage.assetNetwork(
                            placeholder: "assets/PNG/Logo.png",
                            image:
                                "${controller.productrequest?.product!.image}",
                            fit: BoxFit.cover,
                            imageErrorBuilder:
                                (context, error, stackTrace) =>
                                    Image.asset("assets/PNG/Logo.png"),
                            placeholderErrorBuilder:
                                (context, error, stackTrace) =>
                                    Image.asset("assets/PNG/Logo.png"),
                          ),
                        ),
                      ),
                      Gap(10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Product: ${controller.productrequest?.product?.name! ?? ""}",
                            style: TextStyles.pramed.copyWith(
                              color: AppColors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Owner: You",
                            style: TextStyles.smallpra.copyWith(
                              color: AppColors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Gap(10),
          Gap(28),
          Text(
            "Delivery Location",
            style: TextStyles.header.copyWith(color: AppColors.black),
          ),
          Gap(10),
          Container(
            decoration: BoxDecoration(
              color: Color(0x0D000000),
              borderRadius: BorderRadius.circular(15),

              border: Border.all(color: Color(0x1A000000), width: .5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Address",
                    style: TextStyles.pramed.copyWith(color: Color(0x80000000)),
                  ),
                  Gap(10),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: AppColors.black,
                        size: 35,
                      ),
                      Gap(10),
                      Expanded(
                        child: Text(
                          "${controller.swapmodel!.selectedAddress!.buildingNumber!}${controller.swapmodel!.selectedAddress!.buildingNumber != "" ? ',' : ""}${controller.swapmodel!.selectedAddress!.street!}${controller.swapmodel!.selectedAddress!.street != "" ? ',' : ""}${controller.swapmodel!.selectedAddress!.neighborhood!}${controller.swapmodel!.selectedAddress!.neighborhood != "" ? ',' : ""}${controller.swapmodel!.selectedAddress!.city}${controller.swapmodel!.selectedAddress!.city != "" ? ',' : ""}${controller.swapmodel!.selectedAddress!.postalCode}${controller.swapmodel!.selectedAddress!.postalCode != "" ? ',' : ""}${controller.swapmodel!.selectedAddress!.country}",

                          style: TextStyles.paraghraph.copyWith(
                            color: Color(0xff000000),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(15),
                  Text(
                    "Delivery Method",
                    style: TextStyles.pramed.copyWith(color: Color(0x80000000)),
                  ),
                  Gap(10),
                  Row(
                    children: [
                      Icon(
                        Icons.delivery_dining_outlined,
                        color: AppColors.black,
                        size: 35,
                      ),
                      Gap(10),
                      Expanded(
                        child: Text(
                          controller.swapmodel!.swapRequest!.deliveryType!,
                          style: TextStyles.paraghraph.copyWith(
                            color: Color(0xff000000),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(15),
                  Text(
                    "Payment Method",
                    style: TextStyles.pramed.copyWith(color: Color(0x80000000)),
                  ),
                  Gap(10),
                  Row(
                    children: [
                      Icon(Icons.payment, color: AppColors.black, size: 35),
                      Gap(10),
                      Expanded(
                        child: Text(
                          controller.swapmodel!.swapRequest!.paymentMethod!,
                          style: TextStyles.paraghraph.copyWith(
                            color: Color(0xff000000),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(15),

                  Text(
                    "Payment Status",
                    style: TextStyles.pramed.copyWith(color: Color(0x80000000)),
                  ),
                  Gap(10),

                  Row(
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        color: AppColors.black,
                        size: 35,
                      ),
                      Gap(10),

                      Text(
                        controller.swapmodel?.swapRequest?.paymentStatus ??
                            "Unkown",
                        style: TextStyles.smallpra.copyWith(
                          color: Color(0xff000000),
                        ),
                      ),
                    ],
                  ),
                  Gap(15),

                  Text(
                    "Request Status",
                    style: TextStyles.pramed.copyWith(color: Color(0x80000000)),
                  ),
                  Gap(10),

                  Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: AppColors.black,
                        size: 35,
                      ),
                      Gap(10),

                      Text(
                        controller.swapmodel?.swapRequest?.status ?? "Unkown",
                        style: TextStyles.smallpra.copyWith(
                          color: Color(0xff000000),
                        ),
                      ),
                    ],
                  ),
                  Gap(10),
                  Text(
                    "Order Status",
                    style: TextStyles.pramed.copyWith(color: Color(0x80000000)),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: AppColors.black,
                        size: 35,
                      ),
                      Gap(10),
                      Text(
                        controller.swapOrder?.orderStatus ?? "Unkown",
                        style: TextStyles.smallpra.copyWith(
                          color: Color(0xff000000),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Show Accept/Reject buttons only for pending requests
          if (controller.swapmodel?.swapRequest?.status == "Pending") ...[
            Gap(30),
            Row(
              children: [
                Expanded(
                  child: ButtonCustom(
                    fullWidth: false,
                    fullheight: false,
                    color: AppColors.green,
                    onTap: () async {
                      EasyLoading.show();
                      try {
                        final res = await controller.ProcessSwapRequest(
                          context,
                          "accept",
                        );
                        res.fold(
                          (l) {
                            EasyLoading.showError(l.message);
                            EasyLoading.dismiss();
                          },
                          (r) {
                            EasyLoading.dismiss();
                            Navigator.pop(context);
                          },
                        );
                      } catch (e) {
                        EasyLoading.dismiss();
                      }
                    },
                    child: Text("Accept", style: TextStyles.button),
                  ),
                ),
                Gap(15),
                Expanded(
                  child: ButtonCustom(
                    fullWidth: false,
                    fullheight: false,
                    color: AppColors.red,
                    onTap: () async {
                      EasyLoading.show();
                      try {
                        final res = await controller.ProcessSwapRequest(
                          context,
                          "reject",
                        );
                        res.fold(
                          (l) {
                            EasyLoading.showError(l.message);
                            EasyLoading.dismiss();
                          },
                          (r) {
                            EasyLoading.dismiss();
                            Navigator.pop(context);
                          },
                        );
                      } catch (e) {
                        EasyLoading.dismiss();
                      }
                    },
                    child: Text("Reject", style: TextStyles.button),
                  ),
                ),
              ],
            ),
          ],

          // ===== RATING SYSTEM UI FOR INCOMING REQUESTS =====
          if (controller.canRateOrder) ...[
            Gap(30),
            Text(
              "Rate Your Experience",
              style: TextStyles.header.copyWith(color: AppColors.black),
            ),
            Gap(20),
            // Rate the other user (buyer or seller)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0x0D000000),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Color(0x1A000000), width: .5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.currentUserRole == 'seller'
                        ? "Rate the Buyer"
                        : "Rate the Seller",
                    style: TextStyles.pramed.copyWith(color: AppColors.black),
                  ),
                  Gap(10),
                  if (!controller.sellerAlreadyRated) ...[
                    RatingStars(
                      rating: controller.sellerRating,
                      editable: true,
                      showLabel: true,
                      showCommentField: true,
                      comment: controller.sellerComment,
                      onRatingChanged: controller.setSellerRating,
                      onCommentChanged: controller.setSellerComment,
                    ),
                    Gap(15),
                    ButtonCustom(
                      fullWidth: true,
                      fullheight: false,
                      color: AppColors.primary,
                      onTap: () => controller.submitSellerRating(context),
                      child: Text(
                        "Submit Rating",
                        style: TextStyles.button.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ] else ...[
                    RatingStars(
                      rating: controller.currentUserOtherRating,
                      editable: false,
                      showLabel: true,
                      showCommentField: true,
                      comment: controller.currentUserOtherComment,
                    ),
                    Gap(10),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.green),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.green),
                          Gap(10),
                          Text(
                            "Rating submitted Successfully",
                            style: TextStyles.paraghraph.copyWith(
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Gap(20),
            // --- DELIVERY RATING SECTION ---
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0x0D000000),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Color(0x1A000000), width: .5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rate the Delivery Service",
                    style: TextStyles.pramed.copyWith(color: AppColors.black),
                  ),
                  Gap(10),
                  if (!controller.deliveryAlreadyRated) ...[
                    RatingStars(
                      rating: controller.deliveryRating,
                      editable: true,
                      showLabel: true,
                      showCommentField: true,
                      comment: controller.deliveryComment,
                      onRatingChanged: controller.setDeliveryRating,
                      onCommentChanged: controller.setDeliveryComment,
                    ),
                    Gap(15),
                    ButtonCustom(
                      fullWidth: true,
                      fullheight: false,
                      color: AppColors.primary,
                      onTap: () => controller.submitDeliveryRating(context),
                      child: Text(
                        "Submit Delivery Rating",
                        style: TextStyles.button.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ] else ...[
                    RatingStars(
                      rating: controller.currentUserDeliveryRating,
                      editable: false,
                      showLabel: true,
                      showCommentField: true,
                      comment: controller.currentUserDeliveryComment,
                    ),
                    Gap(10),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.green),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.green),
                          Gap(10),
                          Text(
                            "Delivery rating submitted Successfully",
                            style: TextStyles.paraghraph.copyWith(
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
