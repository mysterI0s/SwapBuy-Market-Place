import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/View/User/Navigation/Controller/NavigationPageUserController.dart';

class NavigationPageUser extends StatelessWidget {
  const NavigationPageUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationPageUserController>(
      builder:
          (context, controller, child) => SafeArea(
            child: Scaffold(
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: controller.index,
                selectedItemColor: AppColors.thirdy,
                unselectedItemColor: AppColors.basic,

                items: [
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/SVG/more_vert.svg',
                      color: AppColors.thirdy,
                    ),

                    label: "",
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/SVG/Box.svg',
                      color: AppColors.thirdy,
                    ),
                    label: "",
                  ),
                  BottomNavigationBarItem(
                    label: "Add Product",

                    icon: Icon(CupertinoIcons.add, color: AppColors.thirdy),
                  ),

                  BottomNavigationBarItem(
                    label: "",
                    icon: SvgPicture.asset(
                      'assets/SVG/Map pin.svg',
                      color: AppColors.thirdy,
                    ),
                  ),
                  BottomNavigationBarItem(
                    label: "",
                    icon: SvgPicture.asset(
                      'assets/SVG/Shop.svg',
                      color: AppColors.thirdy,
                    ),
                  ),
                ],

                backgroundColor: AppColors.secondery,
                elevation: 0,
                useLegacyColorScheme: true,
                onTap: (value) => controller.ChangeIndex(value),
              ),
              body: controller.pages[controller.index],
            ),
          ),
    );
  }
}
