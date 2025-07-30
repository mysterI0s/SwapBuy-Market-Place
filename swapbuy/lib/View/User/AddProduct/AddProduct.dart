import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Model/Address.dart';
import 'package:swapbuy/View/User/AddProduct/Controller/AddProductController.dart';
import 'package:swapbuy/Widgets/Button/ButtonCustom.dart';
import 'package:swapbuy/Widgets/Dropdown/DropdownCustom.dart';
import 'package:swapbuy/Widgets/TextInput/TextInputCustom.dart';

class Addproduct extends StatelessWidget {
  const Addproduct({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AddProductController>(
      builder:
          (context, controller, child) => Scaffold(
            resizeToAvoidBottomInset: false,
            body: ListView(
              padding: EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ButtonCustom(
                      onTap: () {
                        controller.PickImage();
                      },
                      fullWidth: false,
                      fullheight: false,
                      height: 150,
                      width: 150,
                      color: Color(0x0D000000),
                      borderradius: 15,
                      bordercolor: Color(0x1A000000),
                      bordersize: .5,
                      child:
                          controller.productpicture == null
                              ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: 50,
                                    color: Color(0x80000000),
                                  ),
                                  Gap(10),
                                  Text(
                                    "Add Picture",
                                    style: TextStyles.paraghraph.copyWith(
                                      color: Color(0x80000000),
                                    ),
                                  ),
                                ],
                              )
                              : ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(
                                  fit: BoxFit.fill,
                                  File(controller.productpicture!.path),
                                ),
                              ),
                    ),
                    Gap(20),
                    ButtonCustom(
                      onTap: () {
                        controller.PickVideo();
                      },
                      fullWidth: false,
                      fullheight: false,
                      height: 150,
                      width: 150,
                      borderradius: 15,
                      bordercolor: Color(0x1A000000),
                      bordersize: .5,
                      color: Color(0x0D000000),
                      child:
                          controller.videofile == null
                              ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: 50,
                                    color: Color(0x80000000),
                                  ),
                                  Gap(10),

                                  Text(
                                    "Add Video",
                                    style: TextStyles.paraghraph.copyWith(
                                      color: Color(0x80000000),
                                    ),
                                  ),
                                ],
                              )
                              : controller.thumbnailPath != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(
                                  File(controller.thumbnailPath!),
                                  fit: BoxFit.cover,
                                  width: 150,
                                  height: 150,
                                ),
                              )
                              : Text("Loading ..."),
                    ),
                  ],
                ),
                Gap(21),

                TextInputCustom(
                  hint: "Product name",
                  fillcolor: Color(0xff000000),
                  bordercolor: Color(0x1A000000),
                  controller: controller.productname,
                ),
                Gap(15),
                TextInputCustom(
                  hint: "Description",
                  fillcolor: Color(0xff000000),
                  bordercolor: Color(0x1A000000),
                  controller: controller.productdescription,
                  line: 3,
                ),
                Gap(15),

                DropdownCustom<Address>(
                  hint: "Address",

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
                Gap(15),

                DropdownCustom(
                  value: controller.condition,
                  hint: "Condition",
                  fillcolor: Color(0xff000000),
                  bordercolor: Color(0x1A000000),
                  items:
                      controller.conditionlist
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
                    controller.Selectcondition(p0!);
                  },
                ),
                Gap(15),

                DropdownCustom(
                  value: controller.status,
                  hint: "Status",
                  fillcolor: Color(0xff000000),
                  bordercolor: Color(0x1A000000),
                  items:
                      controller.statuslist
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
                    controller.Selectstatus(p0!);
                  },
                ),
                Gap(10),
                Divider(
                  color: AppColors.grey200,
                  endIndent: 30,
                  indent: 30,
                  thickness: .5,
                ),
                Gap(10),

                TextInputCustom(
                  controller: controller.productprice,
                  hint: "Price",
                  fillcolor: Color(0xff000000),
                  bordercolor: Color(0x1A000000),
                  suffix: Icon(
                    Icons.monetization_on_outlined,
                    color: Color.fromARGB(56, 0, 0, 0),
                  ),
                ),
                Gap(15),
                TextInputCustom(
                  controller: controller.productquantity,

                  hint: "Quantity",
                  fillcolor: Color(0xff000000),
                  bordercolor: Color(0x1A000000),
                ),
                Gap(15),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 27),
                  child: ButtonCustom(
                    onTap: () async {
                      // if (controller.keyform.currentState!.validate()) {
                      EasyLoading.show();
                      try {
                        final res = await controller.AddProduct(context);
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
                      // }
                    },
                    title: "Confirm",
                    color: AppColors.thirdy,
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
