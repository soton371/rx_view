import 'dart:convert';
import 'dart:io';
import 'package:rx_view/controllers/drawer_con/my_new_drawer_con.dart';
import 'package:rx_view/models/my_new_drawer_mod/my_new_drawer_mod.dart';
import 'package:rx_view/views/prescription/new_rx_view.dart';
import 'package:rx_view/views/setting/setting_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rx_view/commons/Constant.dart';
import 'package:http/http.dart' as http;
import 'package:rx_view/views/auth/login.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


class CheckUpdateController extends GetxController {
  // final AppPolicyController _appPolicyController = Get.put(AppPolicyController());
  final MyNewDrawerCon _myNewDrawerCon = Get.put(MyNewDrawerCon());

  Future<void> launchAppStore(String appStoreLink) async {
    debugPrint(appStoreLink);
    var uri = Uri.parse(appStoreLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch appStoreLink';
    }
  }

  var appLocalVersion = 1.obs;
  var needUpdate = true.obs;



  void checkUpdate(BuildContext context) async {

    try {
      final prefs = await SharedPreferences.getInstance();
      String saUsersId = prefs.getString('saUsersId') ?? '';
      int appType = Platform.isIOS ? 2 : 1;

      var url = Uri.parse(
          "${AppConstant().appData}?userId=$saUsersId&appType=$appType");
      var response = await http.post(url);
      var body = json.decode(response.body);
      print("body $body");
      switch (body['statusCode']) {
        case 200:
          {
            int appServerVersion = body['objResponse']['appServerVersion'];
            int userActiveFlag = body['objResponse']['userActiveFlag'];

            PackageInfo packageInfo = await PackageInfo.fromPlatform();
            String buildNumber = packageInfo.buildNumber;
            appLocalVersion.value = int.parse(buildNumber);

            // print(
            //     'object appLocalVersion: $appLocalVersion & appServerVersion: $appServerVersion');

            if (userActiveFlag == 0) {
              showDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                        title: const Text("Account Locked!!"),
                        content: const Text(
                            'Your Account is Locked. Please Contact With Your Service Provider'),
                        actions: [
                          TextButton(
                              onPressed: () => Get.off(const LogInScreen()),
                              child: const Text('Ok'))
                        ],
                      ));

              needUpdate.value = true;
            } else if (appLocalVersion < appServerVersion) {
              showDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                        title: const Text("New version available!"),
                        content: const Text(
                            'Highly recommended to update App for better experience.'),
                        actions: [
                          TextButton(
                              onPressed: () {

                                if(Platform.isIOS){
                                  print('object is ios: ');
                                  launchAppStore(
                                      'https://apps.apple.com/us/app/medical-survey-report/id6443634739');
                                }else{
                                  print('object is android: ');
                                  launchAppStore(
                                      'https://play.google.com/store/apps/details?id=net.ati.rx_view.rx_view');
                                }

                              },
                              child: const Text('Update Now'))
                        ],
                      ));

              needUpdate.value = true;
            } else if (appLocalVersion > appServerVersion) {
              showDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                        title: const Text("Maintenance Break!!"),
                        content: const Text(
                            'We working on server for new version. please wait..'),
                        actions: [
                          TextButton(
                              onPressed: () => Get.off(const LogInScreen()),
                              child: const Text('Ok'))
                        ],
                      ));

              needUpdate.value = true;
            }else {
              needUpdate.value = false;
              //start for initial page route
              if(saUsersId.isEmpty){
                Get.off(const LogInScreen());
              }else{

                try{
                  var url = Uri.parse(AppConstant().appMenu);
                  var response = await http.post(url,
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode({
                        "performBy": saUsersId,
                        "udPerformBy": saUsersId,
                        "userRole": "",
                        "group": "",
                        "appId": 2
                      }));
                  print("call from check update con...............");
                  var body = json.decode(response.body);
                  switch (body['statusCode']) {
                    case 200:{
                      List<MyNewDrawerModel> menuList = myNewDrawerModelFromJson(json.encode(body['listResponse']));
                      String defaultMenuId = '';
                      for(var e in menuList){
                        if(e.menuUId == "SM017"){
                          defaultMenuId = e.menuUId ?? "";
                          break;
                        }else{
                          if(e.subMenuList != null){
                            for(var subE in e.subMenuList!){
                              if(subE.udSubMenuId== "SM017"){
                                defaultMenuId = subE.udSubMenuId ?? "";
                                break;
                              }
                            }
                          }
                        }
                        /*if(e.isWelcomePage==1){
                          defaultMenuId = e.menuUId ?? "";
                          break;
                        }else{
                          if(e.subMenuList != null){
                            for(var subE in e.subMenuList!){
                              if(subE.isWelcomePage==1){
                                defaultMenuId = subE.udSubMenuId ?? "";
                                break;
                              }
                            }
                          }
                        }*/
                      }
                      switch(defaultMenuId){
                        case 'M009':
                          // Get.off(const NewHomeScreen());
                          _myNewDrawerCon.getAppMenu();
                          break;
                        case 'M010':
                          // Get.off(const ReportScreen());
                          _myNewDrawerCon.getAppMenu();
                          break;
                        case 'M012':
                          Get.off(const SettingScreen());
                          _myNewDrawerCon.getAppMenu();
                          break;
                        case 'SM016':
                          // Get.off(const NewPrescriptionScreen());
                          _myNewDrawerCon.getAppMenu();
                          break;
                        case 'SM017':
                          Get.off(NewRxViewScreen());
                          _myNewDrawerCon.hasRxViewMenuId.value = true;
                              _myNewDrawerCon.getAppMenu();
                          break;
                        default:
                          Get.off(NewRxViewScreen());
                          // Get.off(const NewHomeScreen());
                          _myNewDrawerCon.getAppMenu();
                          break;
                      }
                    }
                  }
                }catch(e){
                  print('object check update con where initial page route inside getAppMenu');
                  Get.off(const LogInScreen());
                }

              }
              //end for initial page route
            }
            print('object needUpdate: $needUpdate');
          }
          break;
        default:
          {
            Get.off(const LogInScreen());
            print('object something wrong inside checkUpdate');
          }
      }
    } catch (e) {
      Get.off(const LogInScreen());
      print('something wrong needUpdate');
    }
    print('object needUpdate: $needUpdate');
  }
}

