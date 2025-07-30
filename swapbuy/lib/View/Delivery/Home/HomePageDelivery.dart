import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Services/CustomDialog.dart';
import 'package:swapbuy/Services/Routes.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';
import 'package:swapbuy/View/Auth/Login/Controller/LoginPageController.dart';
import 'package:swapbuy/View/Auth/Login/LoginPage.dart';
import 'package:swapbuy/View/Delivery/Home/Controller/HomePageDeliveryController.dart';
import 'package:swapbuy/View/Delivery/Home/AvailableOrdersScreen.dart';
import 'package:swapbuy/View/Delivery/Home/MyOrdersScreen.dart';
import 'package:swapbuy/View/Delivery/Home/DeliveredOrdersScreen.dart';
import 'package:swapbuy/View/Delivery/Profile/Controller/ProfileDeliveryController.dart';
import 'package:swapbuy/View/Delivery/Profile/ProfileDelivery.dart';

class HomePageDelivery extends StatefulWidget {
  const HomePageDelivery({super.key});

  @override
  State<HomePageDelivery> createState() => _HomePageDeliveryState();
}

class _HomePageDeliveryState extends State<HomePageDelivery>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final controller = context.read<HomePageDeliveryController>();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: controller.currentTab,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        controller.setTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomePageDeliveryController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.basic,
        elevation: 0,
        title: Text(
          "Available Orders",
          style: TextStyles.paraghraph.copyWith(
            fontSize: 24.sp,
            color: AppColors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              CustomRoute.RouteTo(
                context,
                ChangeNotifierProvider(
                  create:
                      (context) =>
                          ProfileDeliveryController()
                            ..CITIES(context)
                            ..PROFILEDelivery(context),
                  builder: (context, child) => ProfileDelivery(),
                ),
              );
            },
            icon: Icon(Icons.person_outline, color: AppColors.black, size: 24),
          ),
          IconButton(
            onPressed: () {
              Provider.of<ServicesProvider>(context, listen: false).logout();
              CustomRoute.RouteAndRemoveUntilTo(
                context,
                ChangeNotifierProvider(
                  create: (context) => Loginpagecontroller(),
                  builder: (context, child) => Loginpage(),
                ),
              );
              CustomDialog.DialogSuccess(context, title: "Logout Successfuly");
            },
            icon: Icon(Icons.logout, color: AppColors.black, size: 24),
          ),
        ],
      ),
      body: Column(
        children: [
          Gap(13),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: List.generate(3, (index) {
                final labels = ['Available', 'My Orders', 'Delivered'];
                final isSelected = controller.currentTab == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _tabController.animateTo(index);
                      context.read<HomePageDeliveryController>().setTab(index);
                    },
                    child: Container(
                      height: 40.h,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.thirdy : AppColors.secondery,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        labels[index],
                        style: TextStyle(
                          color: isSelected ? AppColors.basic : AppColors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Gap(20),
          Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: const [
                AvailableOrdersScreen(),
                MyOrdersScreen(),
                DeliveredOrdersScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
