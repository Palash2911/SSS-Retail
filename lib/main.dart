import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sss_retail/constants/app_colors.dart';
import 'package:sss_retail/constants/routes.dart';

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
      splitScreenMode: true,
      builder: (context, _) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1)),
          child: MultiProvider(
            providers: [],
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
