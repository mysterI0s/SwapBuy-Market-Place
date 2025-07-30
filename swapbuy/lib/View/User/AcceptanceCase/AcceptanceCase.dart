import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Services/Routes.dart';
import 'package:swapbuy/View/User/AcceptanceCase/Controller/AcceptanceCaseController.dart';
import 'package:swapbuy/View/User/BuyDetails/BuyDetails.dart';
import 'package:swapbuy/View/User/BuyDetails/Controller/BuyDetailsController.dart';
import 'package:swapbuy/View/User/SwapDetails/Controller/SwapDetailsController.dart';
import 'package:swapbuy/View/User/SwapDetails/SwapDetails.dart';
import 'package:swapbuy/Widgets/StatusIndicator/StatusIndicator.dart';

class AcceptanceCase extends StatelessWidget {
  const AcceptanceCase({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AcceptanceCaseController>(
      builder:
          (context, controller, child) => DefaultTabController(
            length: 2,
            initialIndex: 0,
            child: Scaffold(
              appBar: AppBar(
                title: Text("Acceptance case"),
                centerTitle: true,
                bottom: TabBar(
                  tabs: [Tab(child: Text("Swap")), Tab(child: Text("Buy"))],
                ),
              ),
              body: TabBarView(
                children: [
                  RefreshIndicator(
                    onRefresh: () => controller.ListSentSwap(context),
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
                                              caseController: controller,
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
                                              child: FadeInImage.assetNetwork(
                                                fit: BoxFit.fill,
                                                height: double.infinity,
                                                width: double.infinity,
                                                placeholder:
                                                    'assets/PNG/Logo.png',

                                                image:
                                                    "${controller.swaprequests[index].productRequested!.product!.image}",
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
                                          ],
                                        ),
                                      ),
                                      Gap(10),
                                      StatusIndicator(
                                        status:
                                            controller
                                                .swaprequests[index]
                                                .swapRequest!
                                                .status!,
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
                    onRefresh: () => controller.ListSentBuy(context),
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
                                              caseController: controller,
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
                                              child: FadeInImage.assetNetwork(
                                                fit: BoxFit.fill,
                                                height: double.infinity,
                                                width: double.infinity,
                                                placeholder:
                                                    'assets/PNG/Logo.png',

                                                image:
                                                    "${controller.buyrequests[index].productRequested!.product!.image}",
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
                                          ],
                                        ),
                                      ),
                                      Gap(10),
                                      StatusIndicator(
                                        status:
                                            controller
                                                .buyrequests[index]
                                                .buyRequest!
                                                .status!,
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
