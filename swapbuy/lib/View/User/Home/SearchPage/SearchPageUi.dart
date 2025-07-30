import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Model/ProductFull.dart';
import 'package:swapbuy/Services/Routes.dart';
import 'package:swapbuy/View/User/Home/SearchPage/Controller/SearchPageController.dart';
import 'package:swapbuy/View/User/ProductDetails/Controller/ProductDetailsController.dart';
import 'package:swapbuy/View/User/ProductDetails/ProductDetails.dart';

class SearchResultsPage extends StatefulWidget {
  final String query;

  const SearchResultsPage({super.key, required this.query});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late SearchPageController controller;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Provider.of<SearchPageController>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // فقط قم بإعادة تعيين البحث إذا كانت هذه أول مرة يتم فيها عرض الصفحة
      // أو إذا تغيرت قيمة البحث
      if (controller.currentQuery != widget.query) {
        controller.resetSearch();
        controller.searchProducts(widget.query, context);
      }
    });

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 0 &&
          !controller.isLoading &&
          controller.next != null) {
        controller.searchProducts(widget.query, context);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchPageController>(
      builder: (context, controller, child) {
        return Scaffold(
          body:
              controller.results.isEmpty && controller.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : controller.results.isEmpty
                  ? Center(
                    child: Text(
                      'No Results Found',
                      style: TextStyles.title.copyWith(color: AppColors.black),
                    ),
                  )
                  : RefreshIndicator(
                    onRefresh: () async {
                      controller.resetSearch();
                      await controller.searchProducts(widget.query, context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Expanded(
                            child: GridView.builder(
                              controller: scrollController,
                              itemCount: controller.results.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.8,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                              itemBuilder: (context, index) {
                                ProductFull product = controller.results[index];
                                return GestureDetector(
                                  onTap:
                                      () => CustomRoute.RouteTo(
                                        context,
                                        ChangeNotifierProvider(
                                          create:
                                              (context) =>
                                                  ProductDetailsController(),
                                          builder:
                                              (context, child) =>
                                                  ProductDetails(product),
                                        ),
                                      ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 180,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            13,
                                          ),
                                          color: AppColors.black,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            13,
                                          ),
                                          child: FadeInImage.assetNetwork(
                                            placeholder: "assets/PNG/Logo.png",
                                            image: "${product.product!.image}",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Gap(10),
                                      Text(
                                        product.product!.name ?? '',
                                        style: TextStyles.pramed.copyWith(
                                          color: AppColors.black,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "${product.product!.price ?? ''}\$",
                                        style: TextStyles.smallpra.copyWith(
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          if (controller.next != null || controller.isLoading)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                "Loading more..",
                                style: TextStyles.title.copyWith(
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
        );
      },
    );
  }
}
