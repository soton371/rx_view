import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rx_view/views/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController{
  var saUsersId = ''.obs;
  var userNAme = 'User Name'.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getLoginInfo();
  }

  Future<void> getLoginInfo()async{
    final prefs = await SharedPreferences.getInstance();
    saUsersId.value = prefs.getString('saUsersId')??'';
    userNAme.value = prefs.getString('userName')??'User Name';
    print('object LoginController saUsersId: $saUsersId');
  }

  Future<void> doLogOut(context)async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saUsersId', '');
    await prefs.setString('userName', '');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const LogInScreen()));
  }

}