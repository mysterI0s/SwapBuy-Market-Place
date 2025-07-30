import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Model/Address.dart';
import 'package:swapbuy/View/User/CartSwap/Controller/CartSwapPageController.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:gap/gap.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Widgets/Button/ButtonCustom.dart';
import 'package:swapbuy/Widgets/Dropdown/DropdownCustom.dart';

class CartSwapPage extends StatelessWidget {
  const CartSwapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartSwapPageController>(
      builder:
          (context, controller, child) => SafeArea(
            child: Scaffold(
              appBar: AppBar(centerTitle: true, title: Text("Cart")),

              body: Form(
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
                                          "${controller.productrequest!.product!.image}",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Gap(10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Product: ${controller.productrequest!.product!.name!}",
                                      style: TextStyles.pramed.copyWith(
                                        color: AppColors.black,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      "Owner: ${"${controller.productrequest!.buyer?.user?.name! ?? "Unkown"}"}",
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
                        Icon(
                          Icons.swap_horiz_outlined,
                          size: 32,
                          color: AppColors.black,
                        ),
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
                                          "${controller.productoffered!.product!.image}",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Gap(10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Product: ${controller.productoffered!.product!.name!}",
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
                              style: TextStyles.pramed.copyWith(
                                color: Color(0x80000000),
                              ),
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

                                                  style: TextStyles.paraghraph
                                                      .copyWith(
                                                        color: Color(
                                                          0xff000000,
                                                        ),
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
                              style: TextStyles.pramed.copyWith(
                                color: Color(0x80000000),
                              ),
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
                                                  style: TextStyles.paraghraph
                                                      .copyWith(
                                                        color: Color(
                                                          0xff000000,
                                                        ),
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
                              style: TextStyles.pramed.copyWith(
                                color: Color(0x80000000),
                              ),
                            ),
                            Gap(10),
                            Row(
                              children: [
                                Icon(
                                  Icons.payment,
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
                                    value: controller.paymentmethod,
                                    items:
                                        controller.paymentmethods
                                            .map(
                                              (e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(
                                                  e,
                                                  style: TextStyles.paraghraph
                                                      .copyWith(
                                                        color: Color(
                                                          0xff000000,
                                                        ),
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
                    // Expanded(
                    //   child: ListView.builder(
                    //     controller: scrollController,
                    //     padding: EdgeInsets.all(16),
                    //     itemCount: controller.products.length,
                    //     itemBuilder:
                    //         (context, index) => Padding(
                    //           padding: const EdgeInsets.symmetric(vertical: 5),
                    //           child: Container(
                    //             decoration: BoxDecoration(
                    //               color: Color(0x0d000000),
                    //               borderRadius: BorderRadius.circular(15),
                    //             ),
                    //             child: Padding(
                    //               padding: const EdgeInsets.all(8.0),
                    //               child: Row(
                    //                 crossAxisAlignment: CrossAxisAlignment.center,
                    //                 mainAxisAlignment: MainAxisAlignment.start,
                    //                 children: [
                    //                   Center(
                    //                     child: Container(
                    //                       width: 82.w,
                    //                       decoration: BoxDecoration(
                    //                         color: Color(0x80100F0F),
                    //                         borderRadius: BorderRadius.circular(
                    //                           15,
                    //                         ),
                    //                       ),
                    //                       height: 82.w,
                    //                       child: Center(
                    //                         child: ClipRRect(
                    //                           borderRadius: BorderRadius.circular(
                    //                             15,
                    //                           ),
                    //                           child: FadeInImage.assetNetwork(
                    //                             fit: BoxFit.fill,
                    //                             width: double.infinity,
                    //                             placeholder:
                    //                                 'assets/PNG/Logo.png',
                    //                             image:
                    //                                 "${controller.products[index].product!.image}",
                    //                           ),
                    //                         ),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                   Gap(7),
                    //                   Expanded(
                    //                     child: Column(
                    //                       crossAxisAlignment:
                    //                           CrossAxisAlignment.start,
                    //                       children: [
                    //                         Text(
                    //                           controller
                    //                               .products[index]
                    //                               .product!
                    //                               .name!,
                    //                           style: TextStyles.title.copyWith(
                    //                             color: AppColors.black,
                    //                           ),
                    //                         ),
                    //                         Text(
                    //                           "${controller.products[index].product!.price!}\$",
                    //                           style: TextStyles.paraghraph
                    //                               .copyWith(
                    //                                 color: AppColors.black,
                    //                               ),
                    //                         ),
                    //                       ],
                    //                     ),
                    //                   ),
                    Gap(30),
                    ButtonCustom(
                      fullWidth: false,
                      fullheight: false,
                      // width: 63.5,
                      // height: 31.6,
                      color: AppColors.thirdy,
                      onTap: () async {
                        if (controller.keyform.currentState!.validate()) {
                          EasyLoading.show();
                          try {
                            final res = await controller.RequestSwap(context);

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
                      child: Text("Confirm", style: TextStyles.button),
                    ),
                    //                 ],
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
