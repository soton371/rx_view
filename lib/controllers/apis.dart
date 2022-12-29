import 'dart:convert';
import 'dart:io';
import 'package:rx_view/views/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rx_view/controllers/check_update_con/check_update_con.dart';
import 'package:rx_view/controllers/drawer_con/my_new_drawer_con.dart';
import 'package:rx_view/controllers/login_con.dart';
import 'package:rx_view/controllers/my_device_info/my_device_info.dart';
import 'package:rx_view/models/my_new_drawer_mod/my_new_drawer_mod.dart';
import 'package:rx_view/views/prescription/new_rx_view.dart';
import 'package:rx_view/views/setting/setting_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../commons/Constant.dart';

final CheckUpdateController _checkUpdateController = Get.put(CheckUpdateController());
final MyDeviceInfoController _myDeviceInfoController = Get.put(MyDeviceInfoController());
final MyNewDrawerCon _myNewDrawerCon = Get.put(MyNewDrawerCon());

Future doLogIn(BuildContext context,String email,String password) async{
  final LoginController _loginController = Get.put(LoginController());
  String osVersion = '';
  String deviceModel = '';
  if(Platform.isIOS){
    osVersion ='systemVersion: ${_myDeviceInfoController.deviceDataInfo['systemVersion'].toString()}, release:: ${_myDeviceInfoController.deviceDataInfo['utsname.release:'].toString()}';
    deviceModel = 'model: ${_myDeviceInfoController.deviceDataInfo['model'].toString()}, localizedModel: ${_myDeviceInfoController.deviceDataInfo['localizedModel'].toString()}, nodename: ${_myDeviceInfoController.deviceDataInfo['utsname.nodename:'].toString()}, machine: ${_myDeviceInfoController.deviceDataInfo['utsname.machine:'].toString()}';
  }else{
    osVersion = 'api lvl: ${_myDeviceInfoController.deviceDataInfo['version.sdkInt'].toString()}, android version: ${_myDeviceInfoController.deviceDataInfo['version.release'].toString()}';
    deviceModel = 'brand: ${_myDeviceInfoController.deviceDataInfo['brand'].toString()}, model: ${_myDeviceInfoController.deviceDataInfo['model'].toString()}, manufacture: ${_myDeviceInfoController.deviceDataInfo['manufacturer'].toString()}';
  }
  try{
    var url = Uri.parse(AppConstant.BASE_URL_MS_LOGIN);
    var response = await http.post(url,body: {
      'email':email.removeAllWhitespace,
      'password':password.removeAllWhitespace,
      'fcm_reg_id': 'fcm',
      'appVersionCode': _checkUpdateController.appLocalVersion.toString(),
      'osVersion': osVersion,
      'deviceModel':deviceModel
    });

    // print('object payload: $osVersion \n $deviceModel');
    var success = json.decode(response.body)['success'];

    if(success){

      String SAUSERS_ID = json.decode(response.body)['details']['SAUSERS_ID'];
      String username = json.decode(response.body)['details']['USRS_FNAME'];

      //for temp local save data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saUsersId', SAUSERS_ID);
      await prefs.setString('userName', username);

      //start for initial page route
      try{
        var url = Uri.parse(AppConstant().appMenu);

        var response = await http.post(url,
            headers: {'Content-Type': 'application/json'},

            body: json.encode({
              "performBy": SAUSERS_ID,
              "udPerformBy": SAUSERS_ID,
              "userRole": "",
              "group": "",
              "appId": 2
            }));
print("call from apiss...............");
        var body = json.decode(response.body);
        switch (body['statusCode']) {
          case 200:
            {
             List<MyNewDrawerModel> menuList = myNewDrawerModelFromJson(json.encode(body['listResponse']));

             for(var e in menuList){
               if(e.menuUId == "SM017"){
                 print('object 1');
                 switch(e.menuUId){
                   case 'M009':{
                     // Get.off(const NewHomeScreen());
                     _myNewDrawerCon.getAppMenu();
                   }
                   break;
                   case 'M010':{
                     // Get.off(const ReportScreen());
                     _myNewDrawerCon.getAppMenu();
                   }
                   break;
                   case 'M012':{
                     Get.off(const SettingScreen());
                     _myNewDrawerCon.getAppMenu();
                   }
                   break;
                 }
               }
               else{
                 if(e.subMenuList != null){

                   for(var subE in e.subMenuList!){

                     if(subE.udSubMenuId== "SM017"){
                       switch(subE.udSubMenuId){
                         case 'SM016':{
                           // Get.off(const NewPrescriptionScreen());
                           _myNewDrawerCon.getAppMenu();
                         }
                         break;
                         case 'SM017':{
                           Get.off(NewRxViewScreen());
                           _myNewDrawerCon.hasRxViewMenuId.value = true;
                           _myNewDrawerCon.getAppMenu();
                         }
                         break;
                       }
                     }
                     else{
                       // Get.off(const NewHomeScreen());
                       Get.off(NewRxViewScreen());
                       _myNewDrawerCon.getAppMenu();
                     }
                   }
                 }
                /* else{
                   Get.off(const NewHomeScreen());
                 }*/
               }
             }
            }
            break;
          default:
            {
              Get.snackbar('Something wrong', 'Please try again');
              Navigator.pop(context);
              print('object something wrong for initial page route 1 inside doLogIn');
            }
        }
      }catch(e){
        print('object something wrong for initial page route 2 inside doLogIn: $e');
        Navigator.pop(context);
        Get.snackbar('Something wrong', 'Please try again');
        Get.off(const LogInScreen());
      }
      //end for initial page route
      _loginController.getLoginInfo();
    }else{
      Navigator.pop(context);
      Get.snackbar('Warning', 'Invalid Email or Password');
    }
  }catch(e){
    Get.snackbar('Something wrong', 'Please try again');
    Navigator.pop(context);
  }

}


