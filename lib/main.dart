import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:rx_view/commons/Constant.dart';
import 'package:rx_view/controllers/app_policy/app_policy_con.dart';
import 'package:rx_view/controllers/check_update_con/check_update_con.dart';
import 'package:rx_view/controllers/setting/setting_con.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Rx Viewer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: AppConstant.primarySwatchColor,
      ),
      // home: const NewHomeScreen(),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AppPolicyController _appPolicyController = Get.put(AppPolicyController());
  final CheckUpdateController _checkUpdateController = Get.put(CheckUpdateController());
  final SettingController _settingController = Get.put(SettingController());

  @override
  void initState() {
    super.initState();
    _appPolicyController.getAppPolicy();
    _checkUpdateController.checkUpdate(context);
    _settingController.getTempSaveSetting();
    FlutterNativeSplash.remove();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppConstant.backgroundColor,
      child: Center(
        child: Image.asset('assets/images/splash.png',height: 120,),
      ),
    );
  }
}
