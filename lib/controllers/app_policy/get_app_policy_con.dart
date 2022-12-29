import 'package:get/get.dart';
import 'package:rx_view/local_db/app_policy/app_policy_db.dart';
import 'package:rx_view/models/app_policy/app_policy_mod.dart';

class GetAppPolicyController extends GetxController{

  //for autoPlayInterval
  var autoPlayInterval = 8.obs;

  List<AppPolicyModel> appPolicyInfo = [];
  var rxVisibilityFg = 0.obs;
  var autoSlid = 0.obs;
  // var rxProcessingVisibilityFg = 0.obs;
  var showRxDetailsSidePanel = 0.obs;

  Future<void> getAppPolicyInfo() async{
    appPolicyInfo = await AppPolicyDb.instance.getData();

    for(var data in appPolicyInfo){
      //for rx visibility
      if(data.policyId == "DIL-PMD-027"){
        rxVisibilityFg.value = data.policyVisibilityFg!;
      }

      //for Slide Show Button Show Hide
      if(data.policyId == "DIL-PMD-028"){
        autoSlid.value = data.policyVisibilityFg!;
      }

      //for Show Rx Details in side pane
      if(data.policyId == "DIL-PMD-032"){
        showRxDetailsSidePanel.value = data.policyVisibilityFg!;
        // print('object showRxDetailsSidePanel.value = data.policyVisibilityFg: ${showRxDetailsSidePanel.value} = ${data.policyVisibilityFg}');
      }
      //end Show Rx Details in side pane
    }
  }
}
