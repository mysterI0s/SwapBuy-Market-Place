import 'dart:convert';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Constant/url.dart';
import 'package:swapbuy/Model/ProductFull.dart';
import 'package:swapbuy/Services/CustomDialog.dart';
import 'package:swapbuy/Services/Failure.dart';
import 'package:swapbuy/Services/NetworkClient.dart';
import 'package:swapbuy/Services/Routes.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';
import 'package:swapbuy/Widgets/Button/ButtonCustom.dart';

class MyProductController with ChangeNotifier {
  List<ProductFull> products = [];
  String? next;
  bool isLoadingMore = false;
  bool isLoadingInitial = false;

  Future<void> RefreshData(BuildContext context) async {
    products.clear();
    next = null;

    MyProducts(context);
  }

  Future<Either<Failure, bool>> MyProducts(BuildContext context) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path:
            next ??
            AppApi.Products(
              Provider.of<ServicesProvider>(context, listen: false).userid,
            ),
        pageination: next != null,
        requestType: RequestType.GET,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        next = json["next"];
        for (var element in json['results']) {
          products.add(ProductFull.fromJson(element));
        }
        // var productjosn = json['results'];
        // productjosn.forEach((v) {
        //   products.add(new Product.fromJson(v));
        // });
        notifyListeners();
        log(products.length.toString());
        // CustomDialog.DialogSuccess(context, title: json['message']);
        return Right(true);
      } else if (response.statusCode == 404) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }

        return Right(false);
      } else if (response.statusCode == 401) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }

        return Right(false);
      } else {
        CustomDialog.DialogError(context, title: json['error']);
        return Right(false);
      }
    } catch (e) {
      log(e.toString());
      return Left(GlobalFailure());
    }
  }

  DialogDeleteProduct(BuildContext context, ProductFull product) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.basic,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Do you really want to Delete this Product ?",
                    style: TextStyles.title.copyWith(color: AppColors.black),
                    textAlign: TextAlign.center,
                  ),
                  Gap(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: ButtonCustom(
                          color: Color(0x80DE2427),
                          borderradius: 100,
                          bordercolor: Color(0xff700002),
                          bordersize: 1,
                          height: 40,
                          onTap: () async {
                            EasyLoading.show();
                            try {
                              final res = await DeleteProduct(
                                context,
                                product.product!.id!,
                              );
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
                          },
                          child: Text(
                            "Delete",
                            style: TextStyles.button.copyWith(
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                      Gap(5),
                      Expanded(
                        child: ButtonCustom(
                          borderradius: 100,
                          height: 40,
                          bordersize: 1,

                          bordercolor: AppColors.black,
                          color: AppColors.secondery,
                          onTap: () async {
                            CustomRoute.RoutePop(context);
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyles.button.copyWith(
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<Either<Failure, bool>> DeleteProduct(
    BuildContext context,
    int id,
  ) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.DeleteProduct(id),
        requestType: RequestType.DELETE,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        CustomDialog.DialogSuccess(context, title: json['message']);
        RefreshData(context);
        CustomRoute.RoutePop(context);
        return Right(true);
      } else if (response.statusCode == 400) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }
        return Right(false);
      } else if (response.statusCode == 401) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }

        return Right(false);
      } else {
        CustomDialog.DialogError(context, title: json['error']);
        return Right(false);
      }
    } catch (e) {
      log(e.toString());
      return Left(GlobalFailure());
    }
  }
}
