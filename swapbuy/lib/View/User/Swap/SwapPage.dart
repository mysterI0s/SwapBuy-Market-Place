import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Model/ProductFull.dart';
import 'package:swapbuy/Services/Routes.dart';
import 'package:swapbuy/View/User/CartSwap/CartSwapPage.dart';
import 'package:swapbuy/View/User/CartSwap/Controller/CartSwapPageController.dart';
import 'package:swapbuy/View/User/Swap/Controller/SwapPageController.dart';
import 'package:swapbuy/Widgets/Button/ButtonCustom.dart';

class SwapPage extends StatefulWidget {
  SwapPage(this.productFull);
  ProductFull productFull;

  @override
  State<SwapPage> createState() => _SwapPageState();
}

class _SwapPageState extends State<SwapPage> {
  late SwapPageController controller;

  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    controller = Provider.of<SwapPageController>(context, listen: false);
    Future.delayed(Duration.zero).then((value) {
      scrollController.addListener(() {
        if (scrollController.position.pixels >=
                scrollController.position.maxScrollExtent - 100 &&
            !controller.isLoadingMore &&
            controller.next != null) {
          controller.MyProducts(context);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SwapPageController>(
      builder:
          (context, controller, child) => Scaffold(
            appBar: AppBar(centerTitle: true, title: Text("Swap Page")),
            body: RefreshIndicator(
              onRefresh: () => controller.RefreshData(context),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SizedBox(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,

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
                                          "${widget.productFull.product!.image}",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Gap(10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.productFull.product!.name!,
                                      style: TextStyles.pramed.copyWith(
                                        color: AppColors.black,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      "${"${widget.productFull.product!.price!}\$"}",
                                      style: TextStyles.smallpra.copyWith(
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Gap(10),
                        Center(
                          child: Icon(
                            Icons.swap_horiz_outlined,
                            size: 32,
                            color: AppColors.black,
                          ),
                        ),
                        Gap(10),

                        Expanded(
                          child: SizedBox(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0x1A000000),
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  height: 150,
                                  width: double.infinity,
                                  child: Icon(
                                    Icons.image,
                                    size: 30,
                                    color: AppColors.black,
                                  ),
                                ),
                                Gap(10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Your Product",
                                      style: TextStyles.pramed.copyWith(
                                        color: AppColors.black,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(""),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // GridView(
                  //   shrinkWrap: true,
                  //   physics: NeverScrollableScrollPhysics(),
                  //   padding: EdgeInsets.all(15),
                  //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  //     crossAxisCount: 2,
                  //     childAspectRatio: 0.8,
                  //     mainAxisSpacing: 2,
                  //     crossAxisSpacing: 5,
                  //   ),
                  //   children: [
                  //     SizedBox(
                  //       // height: 250,
                  //       // width: 250,
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Container(
                  //             decoration: BoxDecoration(
                  //               color: Color(0x1A000000),
                  //               borderRadius: BorderRadius.circular(13),
                  //             ),
                  //             height: 180,
                  //             width: double.infinity,
                  //             child: ClipRRect(
                  //               borderRadius: BorderRadius.circular(13),
                  //               child: FadeInImage.assetNetwork(
                  //                 placeholder: "assets/PNG/Logo.png",
                  //                 image: "${widget.productFull.product!.image}",
                  //                 fit: BoxFit.cover,
                  //               ),
                  //             ),
                  //           ),
                  //           Gap(10),
                  //           Expanded(
                  //             child: Column(
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: [
                  //                 Text(
                  //                   widget.productFull.product!.name!,
                  //                   style: TextStyles.pramed.copyWith(
                  //                     color: AppColors.black,
                  //                   ),
                  //                   maxLines: 1,
                  //                   overflow: TextOverflow.ellipsis,
                  //                 ),
                  //                 Text(
                  //                   "${"${widget.productFull.product!.price!}\$"}",
                  //                   style: TextStyles.smallpra.copyWith(
                  //                     color: AppColors.black,
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //     SizedBox(
                  //       // height: 250,
                  //       // width: 250,
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.center,
                  //         children: [
                  //           Container(
                  //             decoration: BoxDecoration(
                  //               color: Color(0x1A000000),
                  //               borderRadius: BorderRadius.circular(13),
                  //             ),
                  //             height: 180,
                  //             width: double.infinity,
                  //             child: Icon(
                  //               Icons.image,
                  //               size: 30,
                  //               color: AppColors.black,
                  //             ),
                  //           ),
                  //           Gap(10),
                  //           Expanded(
                  //             child: Column(
                  //               crossAxisAlignment: CrossAxisAlignment.center,
                  //               children: [
                  //                 Text(
                  //                   "Your Product",
                  //                   style: TextStyles.pramed.copyWith(
                  //                     color: AppColors.black,
                  //                   ),
                  //                   maxLines: 1,
                  //                   overflow: TextOverflow.ellipsis,
                  //                   textAlign: TextAlign.center,
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  Text(
                    "Select product you want swap",
                    style: TextStyles.title.copyWith(color: AppColors.black),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.all(16),
                      itemCount: controller.products.length,
                      itemBuilder:
                          (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0x0d000000),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            child: FadeInImage.assetNetwork(
                                              fit: BoxFit.fill,
                                              width: double.infinity,
                                              placeholder:
                                                  'assets/PNG/Logo.png',
                                              image:
                                                  "${controller.products[index].product!.image}",
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
                                                .products[index]
                                                .product!
                                                .name!,
                                            style: TextStyles.title.copyWith(
                                              color: AppColors.black,
                                            ),
                                          ),
                                          Text(
                                            "${controller.products[index].product!.price!}\$",
                                            style: TextStyles.paraghraph
                                                .copyWith(
                                                  color: AppColors.black,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ButtonCustom(
                                      fullWidth: false,
                                      fullheight: false,
                                      width: 63.5,
                                      height: 31.6,
                                      color: AppColors.thirdy,
                                      onTap: () {
                                        CustomRoute.RouteTo(
                                          context,
                                          ChangeNotifierProvider(
                                            create:
                                                (context) =>
                                                    CartSwapPageController()
                                                      ..initstate(
                                                        widget.productFull,
                                                        controller
                                                            .products[index],
                                                      )
                                                      ..AllAddress(context),
                                            builder:
                                                (context, child) =>
                                                    CartSwapPage(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "Select",
                                        style: TextStyles.button,
                                      ),
                                    ),
                                  ],
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
