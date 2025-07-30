import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/View/User/Home/Controller/HomePageUserController.dart';
import 'package:swapbuy/Widgets/Dropdown/DropdownCustom.dart';
import 'package:swapbuy/Widgets/TextInput/TextInputCustom.dart'; // تأكد من المسار الصحيح

class FilterBottomSheet extends StatefulWidget {
  late final HomePageUserController _controller; // تغيير النوع هنا
  FilterBottomSheet(this._controller);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  // double? _tempMinPrice;
  // double? _tempMaxPrice;
  // String? _tempSelectedStatus;
  // String? _tempSelectedCity;
  // String? _tempSelectedOrderBy;

  @override
  void initState() {
    super.initState();

    // _tempMinPrice = widget._controller.minPrice;
    // _tempMaxPrice = widget._controller.maxPrice;
    // _tempSelectedStatus = widget._controller.selectedStatus;
    // _tempSelectedCity = widget._controller.selectedCity;
    // _tempSelectedOrderBy = widget._controller.selectedOrderBy;

    // _minPriceController.text = _tempMinPrice?.toString() ?? '';
    // _maxPriceController.text = _tempMaxPrice?.toString() ?? '';
  }

  @override
  void dispose() {
    // _minPriceController.dispose();
    // _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Products',
              style: TextStyles.title.copyWith(color: AppColors.black),
            ),

            Gap(10),
            Row(
              children: [
                Expanded(
                  child: TextInputCustom(
                    controller: widget._controller.minPriceController,
                    hint: "Min Price",
                    fillcolor: Color(0xff000000),
                    bordercolor: Color(0x1A000000),
                  ),
                ),
                Gap(10),
                Expanded(
                  child: TextInputCustom(
                    controller: widget._controller.maxPriceController,
                    hint: "Max Price",
                    fillcolor: Color(0xff000000),
                    bordercolor: Color(0x1A000000),
                  ),
                ),
              ],
            ),
            Gap(20),

            DropdownCustom(
              value: widget._controller.selectedCondition,
              hint: "Condition",
              fillcolor: Color(0xff000000),
              bordercolor: Color(0x1A000000),
              items:
                  widget._controller.availableCondition
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
                widget._controller.SelectCondition(p0!);
              },
            ),
            Gap(20),

            DropdownCustom(
              value: widget._controller.selectedStatus,
              hint: "Status",
              fillcolor: Color(0xff000000),
              bordercolor: Color(0x1A000000),
              items:
                  widget._controller.availableStatuses
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
                widget._controller.SelectStatus(p0!);
              },
            ),
            Gap(20),

            DropdownCustom(
              value: widget._controller.selectedCity,
              hint: "City",
              fillcolor: Color(0xff000000),
              bordercolor: Color(0x1A000000),
              items:
                  widget._controller.availableCities
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
                widget._controller.SelectCity(p0!);
              },
            ),
            Gap(20),

            DropdownCustom(
              value: widget._controller.selectedOrderBy,
              hint: "Order By",
              fillcolor: Color(0xff000000),
              bordercolor: Color(0x1A000000),
              items:
                  widget._controller.orderByOptions
                      .map(
                        (e) => DropdownMenuItem(
                          value: e['value'],
                          child: Text(
                            e['display'].toString(),
                            style: TextStyles.paraghraph.copyWith(
                              color: Color(0xff000000),
                            ),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (p0) {
                widget._controller.SelectOrderBy(p0!);
              },
            ),
            Gap(20),

            // Apply and Reset Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget._controller.applyFilters(
                        context: context, // تمرير الـ context هنا
                      );
                      Navigator.pop(context); // إغلاق الـ BottomSheet
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.black,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      'Apply Filters',
                      style: TextStyles.pramed.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget._controller.resetAllFilters(context);

                      // تطبيق الفلاتر بعد إعادة التعيين

                      Navigator.pop(context); // إغلاق الـ BottomSheet
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(color: AppColors.black),
                    ),
                    child: Text(
                      'Reset Filters',
                      style: TextStyles.pramed.copyWith(color: AppColors.black),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
