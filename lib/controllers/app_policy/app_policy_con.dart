import 'dart:convert';
import 'package:get/get.dart';
import 'package:rx_view/commons/Constant.dart';
import 'package:rx_view/controllers/app_policy/get_app_policy_con.dart';
import 'package:rx_view/local_db/app_policy/app_policy_db.dart';
import 'package:rx_view/models/app_policy/app_policy_mod.dart';
import 'package:http/http.dart' as http;
import 'package:rx_view/views/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPolicyController extends GetxController{
  final GetAppPolicyController _getAppPolicyController = Get.put(GetAppPolicyController());

  List<AppPolicyModel> appPolicyList = [];
  // var rxVisibilityFg = 1.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getAppPolicy();
  }

  Future<void> getAppPolicy()async{
    final prefs = await SharedPreferences.getInstance();
    String getSaUsersId = prefs.getString('saUsersId')??'';
    if(getSaUsersId.isEmpty){
      Get.off(LogInScreen());
    }else{
      int saUsersId= getSaUsersId.length == 0 ? 0 : int.parse(getSaUsersId);
      var url = Uri.parse(AppConstant().appPolicy);
      var response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "chdUid": 0,
            "policyID": "",
            "policyText": "",
            "policyValue":0,
            "apValueFG":0,
            "clientId":0,
            "activeStatusFg":0,
            "userDslNo":saUsersId,
            "createBy":0,
            "modLinkId":0,
            "atiAppID":2,
            "policyVisibilityFg":0,
            "globalPermissionFG":0
          }));
      var body = json.decode(response.body);

      switch(body['statusCode']){
        case 200:{
          await AppPolicyDb.instance.deleteAll();

          appPolicyList = appPolicyModelFromJson(json.encode(body['listResponse']));

          for(var data in appPolicyList){
            //for local store
            final appPolicyData = AppPolicyModel(
                policyId: data.policyId,
                policyText: data.policyText,
                policyValue: data.policyValue,
                apValueFg: data.apValueFg,
                policyVisibilityFg: data.policyVisibilityFg,
                globalPermissionFg: data.globalPermissionFg
            );
            await AppPolicyDb.instance.addData(appPolicyData);
          }
          //for get rx visibility value
          _getAppPolicyController.getAppPolicyInfo();
          update();
          print('object success getAppPolicy');
        }
        break;
        default:{
          print('object something wrong inside getAppPolicy');
        }
      }
    }

  }

}