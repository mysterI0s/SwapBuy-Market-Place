import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Model/Conversation.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';
import 'package:swapbuy/View/Chat/Controller/ChatPageUserController.dart';
import 'package:swapbuy/View/Chat/ChatDetailScreen.dart';
import 'package:swapbuy/Model/ProductFull.dart';
import 'package:swapbuy/Services/Routes.dart';
import 'package:swapbuy/View/User/CartBuy/CartBuyPage.dart';
import 'package:swapbuy/View/User/CartBuy/Controller/CartBuyPageController.dart';
import 'package:swapbuy/View/User/ProductDetails/Controller/ProductDetailsController.dart';
import 'package:swapbuy/View/User/ProductDetails/VideoPlayerScreen.dart';
import 'package:swapbuy/View/User/Swap/Controller/SwapPageController.dart';
import 'package:swapbuy/View/User/Swap/SwapPage.dart';
import 'package:swapbuy/Widgets/Button/ButtonCustom.dart';

class ProductDetails extends StatelessWidget {
  ProductFull product;
  ProductDetails(this.product);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductDetailsController>(
      builder:
          (context, controller, child) => Scaffold(
            body: ListView(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(.5),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      height: 350.h,
                      width: double.infinity,
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/PNG/Logo.png',
                        fit: BoxFit.fill,

                        image: "${product.product!.image}",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            backgroundColor: Color(0x63D9D9D9),
                            foregroundColor: AppColors.basic,
                            radius: 25,
                            child: SvgPicture.asset(
                              "assets/SVG/share.svg",
                              color: AppColors.basic,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => CustomRoute.RoutePop(context),
                            child: CircleAvatar(
                              foregroundColor: AppColors.basic,
                              backgroundColor: Color(0x63D9D9D9),
                              radius: 25,
                              child: Icon(Icons.arrow_forward_ios_outlined),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Gap(27),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 31),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.product!.name!,
                          style: TextStyles.pramed.copyWith(fontSize: 18.sp),
                        ),
                      ),
                      Gap(10),
                      ButtonCustom(
                        fullWidth: false,
                        fullheight: false,
                        width: 63.5,
                        height: 31.6,
                        color: AppColors.thirdy,
                        onTap: () {
                          controller.AddProductWishList(
                            context,
                            product.product!.id!,
                          );
                        },
                        child:
                            controller.isloadingaddwishlist
                                ? CircularProgressIndicator(
                                  color: AppColors.basic,
                                )
                                : SvgPicture.asset(
                                  "assets/SVG/Bookmark_light.svg",
                                ),
                      ),
                    ],
                  ),
                ),
                Gap(15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 31),
                  child: Row(
                    children: [
                      Text(
                        "${product.product!.price!.toString()}\$",
                        style: TextStyles.inputtitle.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                      Gap(20),
                      Text(
                        "Quantity: ",
                        style: TextStyles.inputtitle.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.orange,
                        foregroundColor: AppColors.basic,
                        child: Text(
                          "${product.product!.quantityAvailable}",
                          style: TextStyles.inputtitle.copyWith(
                            color: AppColors.basic,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 31),
                  child: Text(
                    "${product.product!.description!.toString()}",
                    style: TextStyles.pramed.copyWith(fontSize: 12),
                  ),
                ),
                Gap(25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 31),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ButtonCustom(
                        onTap: () {
                          // log(product.product!.addedAt!);
                        },
                        bordercolor: Color(0xff247000),
                        bordersize: 1,
                        color: Color(0x8064AD41),
                        borderradius: 15,
                        height: 35,
                        fullWidth: false,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            product.product!.condition!,
                            style: TextStyles.smallpra.copyWith(
                              color: Color(0x85000000),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        "${controller.getPostedTime(product.product!.addedAt!)}",
                        style: TextStyles.smallpra.copyWith(
                          color: Color(0xff000000),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(64),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 31),
                  child: ButtonCustom(
                    onTap: () async {
                      // Get current user ID from provider
                      final currentUserId =
                          Provider.of<ServicesProvider>(
                            context,
                            listen: false,
                          ).userIdForChat;
                      // Get seller's userIdForChat from product.buyer.user.userIdForChat
                      final sellerId = product.buyer?.user?.userIdForChat;
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
                    color: AppColors.thirdy,
                    title: "Chat with the seller-Request",
                  ),
                ),
                Gap(12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 31),
                  child: ButtonCustom(
                    onTap: () {
                      CustomRoute.RouteTo(
                        context,
                        ChangeNotifierProvider(
                          create:
                              (context) =>
                                  CartBuyPageController()
                                    ..AllAddress(context)
                                    ..initstate(product),
                          builder: (context, child) => CartBuyPage(),
                        ),
                      );
                    },
                    color: AppColors.orange,
                    title: "Buy now",
                  ),
                ),

                Gap(12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 31),
                  child: ButtonCustom(
                    onTap: () {
                      CustomRoute.RouteTo(
                        context,
                        ChangeNotifierProvider(
                          create:
                              (context) =>
                                  SwapPageController()..MyProducts(context),
                          builder: (context, child) => SwapPage(product),
                        ),
                      );
                    },
                    color: AppColors.greenlight,
                    title: "Swap now",
                  ),
                ),
                Gap(12),
                // Show View Video button only if videoFile exists and is not empty
                if (product.product!.videoFile != null &&
                    product.product!.videoFile!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 31),
                    child: ButtonCustom(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => VideoPlayerScreen(
                                  videoUrl: product.product!.videoFile!,
                                ),
                          ),
                        );
                      },
                      color: AppColors.thirdy,
                      title: "View Video",
                    ),
                  ),
              ],
            ),
          ),
    );
  }
}
