import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';
import 'package:swapbuy/Services/NetworkClient.dart';
import 'package:swapbuy/View/Splash/Controller/SplashController.dart';
import 'package:swapbuy/View/Splash/splash.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final servicesProvider = ServicesProvider();
  await servicesProvider.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ServicesProvider>.value(value: servicesProvider),
        Provider<NetworkClient>(
          create: (context) => NetworkClient(http.Client(), servicesProvider),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,

      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Swapbuy',
          theme: ThemeData(
            fontFamily: 'Inter',
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.basic,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                backgroundColor: WidgetStateColor.resolveWith(
                  (states) => AppColors.primary,
                ),
              ),
            ),
            iconTheme: IconThemeData(color: AppColors.active),
            appBarTheme: AppBarTheme(backgroundColor: AppColors.primary),
            textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'Inter',
              bodyColor: AppColors.primary,
              displayColor: AppColors.primary,
            ),
            useMaterial3: false,
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              secondary: AppColors.secondery,
            ).copyWith(surface: AppColors.secondery),
          ),
          locale: Locale('en'),
          home: ChangeNotifierProvider(
            create: (context) => SplashController()..whenIslogin(context),
            builder: (context, child) => Splash(),
          ),
          builder: (context, child) {
            EasyLoading.instance
              ..displayDuration = const Duration(seconds: 3)
              ..indicatorType = EasyLoadingIndicatorType.fadingCircle
              ..loadingStyle = EasyLoadingStyle.custom
              ..indicatorSize = 45.0
              ..radius = 15.0
              ..maskType = EasyLoadingMaskType.black
              ..progressColor = AppColors.active
              ..backgroundColor = AppColors.basic
              ..indicatorColor = AppColors.active
              ..textColor = AppColors.black
              ..maskColor = Colors.black
              ..userInteractions = false
              ..animationStyle = EasyLoadingAnimationStyle.opacity
              ..dismissOnTap = false;
            return FlutterEasyLoading(child: child);
          },
        );
      },
    );
  }
}
