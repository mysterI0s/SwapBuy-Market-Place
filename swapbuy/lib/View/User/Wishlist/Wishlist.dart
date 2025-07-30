import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/View/User/Wishlist/Controller/WishlistController.dart';
import 'package:swapbuy/Widgets/Button/ButtonCustom.dart';

class Wishlist extends StatelessWidget {
  const Wishlist({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistController>(
      builder:
          (context, controller, child) => Scaffold(
            appBar: AppBar(centerTitle: true, title: Text("Wish List")),
            body: ListView.builder(
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
                                    borderRadius: BorderRadius.circular(15),
                                    child: FadeInImage.assetNetwork(
                                      fit: BoxFit.fill,
                                      width: double.infinity,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.products[index].product!.name!,
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
                            ButtonCustom(
                              fullWidth: false,
                              fullheight: false,
                              width: 63.5,
                              height: 31.6,
                              color: AppColors.thirdy,
                              onTap: () {
                                controller.RemoveProductWishList(
                                  context,
                                  controller.products[index].product!.id!,
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
                    ),
                  ),
            ),
          ),
    );
  }
}
