import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Services/Routes.dart';
import 'package:swapbuy/View/User/EditProduct/Controller/EditProductController.dart';
import 'package:swapbuy/View/User/EditProduct/EditProduct.dart';
import 'package:swapbuy/View/User/MyProduct/Controller/MyProductController.dart';

class Myproduct extends StatefulWidget {
  const Myproduct({super.key});

  @override
  State<Myproduct> createState() => _MyproductState();
}

class _MyproductState extends State<Myproduct> {
  late MyProductController controller;

  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    controller = Provider.of<MyProductController>(context, listen: false);
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
    return Consumer<MyProductController>(
      builder:
          (context, controller, child) => Scaffold(
            appBar: AppBar(centerTitle: true, title: Text("My Products")),
            body: RefreshIndicator(
              onRefresh: () => controller.RefreshData(context),
              child: ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.all(16),
                itemCount: controller.products.length,
                itemBuilder:
                    (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Container(
                        // height: 100,
                        decoration: BoxDecoration(
                          color: Color(0x0d000000),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 82.w,
                                      decoration: BoxDecoration(
                                        color: Color(0x80100F0F),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      height: 82.w,
                                      child: Center(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          child: FadeInImage.assetNetwork(
                                            fit: BoxFit.fill,
                                            placeholder: 'assets/PNG/Logo.png',
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
                                          style: TextStyles.paraghraph.copyWith(
                                            color: AppColors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              Divider(
                                color: const Color.fromARGB(126, 26, 26, 26),
                                thickness: 2,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      CustomRoute.RouteTo(
                                        context,
                                        ChangeNotifierProvider(
                                          create:
                                              (context) =>
                                                  EditProductController()
                                                    ..initcontroller(controller)
                                                    ..AllAddress(
                                                      context,
                                                      controller
                                                          .products[index],
                                                    )
                                                    ..CONDITIONOPTIONS(context)
                                                    ..STATUSOPTIONS(context),
                                          builder:
                                              (context, child) => Editproduct(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Edit",
                                      style: TextStyles.pramed,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      controller.DialogDeleteProduct(
                                        context,
                                        controller.products[index],
                                      );
                                    },
                                    child: Text(
                                      "Delete",
                                      style: TextStyles.pramed,
                                    ),
                                  ),
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
    );
  }
}
