import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Services/Routes.dart';
import 'package:swapbuy/View/User/BuyDetails/BuyDetails.dart';
import 'package:swapbuy/View/User/BuyDetails/Controller/BuyDetailsController.dart';
import 'package:swapbuy/View/User/IncomingRequests/Controller/IncomingRequestsController.dart';
import 'package:swapbuy/View/User/SwapDetails/Controller/SwapDetailsController.dart';
import 'package:swapbuy/View/User/SwapDetails/SwapDetails.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swapbuy/Widgets/StatusIndicator/StatusIndicator.dart';

class IncomingRequests extends StatelessWidget {
  const IncomingRequests({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IncomingRequestsController>(
      builder:
          (context, controller, child) => DefaultTabController(
            length: 2,
            initialIndex: 0,
            child: Scaffold(
              appBar: AppBar(
                title: Text("Incoming Requests"),
                centerTitle: true,
                bottom: TabBar(
                  tabs: [Tab(child: Text("Swap")), Tab(child: Text("Buy"))],
                ),
              ),
              body: TabBarView(
                children: [
                  RefreshIndicator(
                    onRefresh: () => controller.ListReceivedSwap(context),
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: controller.swaprequests.length,
                      itemBuilder:
                          (context, index) => GestureDetector(
                            onTap:
                                () => CustomRoute.RouteTo(
                                  context,
                                  ChangeNotifierProvider(
                                    create:
                                        (context) =>
                                            SwapDetailsController()..initstate(
                                              context,
                                              controller.swaprequests[index],
                                              incomingRequestsController:
                                                  controller,
                                            ),
                                    builder: (context, child) => SwapDetails(),
                                  ),
                                ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0x0d000000),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 82.w,
                                          decoration: BoxDecoration(
                                            color: Color(0x80100F0F),
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          height: 82.w,
                                          child: Center(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child:
                                                  controller
                                                                  .swaprequests[index]
                                                                  .productRequested
                                                                  ?.product
                                                                  ?.image !=
                                                              null &&
                                                          controller
                                                              .swaprequests[index]
                                                              .productRequested!
                                                              .product!
                                                              .image!
                                                              .isNotEmpty
                                                      ? FadeInImage.assetNetwork(
                                                        fit: BoxFit.fill,
                                                        height: double.infinity,
                                                        width: double.infinity,
                                                        placeholder:
                                                            'assets/PNG/Logo.png',
                                                        image:
                                                            "${controller.swaprequests[index].productRequested!.product!.image}",
                                                        imageErrorBuilder: (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Image.asset(
                                                            "assets/PNG/Logo.png",
                                                          );
                                                        },
                                                        placeholderErrorBuilder: (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Image.asset(
                                                            "assets/PNG/Logo.png",
                                                          );
                                                        },
                                                      )
                                                      : Image.asset(
                                                        "assets/PNG/Logo.png",
                                                      ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Gap(7),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              controller
                                                  .swaprequests[index]
                                                  .productRequested!
                                                  .product!
                                                  .name!,
                                              style: TextStyles.title.copyWith(
                                                color: AppColors.black,
                                              ),
                                            ),
                                            Text(
                                              "${controller.swaprequests[index].productRequested!.product!.price!}\$",
                                              style: TextStyles.paraghraph
                                                  .copyWith(
                                                    color: AppColors.black,
                                                  ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Swap",
                                                  style: TextStyles.paraghraph
                                                      .copyWith(
                                                        color: AppColors.black,
                                                      ),
                                                ),
                                                Gap(5),
                                                Icon(
                                                  controller
                                                              .swaprequests[index]
                                                              .swapRequest!
                                                              .status ==
                                                          "Pending"
                                                      ? Icons.help_outline
                                                      : controller
                                                              .swaprequests[index]
                                                              .swapRequest!
                                                              .status ==
                                                          "Accepted"
                                                      ? Icons.check_circle
                                                      : Icons.cancel,
                                                  color:
                                                      controller
                                                                  .swaprequests[index]
                                                                  .swapRequest!
                                                                  .status ==
                                                              "Pending"
                                                          ? AppColors.grey
                                                          : controller
                                                                  .swaprequests[index]
                                                                  .swapRequest!
                                                                  .status ==
                                                              "Accepted"
                                                          ? AppColors.green
                                                          : AppColors.red,
                                                  size: 16,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Gap(10),
                                      Column(
                                        children: [
                                          // Close button
                                          GestureDetector(
                                            onTap: () {
                                              controller.removeSwapRequest(
                                                index,
                                                context,
                                              );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(4),
                                              child: Icon(
                                                Icons.close,
                                                color: AppColors.grey,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                          Gap(5),
                                          // Status indicator
                                          StatusIndicator(
                                            status:
                                                controller
                                                    .swaprequests[index]
                                                    .swapRequest!
                                                    .status!,
                                          ),
                                          Gap(5),
                                          // Action buttons
                                          if (controller
                                                  .swaprequests[index]
                                                  .swapRequest!
                                                  .status ==
                                              "Pending") ...[
                                            Row(
                                              children: [
                                                // WhatsApp button
                                                Container(
                                                  padding: EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.green,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: SvgPicture.asset(
                                                    "assets/SVG/whatsapp1.svg",
                                                    color: AppColors.white,
                                                    width: 16,
                                                    height: 16,
                                                  ),
                                                ),
                                                Gap(5),
                                                // Message button
                                                Container(
                                                  padding: EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.chat_bubble_outline,
                                                    color: AppColors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                  RefreshIndicator(
                    onRefresh: () => controller.ListReceivedBuy(context),
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: controller.buyrequests.length,
                      itemBuilder:
                          (context, index) => GestureDetector(
                            onTap:
                                () => CustomRoute.RouteTo(
                                  context,
                                  ChangeNotifierProvider(
                                    create:
                                        (context) =>
                                            BuyDetailsController()..initstate(
                                              context,
                                              controller.buyrequests[index],
                                              incomingRequestsController:
                                                  controller,
                                            ),
                                    builder: (context, child) => BuyDetails(),
                                  ),
                                ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0x0d000000),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 82.w,
                                          decoration: BoxDecoration(
                                            color: Color(0x80100F0F),
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          height: 82.w,
                                          child: Center(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child:
                                                  controller
                                                                  .buyrequests[index]
                                                                  .productRequested
                                                                  ?.product
                                                                  ?.image !=
                                                              null &&
                                                          controller
                                                              .buyrequests[index]
                                                              .productRequested!
                                                              .product!
                                                              .image!
                                                              .isNotEmpty
                                                      ? FadeInImage.assetNetwork(
                                                        fit: BoxFit.fill,
                                                        height: double.infinity,
                                                        width: double.infinity,
                                                        placeholder:
                                                            'assets/PNG/Logo.png',
                                                        image:
                                                            "${controller.buyrequests[index].productRequested!.product!.image}",
                                                        imageErrorBuilder: (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Image.asset(
                                                            "assets/PNG/Logo.png",
                                                          );
                                                        },
                                                        placeholderErrorBuilder: (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Image.asset(
                                                            "assets/PNG/Logo.png",
                                                          );
                                                        },
                                                      )
                                                      : Image.asset(
                                                        "assets/PNG/Logo.png",
                                                      ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Gap(7),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              controller
                                                  .buyrequests[index]
                                                  .productRequested!
                                                  .product!
                                                  .name!,
                                              style: TextStyles.title.copyWith(
                                                color: AppColors.black,
                                              ),
                                            ),
                                            Text(
                                              "${controller.buyrequests[index].productRequested!.product!.price!}\$",
                                              style: TextStyles.paraghraph
                                                  .copyWith(
                                                    color: AppColors.black,
                                                  ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Buy",
                                                  style: TextStyles.paraghraph
                                                      .copyWith(
                                                        color: AppColors.black,
                                                      ),
                                                ),
                                                Gap(5),
                                                Icon(
                                                  controller
                                                              .buyrequests[index]
                                                              .buyRequest!
                                                              .status ==
                                                          "Pending"
                                                      ? Icons.help_outline
                                                      : controller
                                                              .buyrequests[index]
                                                              .buyRequest!
                                                              .status ==
                                                          "Accepted"
                                                      ? Icons.check_circle
                                                      : Icons.cancel,
                                                  color:
                                                      controller
                                                                  .buyrequests[index]
                                                                  .buyRequest!
                                                                  .status ==
                                                              "Pending"
                                                          ? AppColors.grey
                                                          : controller
                                                                  .buyrequests[index]
                                                                  .buyRequest!
                                                                  .status ==
                                                              "Accepted"
                                                          ? AppColors.green
                                                          : AppColors.red,
                                                  size: 16,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Gap(10),
                                      Column(
                                        children: [
                                          // Close button
                                          GestureDetector(
                                            onTap: () {
                                              controller.removeBuyRequest(
                                                index,
                                                context,
                                              );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(4),
                                              child: Icon(
                                                Icons.close,
                                                color: AppColors.grey,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                          Gap(5),
                                          // Status indicator
                                          StatusIndicator(
                                            status:
                                                controller
                                                    .buyrequests[index]
                                                    .buyRequest!
                                                    .status!,
                                          ),
                                          Gap(5),
                                          // Action buttons
                                          if (controller
                                                  .buyrequests[index]
                                                  .buyRequest!
                                                  .status ==
                                              "Pending") ...[
                                            Row(
                                              children: [
                                                // WhatsApp button
                                                Container(
                                                  padding: EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.green,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: SvgPicture.asset(
                                                    "assets/SVG/whatsapp1.svg",
                                                    color: AppColors.white,
                                                    width: 16,
                                                    height: 16,
                                                  ),
                                                ),
                                                Gap(5),
                                                // Message button
                                                Container(
                                                  padding: EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.chat_bubble_outline,
                                                    color: AppColors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
