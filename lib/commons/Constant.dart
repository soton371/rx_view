import 'package:flutter/material.dart';

class AppConstant {
  ///all url
  // static const String BASE_URL_MS = "http://192.168.0.29:8088/dil_rmd_ws/api/"; // Local
   static const String BASE_URL_MS = "http://gpst.billingdil.com:8088/dil_rmd_ws/api/"; // Live

  static const String BASE_URL_MS_LOGIN = "http://gpst.billingdil.com/dil-rmd/api/appLogin"; // Live
  static const String imageUrl = "http://gpst.billingdil.com:8088/dil_rmd_ws/api/prescription/download-precription";

  String getSyncListUrl = '${BASE_URL_MS}sync/get-sync-list';
  String customerUrl = '${BASE_URL_MS}sync/customer';
  String getInsertSyncRecUrl = '${BASE_URL_MS}sync/insert-sync-rec';
  String rxInfoUrl = '${BASE_URL_MS}prescription/get-rx-info';
  String divisionUrl = '${BASE_URL_MS}sync/divisions';
  String districtUrl = '${BASE_URL_MS}sync/district';
  String insertDeviceInfoUrl = '${BASE_URL_MS}commons/insert-device-info';
  String verifyRxInfo = '${BASE_URL_MS}prescription/verify-rx-info';
  String appPolicy = '${BASE_URL_MS}policy/app-policy';
  String appData = '${BASE_URL_MS}policy/app-data/2';
  String appMenu = '${BASE_URL_MS}policy/app-menu/';
  String getUsersName = '${BASE_URL_MS}prescription/get-users-name';
  String getShareableUsers = '${BASE_URL_MS}prescription/get-shareable-users';
  String shareRx = '${BASE_URL_MS}prescription/share-rx';
  String updateRxImg = '${BASE_URL_MS}prescription/update-rx-img';
  String getRxHxCount = '${BASE_URL_MS}prescription/get-rx-hx-count';

  ///color
  static var backgroundColor = Colors.white;
  static var primarySwatchColor = Colors.indigo;
  static var disableTextColor = Colors.grey;
  static var enableTextColor = Colors.black;
  static var doneColor = Colors.green;
  static var ash300 = const Color(0xff62757f);
  static var ash200 = const Color(0xff90a4ae);
  static var ash100 = const Color(0xffc1d5e0);
  static var removeColor = Colors.red;
  static var shadowColor = Colors.black12;
  static var tealOne = const Color(0xff009faf);
  static var tealTwo = const Color(0xff4dd0e1);
  static var tealThree = const Color(0xff88ffff);
  static var myColor = const LinearGradient(
    colors: [Color(0xff009faf), Color(0xff4dd0e1)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static var myColorTwo = LinearGradient(
    colors: [Colors.grey.shade200, Colors.grey.shade50],
    // colors: [Color(0xffd1d1d1), Color(0xffe8e8e8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  //for login screen
  static const blue = Color(0xFF497fff);
  static const whiteshade = Color(0xFFF8F9FA);
  static const grayshade = Color(0xFFEBEBEB);
  static const hintText = Color(0xFFC7C7CD);
}
