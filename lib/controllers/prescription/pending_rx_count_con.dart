import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rx_view/commons/Constant.dart';
// import 'package:rx_view/controllers/login_con.dart';
import 'package:rx_view/models/prescription/get_pending_rx_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PendingRxCountCon extends GetxController{
  // final LoginController _loginController = Get.put(LoginController());
  List<GetPendingRxModel> pendingRxList = [];

  @override
  void onInit() {
    // TODO: implement onInit
    fetchPendingRxCount();
    super.onInit();
  }


  void fetchPendingRxCount() async {
    String currentDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    String nowThirtyDaysAgo = DateFormat('dd-MMM-yyyy').format(DateTime.now().add(Duration(days: -30)));
    try{
      final prefs = await SharedPreferences.getInstance();
      String getSaUsersId = prefs.getString('saUsersId')??'';

      var url = Uri.parse(AppConstant().getRxHxCount);
      var response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "searchById" : getSaUsersId.toString(),
            "fromDate" : nowThirtyDaysAgo,
            "toDate" : currentDate
          }));
      var body = json.decode(response.body);
      switch (body['statusCode']) {
        case 200:
          {
            pendingRxList = getPendingRxModelFromJson(json.encode(body['listResponse']));
            update();
            // print("pendingRxList: $pendingRxList");
          }
          break;
        default:
          {
            print('object fetchPendingRxCount Failed api');
          }
      }
    }catch(e){
      print('FetchPendingRxCount Error: -> $e');
    }

  }
}

