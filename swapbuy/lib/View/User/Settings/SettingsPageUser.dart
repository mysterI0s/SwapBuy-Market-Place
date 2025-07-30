import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Constant/url.dart';
import 'package:swapbuy/Services/CustomDialog.dart';
import 'package:swapbuy/Services/NetworkClient.dart';
import 'package:swapbuy/Services/Routes.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';
import 'package:swapbuy/View/Auth/Login/Controller/LoginPageController.dart';
import 'package:swapbuy/View/Auth/Login/LoginPage.dart';
import 'package:swapbuy/View/User/AcceptanceCase/AcceptanceCase.dart';
import 'package:swapbuy/View/User/AcceptanceCase/Controller/AcceptanceCaseController.dart';
import 'package:swapbuy/View/User/IncomingRequests/Controller/IncomingRequestsController.dart';
import 'package:swapbuy/View/User/IncomingRequests/IncomingRequests.dart';
import 'package:swapbuy/View/User/Profile/Controller/ProfileUserController.dart';
import 'package:swapbuy/View/User/Profile/ProfileUser.dart';
import 'package:swapbuy/View/User/Wishlist/Controller/WishlistController.dart';
import 'package:swapbuy/View/User/Wishlist/Wishlist.dart';
import 'package:swapbuy/Widgets/Button/ButtonCustom.dart';
import 'package:swapbuy/Widgets/TextInput/TextInputCustom.dart';
import 'package:swapbuy/View/Chat/ChatsScreen.dart';
import 'package:swapbuy/View/User/Reviews/ReviewsScreen.dart';

class SettingsPageUser extends StatelessWidget {
  const SettingsPageUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          Gap(20),
          Center(
            child: Text(
              "Settings",
              style: TextStyles.header.copyWith(color: AppColors.black),
            ),
          ),
          Gap(20),

          ButtonCustom(
            borderradius: 15,
            fullheight: true,
            bordersize: 0.5,
            bordercolor: Color(0x1A000000),
            color: const Color(0x0d000000),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
              child: Row(
                children: [
                  SvgPicture.asset(
                    "assets/SVG/person.svg",
                    color: Color(0xff1D1B20),
                  ),
                  Gap(7),
                  Text(
                    "Personal profile",
                    style: TextStyles.paraghraph.copyWith(
                      color: Color(0xff1D1B20),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              CustomRoute.RouteTo(
                context,
                ChangeNotifierProvider(
                  create:
                      (context) => ProfileUserController()..PROFILE(context),
                  builder: (context, child) => Profileuser(),
                ),
              );
            },
          ),
          Gap(18),
          // ButtonCustom(
          //   borderradius: 15,
          //   fullheight: true,
          //   bordersize: 0.5,
          //   bordercolor: Color(0x1A000000),
          //   color: const Color(0x0d000000),
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
          //     child: Row(
          //       children: [
          //         Icon(Icons.pin_drop_outlined, color: Color(0xff1D1B20)),
          //         Gap(7),
          //         Text(
          //           "Address",
          //           style: TextStyles.paraghraph.copyWith(
          //             color: Color(0xff1D1B20),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          //   onTap: () {
          //     CustomRoute.RouteTo(
          //       context,
          //       ChangeNotifierProvider(
          //         create:
          //             (context) =>
          //                 AllAddressController()
          //                   ..AllAddress(context)
          //                   ..CITIES(context),
          //         builder: (context, child) => AllAddress(),
          //       ),
          //     );
          //   },
          // ),
          // Gap(18),
          ButtonCustom(
            borderradius: 15,
            fullheight: true,
            bordersize: 0.5,
            bordercolor: Color(0x1A000000),
            color: const Color(0x0d000000),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
              child: Row(
                children: [
                  Icon(
                    Icons.monetization_on_outlined,
                    color: Color(0xff1D1B20),
                  ),
                  Gap(7),
                  Text(
                    "Wallet",
                    style: TextStyles.paraghraph.copyWith(
                      color: Color(0xff1D1B20),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () async {
              EasyLoading.show();
              final client = Provider.of<NetworkClient>(context, listen: false);
              try {
                var response = await client.request(
                  path: AppApi.WalletBalance(
                    Provider.of<ServicesProvider>(
                      context,
                      listen: false,
                    ).userid,
                  ),
                  requestType: RequestType.GET,
                );

                log(response.statusCode.toString());
                log(response.body);
                var json = jsonDecode(response.body);

                if (response.statusCode == 200) {
                  EasyLoading.dismiss();
                  CustomDialog.DialogSuccess(
                    context,
                    title: "Wallet balance is: ${json['balance']}\$",
                  );
                  // var productjosn = json['results'];
                  // productjosn.forEach((v) {
                  //   products.add(new Product.fromJson(v));
                  // });
                } else if (response.statusCode == 404) {
                  EasyLoading.dismiss();

                  if (json.containsKey('error')) {
                    CustomDialog.DialogError(context, title: json['error']);
                  }
                } else if (response.statusCode == 401) {
                  EasyLoading.dismiss();

                  if (json.containsKey('error')) {
                    CustomDialog.DialogError(context, title: json['error']);
                  }
                } else {
                  EasyLoading.dismiss();

                  CustomDialog.DialogError(context, title: json['error']);
                }
              } catch (e) {
                EasyLoading.dismiss();

                log(e.toString());
              }
            },
          ),
          Gap(18),
          ButtonCustom(
            borderradius: 15,
            fullheight: true,
            bordersize: 0.5,
            bordercolor: Color(0x1A000000),
            color: const Color(0x0d000000),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
              child: Row(
                children: [
                  SvgPicture.asset(
                    "assets/SVG/Chat.svg",
                    color: Color(0xff1D1B20),
                  ),
                  Gap(7),
                  Text(
                    "Chat",
                    style: TextStyles.paraghraph.copyWith(
                      color: Color(0xff1D1B20),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatsScreen()),
              );
            },
          ),
          Gap(18),
          ButtonCustom(
            borderradius: 15,
            fullheight: true,
            bordersize: 0.5,
            bordercolor: Color(0x1A000000),
            color: const Color(0x0d000000),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
              child: Row(
                children: [
                  SvgPicture.asset(
                    "assets/SVG/Bookmark_light.svg",
                    color: Color(0xff1D1B20),
                  ),
                  Gap(7),
                  Text(
                    "Wish list",
                    style: TextStyles.paraghraph.copyWith(
                      color: Color(0xff1D1B20),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              CustomRoute.RouteTo(
                context,
                ChangeNotifierProvider(
                  create:
                      (context) =>
                          WishlistController()..ProductsWishList(context),
                  builder: (context, child) => Wishlist(),
                ),
              );
            },
          ),
          Gap(18),
          ButtonCustom(
            borderradius: 15,
            fullheight: true,
            bordersize: 0.5,
            bordercolor: Color(0x1A000000),
            color: const Color(0x0d000000),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
              child: Row(
                children: [
                  SvgPicture.asset(
                    "assets/SVG/check_box.svg",
                    color: Color(0xff1D1B20),
                  ),
                  Gap(7),
                  Text(
                    "Acceptance case",
                    style: TextStyles.paraghraph.copyWith(
                      color: Color(0xff1D1B20),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              CustomRoute.RouteTo(
                context,
                ChangeNotifierProvider(
                  create:
                      (context) =>
                          AcceptanceCaseController()
                            ..ListSentSwap(context)
                            ..ListSentBuy(context),
                  builder: (context, child) => AcceptanceCase(),
                ),
              );
            },
          ),
          Gap(18),
          ButtonCustom(
            borderradius: 15,
            fullheight: true,
            bordersize: 0.5,
            bordercolor: Color(0x1A000000),
            color: const Color(0x0d000000),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
              child: Row(
                children: [
                  Icon(Icons.inbox, color: Color(0xff1D1B20)),
                  Gap(7),
                  Text(
                    "Incoming Requests",
                    style: TextStyles.paraghraph.copyWith(
                      color: Color(0xff1D1B20),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              CustomRoute.RouteTo(
                context,
                ChangeNotifierProvider(
                  create:
                      (context) =>
                          IncomingRequestsController()
                            ..ListReceivedSwap(context)
                            ..ListReceivedBuy(context),
                  builder: (context, child) => IncomingRequests(),
                ),
              );
            },
          ),
          Gap(18),
          ButtonCustom(
            borderradius: 15,
            fullheight: true,
            bordersize: 0.5,
            bordercolor: Color(0x1A000000),
            color: const Color(0x0d000000),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
              child: Row(
                children: [
                  SvgPicture.asset(
                    "assets/SVG/Star.svg",
                    color: Color(0xff1D1B20),
                  ),
                  Gap(7),
                  Text(
                    "Reviews",
                    style: TextStyles.paraghraph.copyWith(
                      color: Color(0xff1D1B20),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReviewsScreen()),
              );
            },
          ),
          Gap(18),
          ButtonCustom(
            borderradius: 15,
            fullheight: true,
            bordersize: 0.5,
            bordercolor: Color(0x1A000000),
            color: const Color(0x0d000000),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
              child: Row(
                children: [
                  Icon(Icons.report_gmailerrorred, color: Color(0xff1D1B20)),
                  Gap(7),
                  Text(
                    "Complaint",
                    style: TextStyles.paraghraph.copyWith(
                      color: Color(0xff1D1B20),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  TextEditingController message = TextEditingController();
                  TextEditingController subject = TextEditingController();
                  return AlertDialog(
                    title: Text(
                      "Send Colmplint",
                      style: TextStyles.title.copyWith(color: AppColors.black),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextInputCustom(
                          hint: "Subject",
                          controller: subject,
                          fillcolor: Color(0xff000000),
                          bordercolor: Color(0x1A000000),
                        ),
                        Gap(10),
                        TextInputCustom(
                          hint: "Message",
                          controller: message,
                          fillcolor: Color(0xff000000),
                          bordercolor: Color(0x1A000000),
                          line: 3,
                        ),
                      ],
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ButtonCustom(
                          onTap: () async {
                            EasyLoading.show();
                            final client = Provider.of<NetworkClient>(
                              context,
                              listen: false,
                            );
                            try {
                              var response = await client.request(
                                path: AppApi.SendComplint(
                                  Provider.of<ServicesProvider>(
                                    context,
                                    listen: false,
                                  ).userid,
                                ),
                                requestType: RequestType.POST,
                                body: jsonEncode({
                                  'subject': subject.text,
                                  'message': message.text,
                                }),
                              );

                              log(response.statusCode.toString());
                              log(response.body);
                              var json = jsonDecode(response.body);

                              if (response.statusCode == 201) {
                                EasyLoading.dismiss();
                                CustomRoute.RoutePop(context);

                                CustomDialog.DialogSuccess(
                                  context,
                                  title: json['message'],
                                );
                              } else if (response.statusCode == 404) {
                                EasyLoading.dismiss();

                                if (json.containsKey('error')) {
                                  CustomDialog.DialogError(
                                    context,
                                    title: json['error'],
                                  );
                                }
                              } else if (response.statusCode == 401) {
                                EasyLoading.dismiss();

                                if (json.containsKey('error')) {
                                  CustomDialog.DialogError(
                                    context,
                                    title: json['error'],
                                  );
                                }
                              } else {
                                EasyLoading.dismiss();

                                CustomDialog.DialogError(
                                  context,
                                  title: json['error'],
                                );
                              }
                            } catch (e) {
                              EasyLoading.dismiss();

                              log(e.toString());
                            }
                          },
                          title: "Send",
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          Gap(18),
          ButtonCustom(
            borderradius: 15,
            fullheight: true,
            bordersize: 0.5,
            bordercolor: Color(0x1A000000),
            color: const Color(0x0d000000),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
              child: Row(
                children: [
                  SvgPicture.asset(
                    "assets/SVG/Log out.svg",
                    color: Color(0xff1D1B20),
                  ),
                  Gap(7),
                  Text(
                    "Sign out",
                    style: TextStyles.paraghraph.copyWith(
                      color: Color(0xff1D1B20),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              CustomRoute.RouteAndRemoveUntilTo(
                context,
                ChangeNotifierProvider(
                  create: (context) => Loginpagecontroller(),
                  builder: (context, child) => Loginpage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
