import 'dart:convert';
import 'package:rx_view/views/auth/login.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rx_view/commons/Constant.dart';
import 'package:rx_view/models/my_new_drawer_mod/my_new_drawer_mod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyNewDrawerCon extends GetxController {
  List<MyNewDrawerModel> menuList = [];
  //for rx view page rout permission
  var hasRxViewMenuId = false.obs;
  // final LoginController _controller = Get.put(LoginController());

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getAppMenu();
  }

  Future<void> getAppMenu() async {
    menuList.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      var saUsersId = prefs.getString('saUsersId') ?? '';
      var url = Uri.parse(AppConstant().appMenu);

      var response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "performBy": saUsersId.toString(),
            "udPerformBy": saUsersId.toString(),
            "userRole": "",
            "group": "",
            "appId": 2
          }));
      print("Call from my new drawer con.......................${hasRxViewMenuId.value}...");

      var body = json.decode(response.body);
      switch (body['statusCode']) {
        case 200:
            {
              menuList = myNewDrawerModelFromJson(json.encode(body['listResponse']));
              for(var e in menuList){
                if(e.menuUId=='SM017'){
                  hasRxViewMenuId.value = true;
                  break;
                }else{
                  if(e.subMenuList != null){
                    for(var subE in e.subMenuList!){
                      if(subE.udSubMenuId=='SM017'){
                        hasRxViewMenuId.value = true;

                        break;
                      }
                    }
                  }
                }
              }
            print('object success inside getAppMenu');
         }
          break;
        default:
          {
            Get.off(const LogInScreen());
            print('object something wrong inside getAppMenu');
          }
      }
      update();
    } catch (e) {
      Get.off(const LogInScreen());
      Get.snackbar('Something wrong', 'Please try again');
      print('object $e something wrong inside getAppMenu');
    }
  }
}
