import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Services/Routes.dart';
import 'package:swapbuy/View/User/Home/Controller/HomePageUserController.dart';
import 'package:swapbuy/View/User/Home/FilterBottomSheet.dart';
import 'package:swapbuy/View/User/Home/SearchPage/Controller/SearchPageController.dart';
import 'package:swapbuy/View/User/Home/SearchPage/SearchPage.dart';
import 'package:swapbuy/View/User/ProductDetails/Controller/ProductDetailsController.dart';
import 'package:swapbuy/View/User/ProductDetails/ProductDetails.dart';
import 'package:swapbuy/Widgets/TextInput/TextInputCustom.dart';

class Homepageuser extends StatefulWidget {
  const Homepageuser({super.key});

  @override
  State<Homepageuser> createState() => _HomepageuserState();
}

class _HomepageuserState extends State<Homepageuser> {
  late HomePageUserController controller;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Provider.of<HomePageUserController>(context, listen: false);
    Future.delayed(Duration.zero).then((value) {
      scrollController.addListener(() {
        if (scrollController.position.pixels >=
                scrollController.position.maxScrollExtent - 200 &&
            !controller.isLoadingMore &&
            controller.next != null) {
          controller.AllProduct(context);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomePageUserController>(
      builder:
          (context, controller, child) => Scaffold(
            body: RefreshIndicator(
              onRefresh: () => controller.RefreshData(context),
              child: SingleChildScrollView(
                controller: scrollController,

                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Gap(20),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                ),
                                builder:
                                    (context) => Padding(
                                      padding: EdgeInsets.only(
                                        bottom:
                                            MediaQuery.of(
                                              context,
                                            ).viewInsets.bottom,
                                      ),
                                      child: FilterBottomSheet(controller),
                                    ),
                              );
                            },
                            icon: Icon(
                              Icons.filter_list_outlined,
                              color: AppColors.primary,
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                final searchController = SearchPageController();
                                showSearch(
                                  context: context,
                                  delegate: ProductSearchDelegate(
                                    searchController,
                                  ),
                                );
                              },
                              child: TextInputCustom(
                                enable: false,
                                hint: "Search",
                                suffix: Icon(
                                  Icons.search,
                                  color: Color(0xff000000),
                                ),
                                fillcolor: Color(0xff000000),
                                bordercolor: Color(0x1A000000),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Gap(10),
                      Stack(
                        children: [
                          // Container(
                          //   height: 150.h,
                          //   width: double.infinity,
                          //   decoration: BoxDecoration(
                          //     color: Color(0x1A000000),
                          //     borderRadius: BorderRadius.circular(14),
                          //   ),
                          // ),
                          Container(
                            height: 150.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0x1A000000),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),

                              child: Image.asset(
                                "assets/PNG/image_ad.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            height: 150.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xFFFFFFFF).withOpacity(.4),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: AutoSizeText(
                                          "Buy",
                                          style: TextStyles.header.copyWith(
                                            letterSpacing: 8,

                                            color: AppColors.black.withOpacity(
                                              .8,
                                            ),
                                          ),
                                          maxFontSize: 35,
                                          minFontSize: 35,
                                        ),
                                      ),
                                      Expanded(
                                        child: AutoSizeText(
                                          "Sell",
                                          style: TextStyles.header.copyWith(
                                            letterSpacing: 8,

                                            color: AppColors.black.withOpacity(
                                              .8,
                                            ),
                                          ),
                                          maxFontSize: 35,
                                          minFontSize: 35,
                                        ),
                                      ),
                                      Expanded(
                                        child: AutoSizeText(
                                          "Swap",
                                          style: TextStyles.header.copyWith(
                                            letterSpacing: 8,
                                            color: AppColors.black.withOpacity(
                                              .8,
                                            ),
                                          ),
                                          maxFontSize: 35,
                                          minFontSize: 35,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional.topEnd,
                                    child: Image.asset(
                                      "assets/PNG/Logo.png",
                                      width: 37.w,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Gap(10),
                      Divider(
                        color: const Color.fromARGB(231, 26, 26, 26),
                        endIndent: 30,
                        indent: 30,
                      ),
                      Gap(20),
                      GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: controller.products.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap:
                                () => CustomRoute.RouteTo(
                                  context,
                                  ChangeNotifierProvider(
                                    create:
                                        (context) => ProductDetailsController(),
                                    builder:
                                        (context, child) => ProductDetails(
                                          controller.products[index],
                                        ),
                                  ),
                                ),
                            child: SizedBox(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0x1A000000),
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    height: 180,
                                    width: double.infinity,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(13),
                                      child: FadeInImage.assetNetwork(
                                        placeholder: "assets/PNG/Logo.png",
                                        image:
                                            "${controller.products[index].product!.image}",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Gap(10),
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
                                          style: TextStyles.pramed.copyWith(
                                            color: AppColors.black,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "${"${controller.products[index].product!.price!}\$"}",
                                          style: TextStyles.smallpra.copyWith(
                                            color: AppColors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 5,
                        ),
                      ),
                      if (controller.isLoadingMore)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(
                            color: AppColors.black,
                            strokeWidth: 2,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
