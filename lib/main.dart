import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sss_retail/constants/app_colors.dart';
import 'package:sss_retail/constants/routes.dart';
import 'package:sss_retail/providers/auth_provider.dart';
import 'package:sss_retail/providers/item_provider.dart';
import 'package:sss_retail/providers/order_provider.dart';
import 'package:sss_retail/providers/user_provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return ScreenUtilInit(
      designSize: const Size(360, 900),
      builder: (context, _) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1)),
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (BuildContext context) => Auth(),
              ),
              ChangeNotifierProvider(
                create: (BuildContext context) => UserProvider(),
              ),
              ChangeNotifierProvider(
                create: (BuildContext context) => OrderProvider(),
              ),
              ChangeNotifierProvider(
                create: (BuildContext context) => ItemProvider(),
              ),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              initialRoute: '/',
              navigatorKey: navigatorKey,
              routes: approutes,
              theme: AppThemes.normalTheme,
            ),
          ),
        );
      },
    );
  }
}
