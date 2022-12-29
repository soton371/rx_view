import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingController extends GetxController{

  //for default rx view page tab
  var defaultRxViewTab = 'All'.obs;

  //for calender month duration
  var calenderMonthDuration = '1'.obs;
  var calenderDayDuration = '30'.obs;

  //for refresh alert
  var refreshAlertIs = true.obs;
  var refreshAlertDuration = '5'.obs;

  //for rx info side panel
  var rxInfoSideVisible = false.obs;

  void tempSaveSetting()async{
    //for temp local save data
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('refreshAlertIs', refreshAlertIs.value);
    await prefs.setString('refreshAlertDuration', refreshAlertDuration.value);
    await prefs.setString('calenderMonthDuration', calenderMonthDuration.value);
    await prefs.setString('calenderDayDuration', calenderDayDuration.value);
    await prefs.setString('defaultRxViewTab', defaultRxViewTab.value);
    await prefs.setBool('rxInfoSideVisible', rxInfoSideVisible.value);
    print('object call tempSaveSetting()');
  }

  void getTempSaveSetting()async{
    //for get temp local save data
    final prefs = await SharedPreferences.getInstance();
    rxInfoSideVisible.value = prefs.getBool('rxInfoSideVisible')??false;
    refreshAlertIs.value = prefs.getBool('refreshAlertIs')??true;
    refreshAlertDuration.value = prefs.getString('refreshAlertDuration')??'5';
    calenderMonthDuration.value = prefs.getString('calenderMonthDuration')??'1';
    calenderDayDuration.value = prefs.getString('calenderDayDuration')??'0';
    defaultRxViewTab.value = prefs.getString('defaultRxViewTab')??'All';
    print('object call getTempSaveSetting()');
  }

}