import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Model/Address.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:gap/gap.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Model/Conversation.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';
import 'package:swapbuy/View/Chat/Controller/ChatPageUserController.dart';
import 'package:swapbuy/View/User/BuyDetails/Controller/BuyDetailsController.dart';
import 'package:swapbuy/Widgets/Button/ButtonCustom.dart';
import 'package:swapbuy/Widgets/Dropdown/DropdownCustom.dart';
import 'package:swapbuy/Widgets/RatingStars.dart';
import 'package:swapbuy/Widgets/StatusIndicator/StatusIndicator.dart';
import 'package:swapbuy/Constant/status_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swapbuy/View/Chat/ChatDetailScreen.dart';

class BuyDetails extends StatefulWidget {
  const BuyDetails({super.key});

  @override
  State<BuyDetails> createState() => _BuyDetailsState();
}

class _BuyDetailsState extends State<BuyDetails> {
  bool _didFetch = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didFetch) {
      final controller = context.read<BuyDetailsController>();
      // Always fetch latest order details when screen is opened
      controller.fetchOrderDetails(context);
      _didFetch = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => ChatPageUser1Controller(
            context.read<ServicesProvider>().userIdForChat,
          ),
      child: Consumer<BuyDetailsController>(
        builder:
            (context, controller, child) => SafeArea(
              child: Scaffold(
                appBar: AppBar(centerTitle: true, title: Text("Details")),
                body:
                    controller.incomingRequestsController == null
                        ? AcceptanceCaseWidget(controller)
                        : IncomingRequestsWidget(controller),
              ),
            ),
      ),
    );
  }
}

class AcceptanceCaseWidget extends StatelessWidget {
  BuyDetailsController controller;
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
              SizedBox(
                width: 180,
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
                            controller.productrequest?.product?.image != null &&
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
                          "Owner: ${controller.buyOrder?.seller?.name! ?? {controller.buymodel?.productRequested?.buyer?.user?.name}} ",
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
            ],
          ),
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
                    controller.buymodel?.buyRequest?.paymentStatus ?? "Unknown",
                    style: TextStyles.smallpra.copyWith(
                      color: Color(0xff000000),
                    ),
                  ),
                  Gap(10),
                  Text(
                    "Request Status",
                    style: TextStyles.pramed.copyWith(color: Color(0x80000000)),
                  ),
                  Text(
                    controller.buymodel?.buyRequest?.status ?? "Unknown",
                    style: TextStyles.smallpra.copyWith(
                      color: Color(0xff000000),
                    ),
                  ),
                  Gap(15),
                  Text(
                    "Order Status",
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
                      StatusIndicator(
                        status: controller.buyOrder?.orderStatus ?? "Unknown",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Gap(30),
          // Update Buy Button - Only enabled for pending requests
          ButtonCustom(
            fullWidth: false,
            fullheight: false,
            color:
                StatusHelper.isActionable(
                      controller.buymodel?.buyRequest?.status ?? "",
                    )
                    ? AppColors.thirdy
                    : AppColors.grey,
            onTap: () async {
              if (!StatusHelper.isActionable(
                controller.buymodel?.buyRequest?.status ?? "",
              )) {
                return;
              }
              if (controller.keyform.currentState!.validate()) {
                EasyLoading.show();
                try {
                  final res = await controller.UpdateBuy(context);
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
              "Update Buy",
              style: TextStyles.button.copyWith(
                color:
                    StatusHelper.isActionable(
                          controller.buymodel?.buyRequest?.status ?? "",
                        )
                        ? AppColors.white
                        : AppColors.white.withOpacity(0.6),
              ),
            ),
          ),
          Gap(20),
          // Cancel Buy Button - Only enabled for pending requests
          ButtonCustom(
            fullWidth: false,
            fullheight: false,
            color:
                StatusHelper.isActionable(
                      controller.buymodel?.buyRequest?.status ?? "",
                    )
                    ? AppColors.red
                    : AppColors.grey,
            onTap: () async {
              if (!StatusHelper.isActionable(
                controller.buymodel?.buyRequest?.status ?? "",
              )) {
                return;
              }
              if (controller.keyform.currentState!.validate()) {
                EasyLoading.show();
                try {
                  final res = await controller.CanceleBuy(context);
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
              "Cancel Buy",
              style: TextStyles.button.copyWith(
                color:
                    StatusHelper.isActionable(
                          controller.buymodel?.buyRequest?.status ?? "",
                        )
                        ? AppColors.white
                        : AppColors.white.withOpacity(0.6),
              ),
            ),
          ),
          // Accept Order Button - Only enabled for pending requests and only for seller
          if (StatusHelper.isActionable(
                controller.buymodel?.buyRequest?.status ?? "",
              ) &&
              controller.buyOrder == null &&
              controller.currentUserRole == 'seller') ...[
            Gap(20),
            ButtonCustom(
              fullWidth: false,
              fullheight: false,
              color: AppColors.green,
              onTap: () async {
                EasyLoading.show(status: 'Accepting...');
                try {
                  await controller.acceptOrder(context);
                  EasyLoading.dismiss();
                } catch (e) {
                  EasyLoading.dismiss();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to accept order: $e')),
                  );
                }
              },
              child: Text(
                "Accept Order",
                style: TextStyles.button.copyWith(color: AppColors.white),
              ),
            ),
            Gap(20),
          ],
          // Show message when buttons are disabled
          if (!StatusHelper.isActionable(
            controller.buymodel?.buyRequest?.status ?? "",
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
                      "This request has been ${controller.buymodel?.buyRequest?.status?.toLowerCase()}. Updates and cancellations are no longer allowed.",
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
          // ===== RATING SYSTEM UI =====
          if (controller.canRateOrder) ...[
            Text(
              'Rate your experience',
              style: TextStyles.header.copyWith(color: AppColors.black),
            ),
            Gap(16),

            // Rate the other user (seller/buyer based on current user role)
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
                    controller.currentUserRole == 'buyer'
                        ? 'Rate the Seller'
                        : 'Rate the Buyer',
                    style: TextStyles.pramed.copyWith(color: AppColors.black),
                  ),
                  Gap(10),

                  if (!controller.sellerAlreadyRated) ...[
                    // User can still rate
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
                      color: AppColors.thirdy,
                      onTap: () => controller.submitSellerRating(context),
                      child: Text(
                        'Submit Rating',
                        style: TextStyles.button.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ] else ...[
                    // User has already rated - show read-only
                    RatingStars(
                      rating: controller.currentUserOtherRating,
                      editable: false,
                      showLabel: true,
                      showCommentField: true,
                      comment: controller.currentUserOtherComment,
                    ),
                    Gap(10),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.green),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.green,
                            size: 20,
                          ),
                          Gap(8),
                          Text(
                            'Rating submitted successfully',
                            style: TextStyles.smallpra.copyWith(
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

            Gap(24),

            // Rate Delivery Driver
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
                    'Rate the Delivery Service',
                    style: TextStyles.pramed.copyWith(color: AppColors.black),
                  ),
                  Gap(10),

                  if (!controller.deliveryAlreadyRated) ...[
                    // User can still rate delivery
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
                      color: AppColors.thirdy,
                      onTap: () => controller.submitDeliveryRating(context),
                      child: Text(
                        'Submit Delivery Rating',
                        style: TextStyles.button.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ] else ...[
                    // User has already rated delivery - show read-only
                    RatingStars(
                      rating: controller.currentUserDeliveryRating,
                      editable: false,
                      showLabel: true,
                      showCommentField: true,
                      comment: controller.currentUserDeliveryComment,
                    ),
                    Gap(10),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.green),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.green,
                            size: 20,
                          ),
                          Gap(8),
                          Text(
                            'Delivery rating submitted successfully',
                            style: TextStyles.smallpra.copyWith(
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
          // ===== END RATING SYSTEM UI =====
          if (buyerPhone != null) ...[
            Gap(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.chat_bubble_outline, color: AppColors.green),
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
                        SnackBar(content: Text('Could not open WhatsApp.')),
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
                            controller.buyOrder?.seller?.userIdForChat;
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
                        for (final c in chatController.listConversation) {
                          if ((c.user1 == sellerId &&
                                  c.user2 == currentUserId) ||
                              (c.user2 == sellerId &&
                                  c.user1 == currentUserId)) {
                            existing = c;
                            break;
                          }
                        }
                        if (existing != null) {
                          await chatController.getAllMessagesForConversation(
                            existing.id!,
                          );
                          chatController.user1Id = currentUserId;
                          chatController.user2Id = sellerId;
                          chatController.initChatForConversation(existing.id!);
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
                          if (chatController.listConversation.isNotEmpty) {
                            final newConvo =
                                chatController.listConversation.last;
                            await chatController.getAllMessagesForConversation(
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
    );
  }
}

class IncomingRequestsWidget extends StatelessWidget {
  BuyDetailsController controller;
  IncomingRequestsWidget(this.controller);

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
              SizedBox(
                width: 180,
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
                            controller.productrequest?.product?.image != null &&
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
                          "Buyer: ${controller.buymodel!.requester!.user!.name!}",
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
            ],
          ),
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
                          "${controller.buymodel!.selectedAddress!.buildingNumber!}${controller.buymodel!.selectedAddress!.buildingNumber != "" ? ',' : ""}${controller.buymodel!.selectedAddress!.street!}${controller.buymodel!.selectedAddress!.street != "" ? ',' : ""}${controller.buymodel!.selectedAddress!.neighborhood!}${controller.buymodel!.selectedAddress!.neighborhood != "" ? ',' : ""}${controller.buymodel!.selectedAddress!.city}${controller.buymodel!.selectedAddress!.city != "" ? ',' : ""}${controller.buymodel!.selectedAddress!.postalCode}${controller.buymodel!.selectedAddress!.postalCode != "" ? ',' : ""}${controller.buymodel!.selectedAddress!.country}",
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
                          controller.buymodel!.buyRequest!.deliveryType!,
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
                          controller.buymodel!.buyRequest!.paymentMethod!,
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
                        controller.buymodel?.buyRequest?.paymentStatus ??
                            "Unknown",
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
                      StatusIndicator(
                        status:
                            controller.buymodel?.buyRequest?.status ??
                            "Unknown",
                      ),
                    ],
                  ),
                  Gap(15),
                  Text(
                    "Order Status",
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
                      StatusIndicator(
                        status: controller.buyOrder?.orderStatus ?? "Unknown",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ), // Show Accept/Reject buttons only for pending requests
          if (controller.buymodel?.buyRequest?.status == "Pending") ...[
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
                        final res = await controller.ProcessBuyRequest(
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
                        final res = await controller.ProcessBuyRequest(
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

          // ===== RATING SYSTEM UI =====
          if (controller.canRateOrder) ...[
            Gap(30),
            Text(
              "Rate Your Experience",
              style: TextStyles.header.copyWith(color: AppColors.black),
            ),
            Gap(20),

            // Rate the other user (buyer in this case since current user is seller)
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
                    // User can still rate
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
                    // User has already rated - show read-only
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

            // Rate Delivery Driver
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
                    // User can still rate delivery
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
                    // User has already rated delivery - show read-only
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
                            "Delivery rating submitted successfully",
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
          // ===== END RATING SYSTEM UI =====// Chat buttons section
          if (buyerPhone != null) ...[
            Gap(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.chat_bubble_outline, color: AppColors.green),
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
                        SnackBar(content: Text('Could not open WhatsApp.')),
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
                            controller.buymodel?.requester?.user?.userIdForChat;
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
                        for (final c in chatController.listConversation) {
                          if ((c.user1 == sellerId &&
                                  c.user2 == currentUserId) ||
                              (c.user2 == sellerId &&
                                  c.user1 == currentUserId)) {
                            existing = c;
                            break;
                          }
                        }
                        if (existing != null) {
                          await chatController.getAllMessagesForConversation(
                            existing.id!,
                          );
                          chatController.user1Id = currentUserId;
                          chatController.user2Id = sellerId;
                          chatController.initChatForConversation(existing.id!);
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
                          if (chatController.listConversation.isNotEmpty) {
                            final newConvo =
                                chatController.listConversation.last;
                            await chatController.getAllMessagesForConversation(
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
    );
  }
}

class ChatButtonsBar extends StatelessWidget {
  final dynamic
  controller; // Accepts BuyDetailsController or SwapDetailsController
  const ChatButtonsBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<ServicesProvider>().userIdForChat;
    // Try to get user IDs for chat from either controller type
    final buyerUserIdForChat = controller.buyOrder?.buyer?.userIdForChat;
    final sellerUserIdForChat = controller.buyOrder?.seller?.userIdForChat;
    final otherUserId =
        (currentUserId == buyerUserIdForChat)
            ? sellerUserIdForChat
            : buyerUserIdForChat;
    final buyerPhone =
        controller.getBuyerPhoneInternational != null
            ? controller.getBuyerPhoneInternational()
            : (controller.buymodel?.buyer?.phone ?? '');

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
              final url = Uri.parse(
                'https://wa.me/${buyerPhone.replaceAll('+', '')}',
              );
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
              // Get current user ID from provider
              final currentUserId =
                  Provider.of<ServicesProvider>(
                    context,
                    listen: false,
                  ).userIdForChat;
              // Get seller's userIdForChat from product.buyer.user.userIdForChat
              final sellerId = controller.product.buyer?.user?.userIdForChat;
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
              final chatController = ChatPageUser1Controller(currentUserId);
              chatController.resetChatState();
              await chatController.getAllConversations();
              Conversation? existing;
              for (final c in chatController.listConversation) {
                if ((c.user1 == sellerId && c.user2 == currentUserId) ||
                    (c.user2 == sellerId && c.user1 == currentUserId)) {
                  existing = c;
                  break;
                }
              }
              if (existing != null) {
                await chatController.getAllMessagesForConversation(
                  existing.id!,
                );
                chatController.user1Id = currentUserId;
                chatController.user2Id = sellerId;
                chatController.initChatForConversation(existing.id!);
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
                if (chatController.listConversation.isNotEmpty) {
                  final newConvo = chatController.listConversation.last;
                  await chatController.getAllMessagesForConversation(
                    newConvo.id!,
                  );
                  chatController.user1Id = currentUserId;
                  chatController.user2Id = sellerId;
                  chatController.initChatForConversation(newConvo.id!);
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
          ),
        ],
      ),
    );
  }
}
