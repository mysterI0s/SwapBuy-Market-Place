import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';

import 'package:swapbuy/View/User/AllAddress/Controller/AllAddressController.dart';

class AllAddress extends StatelessWidget {
  const AllAddress({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AllAddressController>(
      builder:
          (context, controller, child) => Scaffold(
            appBar: AppBar(title: Text("All Address"), centerTitle: true),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                controller.DialogAddAddress(context);
              },
              child: Icon(Icons.add),
            ),
            body: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: controller.adresses.length,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Address #${controller.adresses[index].id}",
                              style: TextStyles.title.copyWith(
                                color: AppColors.black,
                              ),
                            ),
                            Text(
                              "${controller.adresses[index].buildingNumber!}${controller.adresses[index].buildingNumber != "" ? ',' : ""}${controller.adresses[index].street!}${controller.adresses[index].street != "" ? ',' : ""}${controller.adresses[index].neighborhood!}${controller.adresses[index].neighborhood != "" ? ',' : ""}${controller.adresses[index].city}${controller.adresses[index].city != "" ? ',' : ""}${controller.adresses[index].postalCode}${controller.adresses[index].postalCode != "" ? ',' : ""}${controller.adresses[index].country}",
                              style: TextStyles.pramed,
                            ),

                            Divider(color: AppColors.black),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    controller.DialogEditAddress(
                                      context,
                                      controller.adresses[index],
                                    );
                                  },
                                  child: Text("Edit", style: TextStyles.pramed),
                                ),
                                TextButton(
                                  onPressed: () {
                                    controller.DialogDeleteAddress(
                                      context,
                                      controller.adresses[index],
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
    );
  }
}
