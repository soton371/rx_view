import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:rx_view/commons/Constant.dart';
import 'package:rx_view/components/back_to_exit.dart';
import 'package:rx_view/components/myLoaderDialog.dart';
import 'package:rx_view/components/my_new_drawer.dart';
import 'package:rx_view/controllers/app_policy/app_policy_con.dart';
import 'package:rx_view/controllers/app_policy/get_app_policy_con.dart';
import 'package:rx_view/controllers/drawer_con/my_new_drawer_con.dart';
import 'package:rx_view/controllers/login_con.dart';
import 'package:rx_view/controllers/prescription/pending_rx_count_con.dart';
import 'package:rx_view/controllers/setting/setting_con.dart';
import 'package:rx_view/models/prescription/rx_model.dart';
import 'package:http/http.dart' as http;
import 'package:rx_view/models/prescription/shareable_user_mod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:image/image.dart' as img;
import 'package:table_calendar/table_calendar.dart';
import '../../models/prescription/get_pending_rx_model.dart';

class NewRxViewScreen extends StatefulWidget {
  const NewRxViewScreen({Key? key}) : super(key: key);

  @override
  State<NewRxViewScreen> createState() => _NewRxViewScreenState();
}

class _NewRxViewScreenState extends State<NewRxViewScreen> {
  final AppPolicyController _appPolicyController = Get.put(AppPolicyController());
  final GetAppPolicyController _getAppPolicyController = Get.put(GetAppPolicyController());
  final LoginController _loginController = Get.put(LoginController());
  final PendingRxCountCon _pendingRxCountCon = Get.put(PendingRxCountCon());
  final SettingController _settingController = Get.put(SettingController());

  bool autoPlayIs = false;
  int currentIndex = 0;

  List<RxModel> listResponse = [];
  List<MyRxList> finalRxList = [];
  List<MyRxList> cloneFinalRxList = [];
  bool hasData = true;

  bool clickFromSidePane = false;

  //for filter
  List<String> drIdList = [];

  String selectDrId = '';
  String selectHospital = '';
  String selectHospitalId = '';
  String selectDivision = '';
  String selectDistrict = '';
  String selectThana = '';
  String selectPerformerId = '';

  //start get division districtList thanaList
  List<String> divisionList = [];
  List<String> hospitalList = [];
  List<String> hospitalListId = [];
  List<String> districtList = [];
  List<String> thanaList = [];

  Future fetchRxData() async {
    _getAppPolicyController.getAppPolicyInfo();
    viewIs = false;
    hasData = true;
    finalRxList.clear();
    selectHospital = '';
    selectHospitalId = '';
    selectDivision = '';
    selectDistrict = '';
    selectThana = '';
    preferredSize = 0;
    divisionList.clear();
    districtList.clear();
    thanaList.clear();
    hospitalListId.clear();
    hospitalList.clear();
    notViewRxList.clear();
    viewRxList.clear();
    viewIs = false;
    notViewIs = false;
    allRxIs = true;
    currentIndex = 0;


    try {
      final prefs = await SharedPreferences.getInstance();
      String getSaUsersId = prefs.getString('saUsersId')??'';

      var url = Uri.parse("${AppConstant().rxInfoUrl}?startDate=$showDate&endDate=$showDate");

      var reqBody = {
            "searchById": getSaUsersId,
            "searchUsrId": "",
            "divisionNo": "",
            "districtNo": "",
            " hospitalNo": "",
            "doctorNo": "",
            "startDate": showDate,
            "endDate": showDate
          };
      debugPrint('Rx Info url: $url');
      debugPrint('Rx Info url: $reqBody');
      var response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(reqBody));
      var body = jsonDecode(utf8.decode(response.bodyBytes));
      switch (body['statusCode']) {
        case 200:
          {
            List<String> division = [];
            List<MyRxList>? rawRxList = [];

            final rxModel = rxModelFromJson(json.encode(body['listResponse']));

            listResponse = rxModel;
            for (int i = 0; i < listResponse.length; i++) {
              var listResponse2 = listResponse[i];
              hospitalList.add(listResponse2.hosCareName ?? '');
              hospitalListId.add(listResponse2.udHospitalId ?? '');
              var drList = listResponse2.drList;

              if (drList != null && drList.isNotEmpty) {
                for (int j = 0; j < drList.length; j++) {
                  var drList2 = drList[j];

                  var rxList2 = drList2.rxList;
                  finalRxList.addAll(rxList2 ?? []);
                  drIdList.add(drList2.userDhcgNo ?? '');
                  //for division
                  if (rxList2 != null && rxList2.isNotEmpty) {
                    rawRxList.addAll(rxList2);
                    for (int k = 0; k < rxList2.length; k++) {
                      //for not report from data
                        var rxList22 = rxList2[k];
                        division.add(rxList22.divisionName ?? '');
                        if (rxList22.viewingFlag == 0) {
                          notViewRxList.add(rxList22);
                        }else{
                          viewRxList.add(rxList22);
                        }
                    } // End Loop
                  }
                }
              } // End main if
            } //end main loop
            //filerSidePanData(finalRxList);
            //for double values are not allowed
            var seenDivision = <String>{};
            divisionList = division.where((d) => seenDivision.add(d)).toList();
            //for sort division
            divisionList.sort((a, b) => a.compareTo(b));



            // formattedData(filterData());
            hasData = false;

            print('object success fetchData');
            setState(() {});
          }
          break;
        default:
          {
            divisionList.clear();
            districtList.clear();
            thanaList.clear();
            hospitalListId.clear();
            hospitalList.clear();
            setState(() {
              hasData = false;
            });
            print('object wrong something inside fetchData');
          }
      }
    } catch (e) {
      //code
      divisionList.clear();
      districtList.clear();
      thanaList.clear();
      hospitalListId.clear();
      hospitalList.clear();
      setState(() {
        hasData = false;
      });
      print('object wrong something inside fetchData e: $e ');
    }
    if(cloneFinalRxList.isEmpty){
      cloneFinalRxList = finalRxList;
    }

    print("Changing clone...........");
    allRxList = cloneFinalRxList;
    //for default tab
    defaultTab();
    refreshAlert();
    viewResponse();
    setState(() {});
  }

  List<MyRxList> allRxList = [];

  List<MyRxList> selectedRxList() {
    if (viewIs) {
      return viewRxList;
    } else if (notViewIs) {
      return notViewRxList;
    } else {

      return allRxList;
    }
  }

  //start filter data
  List<MyRxList> filterData() {
    List<MyRxList> filteredList = [];
    if (selectedRxList().isNotEmpty) {

      for (var data in selectedRxList()) {
        var udHospitalId = data.udHospitalId;
        var drId = data.userDhcgNo;
        var divisionName = data.divisionName;
        var districtName = data.districtName;
        var thanaName = data.thanaName;
        var feedbackSendBy = data.feedbackSendBy;

        if (selectHospitalId.isNotEmpty &&
            selectHospitalId == udHospitalId &&
            selectDrId.isNotEmpty &&
            selectDrId == drId &&
            selectDivision.isNotEmpty &&
            divisionName == selectDivision &&
            selectDistrict.isNotEmpty &&
            districtName == selectDistrict &&
            selectThana.isNotEmpty &&
            thanaName == selectThana &&
            selectPerformerId.isNotEmpty &&
            selectPerformerId == feedbackSendBy) {
          filteredList.add(data);
          print("For All filter Data");
        } else if (selectHospitalId.isNotEmpty &&
            selectHospitalId == udHospitalId &&
            selectDrId.isNotEmpty &&
            selectDrId == drId &&
            selectDivision.isNotEmpty &&
            divisionName == selectDivision &&
            selectDistrict.isNotEmpty &&
            districtName == selectDistrict &&
            selectThana.isNotEmpty &&
            thanaName == selectThana &&
            selectPerformerId.isEmpty) {
          filteredList.add(data);
          print("Without performer filtered DAta");
        } else if (selectHospitalId.isNotEmpty &&
            selectHospitalId == udHospitalId &&
            selectDrId.isNotEmpty &&
            selectDrId == drId &&
            selectDivision.isNotEmpty &&
            divisionName == selectDivision &&
            selectDistrict.isNotEmpty &&
            districtName == selectDistrict &&
            selectThana.isEmpty &&
            selectPerformerId.isEmpty) {
          filteredList.add(data);
          print("Without thana & professional filtered DAta");
        } else if (selectHospitalId.isNotEmpty &&
            selectHospitalId == udHospitalId &&
            selectDrId.isNotEmpty &&
            selectDrId == drId &&
            selectDivision.isNotEmpty &&
            divisionName == selectDivision &&
            selectDistrict.isEmpty &&
            selectThana.isEmpty &&
            selectPerformerId.isEmpty) {
          filteredList.add(data);
          print("Without district, thana & professional filtered DAta");
        } else if (selectHospitalId.isNotEmpty &&
            selectHospitalId == udHospitalId &&
            selectDrId.isNotEmpty &&
            selectDrId == drId &&
            selectDivision.isEmpty &&
            selectDistrict.isEmpty &&
            selectThana.isEmpty &&
            selectPerformerId.isEmpty) {
          filteredList.add(data);
          print("Without division, district, thana & professional filtered DAta");
        } else if (selectHospitalId.isNotEmpty &&
            selectHospitalId == udHospitalId &&
            selectDrId.isEmpty &&
            selectDivision.isEmpty &&
            selectDistrict.isEmpty &&
            selectThana.isEmpty &&
            selectPerformerId.isEmpty) {
          filteredList.add(data);
          print("Without doctor, division, district, thana & professional filtered DAta");
        } else if (selectHospitalId.isEmpty &&
            selectDrId.isEmpty &&
            selectDivision.isEmpty &&
            selectDistrict.isEmpty &&
            selectThana.isEmpty &&
            selectPerformerId.isNotEmpty &&
            selectPerformerId == feedbackSendBy) {
          filteredList.add(data);
          print("Without hospital, doctor, division, district & thana filtered DAta");
        } else if (selectHospitalId.isEmpty &&
            selectDrId.isEmpty &&
            selectDivision.isNotEmpty &&
            divisionName == selectDivision &&
            selectDistrict.isNotEmpty &&
            districtName == selectDistrict &&
            selectThana.isNotEmpty &&
            thanaName == selectThana &&
            selectPerformerId.isNotEmpty &&
            selectPerformerId == feedbackSendBy) {
          filteredList.add(data);
          print("Without hospital & doctor filtered DAta");
        } else if (selectHospitalId.isEmpty &&
            selectDrId.isEmpty &&
            selectDivision.isNotEmpty &&
            divisionName == selectDivision &&
            selectDistrict.isNotEmpty &&
            districtName == selectDistrict &&
            selectThana.isNotEmpty &&
            thanaName == selectThana &&
            selectPerformerId.isEmpty) {
          filteredList.add(data);
          print("Without hospital, doctor & performer filtered DAta");
        } else if (selectHospitalId.isEmpty &&
            selectDrId.isEmpty &&
            selectDivision.isNotEmpty &&
            divisionName == selectDivision &&
            selectDistrict.isNotEmpty &&
            districtName == selectDistrict &&
            selectThana.isEmpty &&
            selectPerformerId.isEmpty) {
          filteredList.add(data);
          print("Without hospital, doctor, thana &  performer filtered DAta");
        } else if (selectHospitalId.isEmpty &&
            selectDrId.isEmpty &&
            selectDivision.isNotEmpty &&
            divisionName == selectDivision &&
            selectDistrict.isEmpty &&
            selectThana.isEmpty &&
            selectPerformerId.isEmpty) {
          filteredList.add(data);
          print("Without hospital, doctor, district, thana &  performer filtered DAta");
        } else if (selectHospitalId.isNotEmpty &&
            selectHospitalId == udHospitalId &&
            selectDrId.isNotEmpty &&
            selectDrId == drId &&
            selectDivision.isNotEmpty &&
            divisionName == selectDivision &&
            selectDistrict.isNotEmpty &&
            districtName == selectDistrict &&
            selectThana.isEmpty &&
            selectPerformerId.isNotEmpty &&
            selectPerformerId == feedbackSendBy) {
          filteredList.add(data);
          print("Without thana filtered DAta");
        } else if (selectHospitalId.isNotEmpty &&
            selectHospitalId == udHospitalId &&
            selectDrId.isNotEmpty &&
            selectDrId == drId &&
            selectDivision.isNotEmpty &&
            divisionName == selectDivision &&
            selectDistrict.isEmpty &&
            selectThana.isEmpty &&
            selectPerformerId.isNotEmpty &&
            selectPerformerId == feedbackSendBy) {
          filteredList.add(data);
          print("Without district & thana filtered DAta");
        } else if (selectHospitalId.isNotEmpty &&
            selectHospitalId == udHospitalId &&
            selectDrId.isNotEmpty &&
            selectDrId == drId &&
            selectDivision.isEmpty &&
            selectDistrict.isEmpty &&
            selectThana.isEmpty &&
            selectPerformerId.isNotEmpty &&
            selectPerformerId == feedbackSendBy) {
          filteredList.add(data);
          print("Without division, district & thana filtered DAta");
        } else if (selectHospitalId.isNotEmpty &&
            selectHospitalId == udHospitalId &&
            selectDrId.isEmpty &&
            selectDivision.isEmpty &&
            selectDistrict.isEmpty &&
            selectThana.isEmpty &&
            selectPerformerId.isNotEmpty &&
            selectPerformerId == feedbackSendBy) {
          filteredList.add(data);
          print("Without dr, division, district & thana filtered DAta");
        } else if (selectDivision.isNotEmpty &&
            divisionName == selectDivision &&
            selectDistrict.isNotEmpty &&
            districtName == selectDistrict &&
            selectThana.isNotEmpty &&
            thanaName == selectThana &&
            selectHospitalId.isNotEmpty &&
            selectHospitalId == udHospitalId &&
            selectDrId.isEmpty &&
            selectPerformerId.isEmpty) {
          filteredList.add(data);
          print("Without doctor & performer filtered DAta");
        } else if (selectHospitalId.isEmpty &&
            selectDrId.isEmpty &&
            selectDivision.isEmpty &&
            selectDistrict.isEmpty &&
            selectThana.isEmpty &&
            selectPerformerId.isEmpty) {
          filteredList.add(data);
          //  print("Without hospital, dr, division, district, thana & performer id filtered DAta");
        } else if (selectHospitalId.isNotEmpty &&
            selectHospitalId == udHospitalId &&
            selectDrId.isEmpty &&
            selectDivision.isNotEmpty &&
            divisionName == selectDivision &&
            selectDistrict.isNotEmpty &&
            districtName == selectDistrict &&
            selectThana.isEmpty &&
            selectPerformerId.isEmpty) {
          filteredList.add(data);
          print("Without dr, thana & performer id filtered DAta");
        } else if (selectHospitalId.isNotEmpty &&
            selectHospitalId == udHospitalId &&
            selectDrId.isEmpty &&
            selectDivision.isNotEmpty &&
            divisionName == selectDivision &&
            selectDistrict.isEmpty &&
            selectThana.isEmpty &&
            selectPerformerId.isEmpty) {
          filteredList.add(data);
          print("Without dis, dr, thana & performer id filtered DAta");
        }
      }
    }
    return filteredList;
  }

//end filter data
  final MyNewDrawerCon _myNewDrawerCon = Get.put(MyNewDrawerCon());

  //for dynamic calender month duration
  DateTime kFirstDay = DateTime(DateTime.now().year, DateTime.now().month - 0, DateTime.now().day);

  //for data refresh alert
  int repeatRefreshAlert = 0;
  void refreshAlert() {
    if(repeatRefreshAlert == 0){
      repeatRefreshAlert = 1;
      if (_settingController.refreshAlertIs.isTrue) {
        int min = int.parse(_settingController.refreshAlertDuration.toString());
        Timer(Duration(minutes: min), () {
          showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: Text('Notice'),
                content: Text('Do you want to refresh?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      repeatRefreshAlert = 0;
                      Navigator.pop(context);
                    },
                    child: Text('Dismiss'),
                  ),


                  TextButton(
                      onPressed: () {
                        repeatRefreshAlert = 0;
                        fetchRxData();
                        setState(() {
                          allRxIs = true;
                          notViewIs = false;
                          viewIs = false;
                          currentIndex = 0;
                        });
                        Navigator.pop(context);
                      },
                      child: Text('Agree'))
                ],
              ));
        });
      } else {
        print('No need refresh alert');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    fetchRxData();
    super.initState();
    _myNewDrawerCon.getAppMenu();
    _appPolicyController.getAppPolicy();
    int getMonth =
        int.parse(_settingController.calenderMonthDuration.value.toString()) > 3 ? 0 : int.parse(_settingController.calenderMonthDuration.value.toString());
    kFirstDay = DateTime(
        DateTime.now().year, DateTime.now().month - getMonth, DateTime.now().day - int.parse(_settingController.calenderDayDuration.value.toString()));
  }

  @override
  void dispose() {
    super.dispose();
    preferredSize = 0;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  //for checkbox
  bool titleClick = true;

//for preferred sized
  double preferredSize = 0;

  //for hospital content view
  bool selectHospitalIs = false;

  //for under image sized box height
  double underImageHeight = 170;

//for scroll detect
  DragStartDetails startVerticalDragDetails = DragStartDetails();
  var updateVerticalDragDetails;

  //for api response date formatted
  String? responseDate(String resDate) {
    String month = resDate.split('-')[1].toString();
    switch (month) {
      case '01':
        String newDate = resDate.replaceAll(resDate.split('-')[1].toString(), 'Jan');
        return newDate;
      case '02':
        String newDate = resDate.replaceAll(resDate.split('-')[1].toString(), 'Feb');
        return newDate;
      case '03':
        String newDate = resDate.replaceAll(resDate.split('-')[1].toString(), 'Mar');
        return newDate;
      case '04':
        String newDate = resDate.replaceAll(resDate.split('-')[1].toString(), 'Apr');
        return newDate;
      case '05':
        String newDate = resDate.replaceAll(resDate.split('-')[1].toString(), 'May');
        return newDate;
      case '06':
        String newDate = resDate.replaceAll(resDate.split('-')[1].toString(), 'Jun');
        return newDate;
      case '07':
        String newDate = resDate.replaceAll(resDate.split('-')[1].toString(), 'Jul');
        return newDate;
      case '08':
        String newDate = resDate.replaceAll(resDate.split('-')[1].toString(), 'Aug');
        return newDate;
      case '09':
        String newDate = resDate.replaceAll(resDate.split('-')[1].toString(), 'Sep');
        return newDate;
      case '10':
        String newDate = resDate.replaceAll(resDate.split('-')[1].toString(), 'Oct');
        return newDate;
      case '11':
        String newDate = resDate.replaceAll(resDate.split('-')[1].toString(), 'Nov');
        return newDate;
      case '12':
        String newDate = resDate.replaceAll(resDate.split('-')[1].toString(), 'Dec');
        return newDate;
    }
    return null;
  }

  //for select visible
  bool selectVisibleIs() {
    double w = MediaQuery.of(context).size.width;
    if (w > 640) {
      return true;
    } else {
      return false;
    }
  }

  //for image rotate
  int quarterTurns = 0;

  //for panel sized
  double panelSized(int lines) {
    double result = lines * 18;
    return result;
  }

  //for share remarks
  String shareRemark = '';
  String userRole = '';
  String mkgProfNo = '';
  int rxShareFlag = 1;
  int shareId = 0;
  List<ShareableUserModel> shareableUserList = [];
  List sendRemarksPayload = [];
  bool oneTime = true;

  Future<void> getShareableUser(String areaCode) async {
    try {
      var url = Uri.parse(AppConstant().getShareableUsers);
      var rx3 = finalRxList.isEmpty ? MyRxList() : finalRxList[currentIndex];
      var response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "feedBackMstId": rx3.feedBackMstId,
            "udPerformBy": "",
            "performBy": int.parse(_loginController.saUsersId.toString()),
            "userRole": "",
            "areaCode": areaCode,
            "district": rx3.districtName,
            "division": rx3.divisionName,
            "upazilla": rx3.thanaName
          }));
      var body = json.decode(response.body);
      switch (body['statusCode']) {
        case 200:
          {
            shareableUserList = shareableUserModelFromJson(json.encode(body['listResponse']));
            showDialog(
                context: context,
                builder: (context) => StatefulBuilder(
                    builder: (context, setState) => AlertDialog(
                          backgroundColor: Color(0xCCF2F2F2),
                          titlePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          actionsPadding: EdgeInsets.zero,
                          contentPadding: EdgeInsets.all(10),
                          buttonPadding: EdgeInsets.zero,
                          iconPadding: EdgeInsets.zero,
                          insetPadding: EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          actionsAlignment: MainAxisAlignment.center,
                          title: IconButton(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.all(0),
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Iconsax.close_circle,
                                color: AppConstant.removeColor,
                              )),
                          content: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: ListView(
                              children: [
                                //for heading
                                Row(
                                  children: [
                                    Expanded(flex: 2, child: Text('Code')),
                                    Expanded(flex: 5, child: Text('Professional Name')),
                                    Expanded(flex: 1, child: Text('Designation')),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Share To',
                                          textAlign: TextAlign.end,
                                        )),
                                  ],
                                ),

                                //for user list
                                ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: shareableUserList.length,
                                    itemBuilder: (context, i) {
                                      var rx2 = rx3;
                                      if (shareableUserList.isNotEmpty && shareableUserList.length > sendRemarksPayload.length && oneTime) {
                                        userRole = shareableUserList[i].profRole ?? '';
                                        mkgProfNo = shareableUserList[i].mktProfNo ?? '';
                                        shareId = shareableUserList[i].shareId ?? 0;
                                        //add send remarks
                                        sendRemarksPayload.add({
                                          "feedBackMstId": rx2.feedBackMstId,
                                          "udPerformBy": _loginController.saUsersId.toString(),
                                          "performBy": 0,
                                          "userRole": userRole,
                                          "areaCode": "",
                                          "district": rx2.districtName,
                                          "division": rx2.divisionName,
                                          "upazilla": rx2.thanaName,
                                          "mkgProfNo": mkgProfNo,
                                          "reamarks": shareRemark,
                                          "rxShareFlag": rxShareFlag,
                                          "shareId": shareId
                                        });

                                        print('object oneTime: $oneTime');
                                      }
                                      return shareableUserList.isEmpty
                                          ? Text('no user available')
                                          : Container(
                                              decoration: BoxDecoration(border: Border(top: BorderSide(color: AppConstant.shadowColor, width: 1))),
                                              child: Row(
                                                children: [
                                                  //shareableUserList[i].shareFlag==1? Icon(Iconsax.send_2,color: AppConstant.primarySwatchColor.withOpacity(0.8),size: 15,):SizedBox(),
                                                  //for code
                                                  Expanded(flex: 2, child: Text("${shareableUserList[i].mktProfNo.toString()}")),
                                                  //for professional name
                                                  Expanded(
                                                      flex: 5,
                                                      child: Row(
                                                        children: [
                                                          Text(shareableUserList[i].mktProfName.toString()),
                                                          shareableUserList[i].shareFlag == 1
                                                              ? Icon(
                                                                  Iconsax.send_2,
                                                                  color: AppConstant.primarySwatchColor,
                                                                  size: 12,
                                                                )
                                                              : SizedBox(),
                                                        ],
                                                      )),
                                                  //for designation
                                                  Expanded(flex: 1, child: Text(shareableUserList[i].profRole.toString())),
                                                  //for check box
                                                  Expanded(
                                                    flex: 2,
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: Align(
                                                        alignment: Alignment.centerRight,
                                                        child: Checkbox(
                                                            shape: CircleBorder(),
                                                            value: shareableUserList[i].isSelected ?? true,
                                                            onChanged: (v) {
                                                              setState(() {
                                                                shareableUserList[i].isSelected = v;
                                                                oneTime = false;
                                                              });
                                                              if (v == true) {
                                                                userRole = shareableUserList[i].profRole ?? '';
                                                                mkgProfNo = shareableUserList[i].mktProfNo ?? '';
                                                                shareId = shareableUserList[i].shareId ?? 0;

                                                                //add send remarks
                                                                var rx = rx2;
                                                                sendRemarksPayload.add({
                                                                  "feedBackMstId": rx.feedBackMstId,
                                                                  "udPerformBy": _loginController.saUsersId.toString(),
                                                                  "performBy": 0,
                                                                  "userRole": userRole,
                                                                  "areaCode": "",
                                                                  "district": rx.districtName,
                                                                  "division": rx.divisionName,
                                                                  "upazilla": rx.thanaName,
                                                                  "mkgProfNo": mkgProfNo,
                                                                  "reamarks": shareRemark,
                                                                  "rxShareFlag": 1,
                                                                  "shareId": shareId
                                                                });
                                                              } else {
                                                                shareId = shareableUserList[i].shareId ?? 0;
                                                                mkgProfNo = shareableUserList[i].mktProfNo ?? '';
                                                                //remove send remarks
                                                                if (sendRemarksPayload.isNotEmpty) {
                                                                  var index = -1;
                                                                  for (var i = 0; sendRemarksPayload.length > i; i++) {
                                                                    var d = sendRemarksPayload[i];
                                                                    if (d["mkgProfNo"] == mkgProfNo) {
                                                                      index = i;
                                                                      break;
                                                                    }
                                                                  }
                                                                  if (index > -1) {
                                                                    if (shareId > 0) {
                                                                      setState(() {
                                                                        sendRemarksPayload[i]["rxShareFlag"] = 0;
                                                                      });
                                                                    } else {
                                                                      sendRemarksPayload.removeAt(index);
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                              }),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                    }),

                                //for write remarks
                                CupertinoTextField(
                                  maxLines: 2,
                                  scribbleEnabled: titleClick,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  keyboardType: TextInputType.text,
                                  placeholder: 'share your remarks',
                                  onChanged: (v) {
                                    shareRemark = v;
                                  },
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(border: Border(top: BorderSide(color: AppConstant.shadowColor))),
                              child: TextButton(
                                  onPressed: () {
                                    if (mkgProfNo.isEmpty) {
                                      Get.snackbar("Warning", "Please select user", colorText: AppConstant.backgroundColor);
                                    } else {
                                      sendRemarks();
                                    }
                                  },
                                  child: Text('Send')),
                            )
                          ],
                        )));
            print("object getShareableUser success}");
          }
          break;
        default:
          {
            print("object getShareableUser something wrong: ${body['statusCode']}");
          }
      }
      //end switch
    } catch (e) {
      print("object getShareableUser something wrong e: $e");
    }
  }

  Future<void> sendRemarks() async {
    try {
      var url = Uri.parse(AppConstant().shareRx);
      var response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: json.encode(sendRemarksPayload));
      print('object payload: $sendRemarksPayload');
      var body = json.decode(response.body);
      print('object: $body');
      switch (body['statusCode']) {
        case 200:
          shareRemark = '';
          userRole = '';
          mkgProfNo = '';
          rxShareFlag = 1;
          shareId = 0;
          sendRemarksPayload.clear();
          oneTime = true;
          Get.snackbar('Success', "Send remark", colorText: AppConstant.backgroundColor);
          Navigator.pop(context);
          break;
        default:
          Get.snackbar('Failed', "Send remark", colorText: AppConstant.backgroundColor);
      }
    } catch (e) {
      Get.snackbar('Failed', "Send remark", colorText: AppConstant.backgroundColor);
    }
  }

  //save images
  String filepath = "";

  Future<void> storeFileFromNetwork(String imgUrl) async {
    final http.Response responseData = await http.get(Uri.parse(imgUrl));
    var uint8list = responseData.bodyBytes;
    var buffer = uint8list.buffer;
    ByteData byteData = ByteData.view(buffer);
    var tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/img').writeAsBytes(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    print("===>${file.path} - ${file.absolute}");
    filepath = file.path;
    fixExifRotation(filepath);
    // return file;
  }

  //rotate images
  File? file;
  int rotateDrg = 0;

  Future<void> fixExifRotation(String imagePath) async {
    final originalFile = File(imagePath);
    List<int> imageBytes = await originalFile.readAsBytes();

    final originalImage = img.decodeImage(imageBytes);

    img.Image? fixedImage = null;

    fixedImage = img.copyRotate(originalImage!, rotateDrg);
    final fixedFile = await originalFile.writeAsBytes(img.encodeJpg(fixedImage));

    setState(() {
      file = fixedFile;
    });

    print("Calling............$rotateDrg");
    sendImage(file!);
    // return fixedFile;
  }

  //send image
  bool saveVisible = false;

  Future<void> sendImage(File sendFile) async {
    String fileName = finalRxList.isEmpty ? '' : finalRxList[currentIndex].imgLink ?? '';

    var request = http.MultipartRequest('POST', Uri.parse(AppConstant().updateRxImg));
    request.fields.addAll({'fileName': fileName});
    request.files.add(await http.MultipartFile.fromBytes(
      'file',
      await sendFile.readAsBytesSync(),
      filename: "file",
    ));

    print(request.toString());
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      saveVisible = false;
      print(await response.stream.bytesToString());
      Get.snackbar('Success', "Save image", colorText: AppConstant.backgroundColor);
      deleteImageFromCache("${AppConstant.imageUrl}/${finalRxList.isEmpty ? '' : finalRxList[currentIndex].imgLink}");
      Navigator.pop(context);
    } else {
      print(response.reasonPhrase);
      Get.snackbar('Failed', "Save image", colorText: AppConstant.backgroundColor);
    }
  }

//remove cache image
  Future<void> deleteImageFromCache(url) async {
    await CachedNetworkImage.evictFromCache(url);
    PaintingBinding.instance.imageCache.clear();
  }

  void findDistrict() {
    List<String> district = [];
    for (int i = 0; i < selectedRxList().length; i++) {
      if (selectDivision == selectedRxList()[i].divisionName) {
        district.add(selectedRxList()[i].districtName ?? '');
      }
    }
    //for double values are not allowed
    var seenDistrict = <String>{};
    districtList = district.where((d) => seenDistrict.add(d)).toList();

    //for sort district
    districtList.sort((a, b) => a.compareTo(b));
  }

  //for thana inside district
  void findThana() {
    List<String> thana = [];
    for (int i = 0; i < selectedRxList().length; i++) {
      if (selectDistrict == selectedRxList()[i].districtName) {
        thana.add(selectedRxList()[i].thanaName ?? '');
      }
    }
    //for double values are not allowed
    var seenThana = Set<String>();
    thanaList = thana.where((d) => seenThana.add(d)).toList();

    //for sort
    thanaList.sort((a, b) => a.compareTo(b));
  }

  //for doctor inside hospital
  void findHospital() {
    List<String> hospitals = [];
    List<String> hospitalsId = [];
    for (int i = 0; i < selectedRxList().length; i++) {
      if (selectDivision == selectedRxList()[i].divisionName && selectDistrict.isEmpty && selectThana.isEmpty) {
        hospitals.add(selectedRxList()[i].hosCareName ?? '');
        hospitalsId.add(selectedRxList()[i].udHospitalId ?? '');
        print('findHospital block 1');
      } else if (selectDivision == selectedRxList()[i].divisionName && selectDistrict == selectedRxList()[i].districtName && selectThana.isEmpty) {
        hospitals.add(selectedRxList()[i].hosCareName ?? '');
        hospitalsId.add(selectedRxList()[i].udHospitalId ?? '');
        print('findHospital block 2');
      } else if (selectDivision == selectedRxList()[i].divisionName &&
          selectDistrict == selectedRxList()[i].districtName &&
          selectThana == selectedRxList()[i].thanaName) {
        hospitals.add(selectedRxList()[i].hosCareName ?? '');
        hospitalsId.add(selectedRxList()[i].udHospitalId ?? '');
        print('findHospital block 3');
      } else if (selectDivision.isEmpty && selectDistrict.isEmpty && selectThana.isEmpty) {
        hospitals.add(selectedRxList()[i].hosCareName ?? '');
        hospitalsId.add(selectedRxList()[i].udHospitalId ?? '');
        print('findHospital block 4');
      }
    }

    //for double values are not allowed
    var seenHospital = Set<String>();
    var seenHospitalId = Set<String>();
    hospitalList = hospitals.where((d) => seenHospital.add(d)).toList();
    hospitalListId = hospitalsId.where((d) => seenHospitalId.add(d)).toList();
  }

  //for sliding panel up body & panel
  //for select visible
  bool slidingPanelVisibleIs() {
    double w = MediaQuery.of(context).size.width;
    if (w > 835) {
      preferredSize = 0;
      return true;
    } else {
      return false;
    }
  }

  slidingPanelUpPanel() {
    var finalRx = finalRxList.isEmpty ? MyRxList() : finalRxList[currentIndex];
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //start content
            Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Column(
                children: [
                  // start hospital name
                  selectHospitalIs
                      ? SizedBox()
                      : Text(
                          finalRx.hosCareName ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                  // end hospital name

                  // start hospital address
                  selectHospitalIs
                      ? SizedBox()
                      : Text(
                          finalRx.hcpAddress ?? '',
                          textAlign: TextAlign.center,
                        ),
                  // end hospital address

                  Text(
                    "${finalRx.drName ?? ''} ${finalRx.drName?.isEmpty ?? true ? '' : '::'} ${finalRx.drDegree ?? ''} ${finalRx.drDegree?.isEmpty ?? true ? '' : '::'} ${finalRx.speciality ?? ''}",
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            //end content


            Text( finalRx.udMsRxNo?.isNotEmpty ?? false ? '  Rx no: ${finalRx.udMsRxNo}' : '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                )),

            Expanded(
              child: ListView(
                // shrinkWrap: true,
                // padding: EdgeInsets.symmetric(horizontal: 8),
                physics: BouncingScrollPhysics(),
                children: [
                  finalRxList.isEmpty ?
                  Lottie.asset('assets/jsons/nodata.json',height: 200) :
                  Html(data: """
                      <html>
<title>Online HTML Editor</title>
<head>
    <style>
        table {
            width: 100%; border-collapse: collapse; align: left;
        }
        
        th {
            border: 1px solid #c6c6c6; text-align: center; padding: 8px;
        }
        td {
            border: 1px solid #dddddd; text-align: center; padding: 2px;
        }
        tr:nth-child(even) {
          background-color: #f8f8f8;
       }
    </style>
</head>
<body>
<table >
    ${finalRxList.isNotEmpty ? finalRx.medDetails : ' '}
</table>
</body>
</html> 
                      """, style: {
                    "thead": Style(
                      backgroundColor: Colors.grey.shade300,
                    ),
                    // "table": Style(
                    //   alignment: Alignment.center,
                    // ),
                  })
                ],
              ),
            ),
            // ),
            //end show medicine
            SizedBox(
              height: 8,
            ),
            //start performer name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                  "${finalRx.udCreateBy} ${finalRx.udCreateBy?.isEmpty ?? true ? '' : '::'} ${finalRx.performDate}",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            //end performer name

            //start capture date
            finalRx.rxCaptureDtTm?.isEmpty ?? true
                ? SizedBox()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                        "${finalRx.rxCaptureDtTm?.isEmpty ?? true ? '' : 'Rx Capture Date & Time: ${finalRx.rxCaptureDtTm}'}"),
                  ),
            SizedBox(
              height: 8,
            ),
          ],
        ));
  }

  slidingPanelUpBody() {
    return CarouselSlider(
      options: CarouselOptions(
          height: MediaQuery.of(context).size.height,
          autoPlay: autoPlayIs,
          autoPlayInterval: Duration(seconds: _getAppPolicyController.autoPlayInterval.value),
          viewportFraction: 1,
          initialPage: currentIndex,
          onPageChanged: (index, reason) {
            setState(() {
              int matchIndex = currentIndex + 1;
              currentIndex = matchIndex;
              if(finalRxList.isNotEmpty){
                finalRxList[currentIndex].evfcFg = 5;
              }
              saveVisible = false;
              quarterTurns = 0;
              rotateDrg = 0;

            });

            //start view response
            viewResponse();
            //end view response
          }),
      items: finalRxList.map((i) {
        return Builder(
          builder: (BuildContext context) {
            hasData = true;
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                //for view image
                CachedNetworkImage(
                  imageUrl: "${AppConstant.imageUrl}/${finalRxList.isEmpty ? '' : finalRxList[currentIndex].imgLink}",
                  placeholder: (context, url) => Center(child: const CupertinoActivityIndicator()),
                  imageBuilder: (context, imageProvider) =>
                      Stack(alignment: currentIndex == 0 ? Alignment.centerLeft : Alignment.centerRight, children: [
                    RotatedBox(
                        quarterTurns: currentIndex == 0 ? 3 : 1,
                        child: Text(
                          currentIndex == 0 ? 'This is the first Rx of the base criteria' : 'This is the last Rx of the base criteria',
                          style: TextStyle(color: Colors.redAccent),
                        )),
                    PhotoViewGallery.builder(
                      enableRotation: true,
                      scrollPhysics: const BouncingScrollPhysics(),
                      pageController: PageController(initialPage: currentIndex),
                      builder: (BuildContext context, int index) {
                        return PhotoViewGalleryPageOptions(
                          imageProvider: imageProvider,
                          initialScale: PhotoViewComputedScale.contained,
                        );
                      },
                      itemCount: finalRxList.length,
                      onPageChanged: (v) {
                        int newIndex = v;
                        int testIndex = finalRxList.length == newIndex ? finalRxList.length - 1 : newIndex;
                        setState(() {
                          currentIndex = testIndex;
                          if(finalRxList.isNotEmpty){
                            finalRxList[currentIndex].evfcFg = 5;
                          }

                          saveVisible = false;
                          quarterTurns = 0;
                          rotateDrg = 0;
                        });
                        //start view response
                        viewResponse();
                        //end view response
                      },
                      backgroundDecoration: BoxDecoration(color: AppConstant.backgroundColor),
                    ),
                  ]),
                  errorWidget: (context, url, error) => Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.image),
                        Text('  Image not found'),
                      ],
                    ),
                  ),
                ),
                //end view image


                //for date and view count
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      //count
                      Container(
                        padding: EdgeInsets.all(5),
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.black26,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            finalRxList.isEmpty || finalRxList[currentIndex].viewingFlag == 0
                                ? Icon(Iconsax.eye_slash, size: 14, color: AppConstant.backgroundColor)
                                : Icon(Iconsax.eye, size: 14, color: AppConstant.backgroundColor),
                            Text(
                              '${currentIndex + 1}/${finalRxList.length}',
                              style: TextStyle(fontWeight: FontWeight.w500, color: AppConstant.backgroundColor),
                            ),
                          ],
                        ),
                      ),
                      //end count

                      //tap full image
                      Container(
                          margin: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.black26,
                          ),
                          child: IconButton(
                              onPressed: () {
                                quarterTurns = 0;
                                saveVisible = false;
                                rotateDrg = 0;
                                showGeneralDialog(
                                    context: context,
                                    barrierColor: Colors.black12.withOpacity(0.6),
                                    // Background color
                                    barrierDismissible: false,
                                    barrierLabel: 'Dialog',
                                    transitionDuration: const Duration(milliseconds: 400),
                                    pageBuilder: (_, __, ___) {
                                      return StatefulBuilder(builder: (context, setState) {
                                        return Material(
                                          child: SafeArea(
                                            child: CarouselSlider(
                                              items: finalRxList
                                                  .map((e) => Builder(
                                                        builder: (context) {
                                                          var finalRx2 = finalRxList.isEmpty ? MyRxList() : finalRxList[currentIndex];
                                                          return Column(
                                                          children: [
                                                            //start content & cross
                                                            Container(
                                                              color: AppConstant.backgroundColor,
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  //start content
                                                                  Expanded(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(finalRx2.hosCareName ?? ''),
                                                                          Text(finalRx2.hcpAddress ?? ''),
                                                                          Text(
                                                                              "${finalRx2.drName} ${finalRx2.drName?.isEmpty ?? true ? '' : '::'} ${finalRx2.drDegree} ${finalRx2.drDegree?.isEmpty ?? true ? '' : '::'} ${finalRx2.speciality}"),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  //end content

                                                                  //start cross
                                                                  IconButton(
                                                                      onPressed: () {
                                                                        quarterTurns = 0;
                                                                        saveVisible = false;
                                                                        rotateDrg = 0;
                                                                        Navigator.pop(context);
                                                                        setState(() {
                                                                          currentIndex = currentIndex;
                                                                        });
                                                                      },
                                                                      icon: Icon(
                                                                        Iconsax.close_circle,
                                                                        color: Colors.red,
                                                                      )),
                                                                  //end cross
                                                                ],
                                                              ),
                                                            ),
                                                            //end content & cross

                                                            //start image
                                                            Expanded(
                                                              child: RotatedBox(
                                                                quarterTurns: quarterTurns,
                                                                child: CachedNetworkImage(
                                                                  imageUrl: "${AppConstant.imageUrl}/${finalRxList.isEmpty ? '' : finalRx2.imgLink}",
                                                                  placeholder: (context, url) => Center(child: const CupertinoActivityIndicator()),
                                                                  imageBuilder: (context, imageProvider) => PhotoViewGallery.builder(
                                                                    scrollPhysics: const BouncingScrollPhysics(),
                                                                    pageController: PageController(initialPage: currentIndex),
                                                                    builder: (BuildContext context, int index) {
                                                                      return PhotoViewGalleryPageOptions(
                                                                          imageProvider: imageProvider,
                                                                          initialScale: PhotoViewComputedScale.contained,
                                                                      );
                                                                    },
                                                                    itemCount: finalRxList.length,
                                                                    onPageChanged: (v) {
                                                                      int newIndex = v;
                                                                      int testf = finalRxList.length == newIndex ? finalRxList.length - 1 : newIndex;
                                                                      setState(() {
                                                                        print('3rd testf: $testf');
                                                                        currentIndex = testf;
                                                                        if(finalRxList.isNotEmpty){
                                                                          finalRx2.evfcFg = 5;
                                                                        }

                                                                        saveVisible = false;
                                                                        quarterTurns = 0;
                                                                        rotateDrg = 0;
                                                                      });
                                                                      //start view response
                                                                      viewResponse();
                                                                      //end view response
                                                                      print('3rd currentIndex: $currentIndex');
                                                                    },
                                                                    backgroundDecoration: BoxDecoration(color: AppConstant.backgroundColor),
                                                                  ),
                                                                  errorWidget: (context, url, error) => Center(
                                                                    child: Row(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      children: [
                                                                        Icon(Iconsax.image),
                                                                        Text('  Image not found'),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            //end image

                                                            //start rotate & save
                                                            SizedBox(
                                                              height: 40,
                                                              width: double.infinity,
                                                              child: Row(
                                                                children: [
                                                                  //left
                                                                  Expanded(
                                                                    child: InkWell(
                                                                        onTap: () {
                                                                          setState(() {
                                                                            quarterTurns--;
                                                                          });

                                                                          if (quarterTurns == -4) {
                                                                            setState(() {
                                                                              quarterTurns = 0;
                                                                              rotateDrg = 0;
                                                                              saveVisible = false;
                                                                            });
                                                                          } else {
                                                                            setState(() {
                                                                              rotateDrg = rotateDrg - 90;
                                                                              saveVisible = true;
                                                                            });
                                                                          }
                                                                        },
                                                                        child: Container(
                                                                            height: 40,
                                                                            alignment: Alignment.center,
                                                                            color: AppConstant.primarySwatchColor,
                                                                            child: Icon(
                                                                              Iconsax.rotate_left_1,
                                                                              color: AppConstant.backgroundColor,
                                                                            ))),
                                                                  ),
                                                                  //right
                                                                  Expanded(
                                                                    child: InkWell(
                                                                        onTap: () {
                                                                          setState(() {
                                                                            quarterTurns++;
                                                                          });

                                                                          if (quarterTurns == 4) {
                                                                            setState(() {
                                                                              quarterTurns = 0;
                                                                              rotateDrg = 0;
                                                                              saveVisible = false;
                                                                            });
                                                                          } else {
                                                                            setState(() {
                                                                              rotateDrg = rotateDrg + 90;
                                                                              saveVisible = true;
                                                                            });
                                                                          }
                                                                        },
                                                                        child: Container(
                                                                            height: 40,
                                                                            alignment: Alignment.center,
                                                                            color: AppConstant.primarySwatchColor,
                                                                            child: Icon(
                                                                              Iconsax.rotate_right_1,
                                                                              color: AppConstant.backgroundColor,
                                                                            ))),
                                                                  ),
                                                                  //save
                                                                  saveVisible
                                                                      ? Expanded(
                                                                          child: InkWell(
                                                                              onTap: () {
                                                                                if(finalRxList.isNotEmpty ){
                                                                                  myLoaderDialog(context, '  Saving..');
                                                                                  storeFileFromNetwork(
                                                                                      "${AppConstant.imageUrl}/${finalRx2.imgLink}");
                                                                                  saveVisible = false;
                                                                                }
                                                                              },
                                                                              child: Container(
                                                                                  height: 40,
                                                                                  alignment: Alignment.center,
                                                                                  color: AppConstant.primarySwatchColor,
                                                                                  child: Icon(
                                                                                    Iconsax.tick_square,
                                                                                    color: AppConstant.backgroundColor,
                                                                                  ))),
                                                                        )
                                                                      : SizedBox(),
                                                                ],
                                                              ),
                                                            )
                                                            //end rotate & save
                                                          ],
                                                        );
                                                        },
                                                      ))
                                                  .toList(),
                                              options: CarouselOptions(
                                                  height: MediaQuery.of(context).size.height,
                                                  viewportFraction: 1,
                                                  autoPlay: autoPlayIs,
                                                  initialPage: currentIndex,
                                                  onPageChanged: (index, reason) {
                                                    setState(() {
                                                      currentIndex = index;
                                                      if(finalRxList.isNotEmpty){
                                                        finalRxList[currentIndex].evfcFg = 5;
                                                      }
                                                      saveVisible = false;
                                                      quarterTurns = 0;
                                                      rotateDrg = 0;
                                                    });
                                                    //start view response
                                                    viewResponse();
                                                    //end view response
                                                    print('4th currentIndex: $currentIndex');
                                                  }),
                                            ),
                                          ),
                                        );
                                      });
                                    }).then((value) => setState(() {}));
                              },
                              icon: Icon(
                                Icons.fullscreen,
                                color: AppConstant.backgroundColor,
                              ))),
                      //end tap full image
                    ],
                  ),
                ),
                //end date and view count
              ],
            );
          },
        );
      }).toList(),
    );
  }

  //for Sidebar
  bool viewIs = false;
  bool notViewIs = false;
  bool allRxIs = true;
  List<MyRxList> notViewRxList = [];
  List<MyRxList> viewRxList = [];

  void defaultTab() {
    if (_settingController.defaultRxViewTab == "Pending") {
      viewIs = false;
      selectHospitalIs = false;
      selectHospital = '';
      selectHospitalId = '';
      selectDivision = '';
      selectDistrict = '';
      selectThana = '';
      preferredSize = 0;
      divisionList.clear();
      districtList.clear();
      thanaList.clear();
      hospitalListId.clear();
      hospitalList.clear();
      notViewRxList.clear();
      currentIndex = 0;
      for (var notViewRx in cloneFinalRxList) {
        if (notViewRx.viewingFlag == 0) {
          notViewRxList.add(notViewRx);
        }
      }
      finalRxList = notViewRxList;

      List<String> division = [];
      for (var div in finalRxList) {
        division.add(div.divisionName ?? '');
      }
      //for double values are not allowed
      var seenDivision = <String>{};
      divisionList = division.where((d) => seenDivision.add(d)).toList();
      //for sort division
      divisionList.sort((a, b) => a.compareTo(b));

      //start view response
      viewResponse();
      //end view response

      setState(() {
        notViewIs = true;
        allRxIs = false;
      });
    } else if (_settingController.defaultRxViewTab == "View" && viewRxList.length > 0) {
      selectHospitalIs = false;
      selectHospital = '';
      selectHospitalId = '';
      selectDivision = '';
      selectDistrict = '';
      selectThana = '';
      preferredSize = 0;
      divisionList.clear();
      districtList.clear();
      thanaList.clear();
      hospitalListId.clear();
      hospitalList.clear();
      List<String> division = [];
      viewRxList.clear();
      for (var viewRx in cloneFinalRxList) {
        if (viewRx.viewingFlag != 0) {
          viewRxList.add(viewRx);
          division.add(viewRx.divisionName ?? '');
        }
      }

      finalRxList = viewRxList;
      //for double values are not allowed
      var seenDivision = <String>{};
      divisionList = division.where((d) => seenDivision.add(d)).toList();
      //for sort division
      divisionList.sort((a, b) => a.compareTo(b));

      setState(() {
        notViewIs = false;
        viewIs = true;
        allRxIs = false;
        currentIndex = 0;
      });
    } else {
      viewIs = false;
      selectHospitalIs = false;
      selectHospital = '';
      selectHospitalId = '';
      selectDivision = '';
      selectDistrict = '';
      selectThana = '';
      preferredSize = 0;
      divisionList.clear();
      districtList.clear();
      thanaList.clear();
      hospitalListId.clear();
      hospitalList.clear();
      finalRxList = cloneFinalRxList;
      List<String> division = [];
      currentIndex = 0;
      for (var div in finalRxList) {
        division.add(div.divisionName ?? '');
      }
      //for double values are not allowed
      var seenDivision = <String>{};
      divisionList = division.where((d) => seenDivision.add(d)).toList();
      //for sort division
      divisionList.sort((a, b) => a.compareTo(b));

      //start view response
      viewResponse();
      //end view response

      setState(() {
        allRxIs = true;
        notViewIs = false;
      });
    }
  }



  Widget rxSideBar() {
    return Container(
      color: AppConstant.primarySwatchColor,
      height: double.infinity,
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //All Rx
          InkWell(
            onTap: () {
              viewIs = false;

              if (selectDivision == '') {
                finalRxList = cloneFinalRxList;
                allRxList = cloneFinalRxList;
              } else if (selectDivision != '') {
                finalRxList = filterData();
                allRxList = filterData();
              }

              List<String> division = [];
              for (var div in finalRxList) {
                division.add(div.divisionName ?? '');
              }
              //for double values are not allowed
              var seenDivision = <String>{};
              divisionList = division.where((d) => seenDivision.add(d)).toList();
              //for sort division
              divisionList.sort((a, b) => a.compareTo(b));

              //start view response
              viewResponse();
              //end view response

              setState(() {
                allRxIs = true;
                notViewIs = false;
                currentIndex = 0;
              });
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppConstant.backgroundColor.withOpacity(allRxIs ? 0.1 : 0.0)),
              child: RotatedBox(
                quarterTurns: 3,
                child: Row(
                  children: [
                    Icon(
                      Iconsax.document,
                      color: AppConstant.backgroundColor,
                      size: 18,
                    ),
                    Text(
                      '  ${notViewRxList.length + viewRxList.length}',
                      style: TextStyle(
                        color: AppConstant.backgroundColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          //not view
          InkWell(
            onTap: () {
              viewIs = false;

              currentIndex = 0;

              if (selectDivision == '') {
                notViewRxList.clear();
                for (var notViewRx in cloneFinalRxList) {
                  //not report history selected
                  if (notViewRx.viewingFlag == 0) {
                    notViewRxList.add(notViewRx);
                  }
                }
              }

              finalRxList = notViewRxList; //not report history selected

              List<String> division = [];
              for (var div in finalRxList) {
                division.add(div.divisionName ?? '');
              }
              //for double values are not allowed
              var seenDivision = <String>{};
              divisionList = division.where((d) => seenDivision.add(d)).toList();
              //for sort division
              divisionList.sort((a, b) => a.compareTo(b));

              //start view response
              viewResponse();
              //end view response

              setState(() {
                notViewIs = true;
                allRxIs = false;
              });
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(8),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppConstant.backgroundColor.withOpacity(notViewIs ? 0.1 : 0.0)),
              child: RotatedBox(
                quarterTurns: 3,
                child: Row(
                  children: [
                    Icon(
                      Iconsax.eye_slash,
                      color: AppConstant.backgroundColor,
                      size: 18,
                    ),
                    Text(
                      // '  $unreadRx',
                      '  ${notViewRxList.length}',
                      style: TextStyle(
                        color: AppConstant.backgroundColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          //view
          // readRx == 0
          viewRxList.length == 0
              ? SizedBox()
              : InkWell(
                  onTap: () {
                    List<String> division = [];

                    if (selectDivision == '') {
                      viewRxList.clear();
                      for (var viewRx in cloneFinalRxList) {
                        if (viewRx.viewingFlag != 0) {
                          viewRxList.add(viewRx);
                        }
                      }
                    }

                    finalRxList = viewRxList; //not report history selected

                    //for double values are not allowed
                    var seenDivision = <String>{};
                    for (var div in finalRxList) {
                      division.add(div.divisionName ?? '');
                    }
                    divisionList = division.where((d) => seenDivision.add(d)).toList();
                    divisionList.sort((a, b) => a.compareTo(b));

                    setState(() {
                      notViewIs = false;
                      viewIs = true;
                      allRxIs = false;
                      currentIndex = 0;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(8),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppConstant.backgroundColor.withOpacity(viewIs ? 0.1 : 0.0)),
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.eye,
                            color: AppConstant.backgroundColor,
                            size: 18,
                          ),
                          Text(
                            '  ${viewRxList.length}',
                            // '  $readRx',
                            style: TextStyle(
                              color: AppConstant.backgroundColor,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

          Spacer(),


          //refresh
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: InkWell(
              onTap: () {
                finalRxList.clear();
                fetchRxData();
                setState(() {
                  allRxIs = true;
                  notViewIs = false;
                  viewIs = false;
                  currentIndex = 0;
                });
              },
              child: Icon(
                Iconsax.refresh_circle,
                color: Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //for new add
  List sendVerifyRxInfoPayload = [];
  TextEditingController remarks = TextEditingController();

  void viewResponse()async{
    if (viewIs) {
      print('object viewIs: $viewIs so no need api call to view response');
    } else {
      final prefs = await SharedPreferences.getInstance();
      String getSaUsersId = prefs.getString('saUsersId')??'';

      sendVerifyRxInfoPayload = [
        {
          "feedBackMstId": finalRxList.isEmpty ? 0 : finalRxList[currentIndex].feedBackMstId,
          "rxVerifyBy": getSaUsersId,
          "evfcFg": 5,
          "EvfcRemarks": "",
          "viewTypeFlag": autoPlayIs ? 1 : 2
        }
      ];
      // _newPrescriptionController.sendVerifyRxInfo(context);
      try{
        var url = Uri.parse(AppConstant().verifyRxInfo);
        var response = await http.post(url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(sendVerifyRxInfoPayload));

        // var body = json.decode(response.body);
        switch (response.statusCode) {
          case 200:
            {
              print('object sendVerifyRxInfo success: $sendVerifyRxInfoPayload');
              remarks.clear();
            }
            break;
          default:
            {
              Get.snackbar('Failed', 'To send verify rx info');
            }
        }
      }catch(e){
        // Get.snackbar('Failed', 'To send verify rx info');
        print('object sendVerifyRxInfo Failed');
      }
    }
  }

  //for new date picker
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String showDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());
  DateTime kToday = DateTime.now();
  DateTime kLastDay = DateTime.now();

  String myDay(day) {
    switch (day.day) {
      case 1:
        String convertDay = day.day.toString().replaceAll('1', '01');
        return convertDay;
      case 2:
        String convertDay = day.day.toString().replaceAll('2', '02');
        return convertDay;
      case 3:
        String convertDay = day.day.toString().replaceAll('3', '03');
        return convertDay;
      case 4:
        String convertDay = day.day.toString().replaceAll('4', '04');
        return convertDay;
      case 5:
        String convertDay = day.day.toString().replaceAll('5', '05');
        return convertDay;
      case 6:
        String convertDay = day.day.toString().replaceAll('6', '06');
        return convertDay;
      case 7:
        String convertDay = day.day.toString().replaceAll('7', '07');
        return convertDay;
      case 8:
        String convertDay = day.day.toString().replaceAll('8', '08');
        return convertDay;
      case 9:
        String convertDay = day.day.toString().replaceAll('9', '09');
        return convertDay;
      default:
        return day.day.toString();
    }
  }

  GetPendingRxModel? selectedDayRxCount;
  Future myDatePicker() async {
    _selectedDay = kToday;
    _focusedDay = kToday;
    _pendingRxCountCon.fetchPendingRxCount();
    var pendingRxList = _pendingRxCountCon.pendingRxList.where((element) => element.msRxRecDate == DateFormat('dd-MM-yyyy').format(DateTime.now()));

    if(pendingRxList.isNotEmpty){
      setState((){
        selectedDayRxCount = pendingRxList.elementAt(0);
      });
    }


    return showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
                  content: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: TableCalendar(
                      startingDayOfWeek: StartingDayOfWeek.saturday,
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                      ),
                      shouldFillViewport: true,
                      firstDay: kFirstDay,
                      lastDay: kLastDay,
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      calendarBuilders: CalendarBuilders(
                        holidayBuilder: (context, day, focusedDay) {
                          if (day.day == 20) {}
                          return null;
                        },
                        todayBuilder: (context, date, day) {
                          myDay(date);
                          String generateDate = "${myDay(date)}-${day.month}-${day.year}";
                          var pendingRxList = _pendingRxCountCon.pendingRxList.where((element) => element.msRxRecDate == generateDate);
                          for (var sss in pendingRxList) {
                            return Container(
                              height: 50,
                              width: 50,
                              alignment: Alignment.center,
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: sss.totalRxView == 0
                                          ? Colors.red
                                          : sss.totalViewPending == 0
                                              ? Colors.green
                                              : Colors.amber)),
                              child: Text(date.day.toString()),
                            );
                          }
                          return null;
                        },
                        defaultBuilder: (context, date, day) {
                          myDay(date);
                          String generateDate = "${myDay(date)}-${day.month}-${day.year}";
                          var pendingRxList = _pendingRxCountCon.pendingRxList.where((element) => element.msRxRecDate == generateDate);

                          for (var sss in pendingRxList) {
                            return Container(
                              height: 50,
                              width: 50,
                              alignment: Alignment.center,
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: sss.totalRxView == 0
                                          ? Colors.red
                                          : sss.totalViewPending == 0
                                              ? Colors.green
                                              : Colors.amber)),
                              child: Text(date.day.toString()),
                            );
                          }
                          return null;
                        },
                        markerBuilder: (context, day, event) {
                          myDay(day);
                          String generateDate = "${myDay(day)}-${day.month}-${day.year}";
                          var pendingRxList = _pendingRxCountCon.pendingRxList.where((element) => element.msRxRecDate == generateDate);
                          for (var sss in pendingRxList) {
                            if (sss.msRxRecDate == generateDate) {
                              return sss.totalViewPending == 0
                                  ? SizedBox()
                                  : Container(
                                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                      margin: EdgeInsets.only(left: 40),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(100),
                                        color: sss.totalRxView == 0
                                            ? Colors.red
                                            : sss.totalViewPending == 0
                                                ? Colors.green
                                                : Colors.amber,
                                      ),
                                      child: Text(
                                        "${sss.totalViewPending}",
                                        style: TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    );
                            } else {
                              return SizedBox();
                            }
                          }
                          return null;
                        },
                      ),
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      enabledDayPredicate: (day) {
                        String generateDate = "${myDay(day)}-${day.month}-${day.year}";
                        var pendingRxList = _pendingRxCountCon.pendingRxList.where((element) => element.msRxRecDate == generateDate);
                        bool isFound = false;
                        for (var sss in pendingRxList) {
                          if (sss.msRxRecDate == generateDate) {
                            isFound = true;
                            break;
                          }
                        }
                        return isFound;
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        if (!isSameDay(_selectedDay, selectedDay)) {
                          setState(() {
                            var dt = DateFormat('dd-MM-yyyy').format(selectedDay);
                            var selectedDayRxCount1 = _pendingRxCountCon.pendingRxList.where((element) => element.msRxRecDate == dt);
                            if(selectedDayRxCount1.isNotEmpty){
                              selectedDayRxCount = selectedDayRxCount1.elementAt(0);
                            }

                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        }
                      },
                    ),
                  ),
                  actions: [
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 15,
                          ),
                          //notation
                          CircleAvatar(
                            radius: 5,
                            backgroundColor: Colors.red,
                          ),
                          Text(' All Rx Pending  '),

                          CircleAvatar(
                            radius: 5,
                            backgroundColor: Colors.amber,
                          ),
                          Text(' Some Rx Pending  '),

                          CircleAvatar(
                            radius: 5,
                            backgroundColor: Colors.green,
                          ),
                          Text(' All Rx Viewed  '),

                         // SizedBox(width: 15,),
                          Visibility(visible: selectedDayRxCount != null, child:  Row(
                            children: [
                            //  SizedBox(width: 15,),
                              SizedBox(width: 5,),
                              Text('Total: ${selectedDayRxCount?.totalRx ?? 0}'),
                              SizedBox(width: 5,),
                              Text('Pending: ${selectedDayRxCount?.totalViewPending ?? 0}'),
                              SizedBox(width: 5,),
                              Text('Viewed: ${selectedDayRxCount?.totalRxView ?? 0}')
                            ],
                          )),
                          Spacer(),
                          //button
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel')),
                          TextButton(
                              onPressed: () {
                                showDate = DateFormat('dd-MMM-yyyy').format(_selectedDay ?? DateTime.now());
                                fetchRxData();
                                Navigator.of(context).pop();
                              },
                              child: Text('Ok'))
                        ],
                      ),
                    )
                  ],
                ))).then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    var selectedRX = finalRxList.isEmpty ? MyRxList() : finalRxList[currentIndex];
    return WillPopScope(
        onWillPop: () {
          return backToExit(context);
        },
        child: Scaffold(
          backgroundColor: AppConstant.backgroundColor,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //start select date
                InkWell(
                  onTap: () {
                    myDatePicker();
                  },
                  child: SizedBox(
                    height: 30,
                    child: Center(
                        child: Text(
                      "$showDate  ",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                  ),
                ),
                //end select date

                //start select division
                Expanded(
                  child: DropdownSearch<dynamic>(
                    selectedItem: selectDivision == ''
                        ? selectVisibleIs()
                            ? 'Select Division'
                            : 'Division'
                        : selectDivision,
                    dropdownButtonProps: DropdownButtonProps(
                        icon: selectDivision == ''
                            ? Icon(Icons.arrow_drop_down)
                            : IconButton(
                                onPressed: () {
                                  selectThana = '';
                                  selectDistrict = '';
                                  selectHospital = '';
                                  selectHospitalId = '';
                                  selectHospitalIs = false;
                                  notViewRxList.clear();
                                  viewRxList.clear();
                                  allRxIs = true;
                                  notViewIs = false;
                                  viewIs = false;
                                  setState(() {
                                    selectDivision = '';
                                    //here find district & hospital function
                                    findDistrict();
                                    findHospital();
                                    finalRxList = cloneFinalRxList; //must be open
                                    for (var rx in finalRxList) {
                                      if (rx.viewingFlag == 0) {
                                        notViewRxList.add(rx);
                                      } else {
                                        viewRxList.add(rx);
                                      }
                                    }

                                    preferredSize = 0;
                                  });

                                  //filerSidePanData(finalRxList);
                                },
                                icon: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: AppConstant.backgroundColor,
                                ))),
                    dropdownBuilder: (context, selectedItem) {
                      return Text(
                        selectedItem ?? "",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppConstant.backgroundColor, fontWeight: FontWeight.normal, fontSize: 14),
                      );
                    },
                    popupProps: const PopupProps.menu(showSearchBox: false, fit: FlexFit.loose),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                        textAlignVertical: TextAlignVertical.center,
                        dropdownSearchDecoration: InputDecoration(
                          hintText: 'Division',
                          hintStyle: TextStyle(color: AppConstant.backgroundColor),
                          isDense: true,
                          border: InputBorder.none,
                        )),
                    items: divisionList,
                    onChanged: (v) {
                      selectThana = '';
                      selectDistrict = '';
                      selectHospitalId = '';
                      selectHospital = '';
                      hospitalList.clear();
                      hospitalListId.clear();
                      districtList.clear();
                      currentIndex = 0;
                      selectHospitalIs = false;
                      notViewRxList.clear();
                      viewRxList.clear();
                      currentIndex = 0;
                      allRxIs = true;
                      notViewIs = false;
                      viewIs = false;

                      setState(() {
                        selectDivision = v.toString();
                        //here find district & hospital function
                        findDistrict();
                        findHospital();
                        finalRxList = filterData(); //must be open
                        for (var rx in filterData()) {
                          if (rx.viewingFlag == 0) {
                            notViewRxList.add(rx);
                          } else {
                            viewRxList.add(rx);
                          }
                        }
                      });

                      viewResponse();
                      //filerSidePanData(finalRxList);
                      print("object division: $selectDivision");
                    },
                  ),
                ),
                //end select division

                //start select district
                selectDivision == ''
                    ? SizedBox()
                    : Expanded(
                        child: DropdownSearch<dynamic>(
                          selectedItem: selectDistrict == ''
                              ? selectVisibleIs()
                                  ? 'Select District'
                                  : 'District'
                              : selectDistrict,
                          dropdownButtonProps: DropdownButtonProps(
                              icon: selectDistrict == ''
                                  ? Icon(Icons.arrow_drop_down)
                                  : IconButton(
                                      onPressed: () {
                                        selectThana = '';
                                        selectHospital = '';
                                        selectHospitalId = '';
                                        selectHospitalIs = false;
                                        notViewRxList.clear();
                                        viewRxList.clear();
                                        allRxIs = true;
                                        notViewIs = false;
                                        viewIs = false;
                                        currentIndex = 0;
                                        setState(() {
                                          selectDistrict = '';
                                          findThana();
                                          findHospital();
                                          finalRxList = filterData(); //must be open
                                          preferredSize = 0;
                                          for (var rx in filterData()) {
                                            if (rx.viewingFlag == 0) {
                                              notViewRxList.add(rx);
                                            } else {
                                              viewRxList.add(rx);
                                            }
                                          }
                                        });

                                        viewResponse();
                                        //filerSidePanData(finalRxList);
                                      },
                                      icon: Icon(
                                        Icons.close,
                                        size: 20,
                                        color: AppConstant.backgroundColor,
                                      ))),
                          dropdownBuilder: (context, selectedItem) {
                            return Text(
                              selectedItem ?? "",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppConstant.backgroundColor, fontWeight: FontWeight.normal, fontSize: 14),
                            );
                          },
                          popupProps: const PopupProps.menu(showSearchBox: false, fit: FlexFit.loose),
                          dropdownDecoratorProps: DropDownDecoratorProps(
                              textAlignVertical: TextAlignVertical.center,
                              dropdownSearchDecoration: InputDecoration(hintText: 'District', isDense: true, border: InputBorder.none)),
                          items: districtList,
                          onChanged: (v) {
                            selectThana = '';
                            selectHospitalId = '';
                            selectHospital = '';
                            hospitalList.clear();
                            hospitalListId.clear();
                            notViewRxList.clear();
                            viewRxList.clear();
                            currentIndex = 0;
                            allRxIs = true;
                            notViewIs = false;
                            viewIs = false;

                            setState(() {
                              selectDistrict = v.toString();
                              findThana();
                              findHospital();
                              finalRxList = filterData();
                              preferredSize = slidingPanelVisibleIs() ? 0 : 30;
                              for (var rx in filterData()) {
                                if (rx.viewingFlag == 0) {
                                  notViewRxList.add(rx);
                                } else {
                                  viewRxList.add(rx);
                                }
                              }
                            });
                            viewResponse();
                            //filerSidePanData(finalRxList);
                          },
                        ),
                      ),
                //end select district

                //start select thana
                selectDistrict == ''
                    ? SizedBox()
                    : Expanded(
                        child: DropdownSearch<dynamic>(
                          selectedItem: selectThana == ''
                              ? selectVisibleIs()
                                  ? 'Select Thana'
                                  : 'Thana'
                              : selectThana,
                          dropdownButtonProps: DropdownButtonProps(
                              icon: selectThana == ''
                                  ? Icon(Icons.arrow_drop_down)
                                  : IconButton(
                                      onPressed: () {
                                        selectHospital = '';
                                        selectHospitalId = '';
                                        allRxIs = true;
                                        notViewIs = false;
                                        viewIs = false;
                                        notViewRxList.clear();
                                        viewRxList.clear();
                                        currentIndex = 0;
                                        setState(() {
                                          selectThana = '';
                                          findHospital();
                                          finalRxList = filterData(); //must be open
                                          for (var rx in filterData()) {
                                            if (rx.viewingFlag == 0) {
                                              notViewRxList.add(rx);
                                            } else {
                                              viewRxList.add(rx);
                                            }
                                          }
                                        });
                                        viewResponse();
                                        //filerSidePanData(finalRxList);
                                      },
                                      icon: Icon(
                                        Icons.close,
                                        size: 20,
                                        color: AppConstant.backgroundColor,
                                      ))),
                          dropdownBuilder: (context, selectedItem) {
                            return Text(
                              selectedItem ?? "",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppConstant.backgroundColor, fontWeight: FontWeight.normal, fontSize: 14),
                            );
                          },
                          popupProps: const PopupProps.menu(showSearchBox: false, fit: FlexFit.loose),
                          dropdownDecoratorProps: DropDownDecoratorProps(
                              textAlignVertical: TextAlignVertical.center,
                              dropdownSearchDecoration: InputDecoration(hintText: 'Thana', isDense: true, border: InputBorder.none)),
                          items: thanaList,
                          onChanged: (v) {
                            selectHospital = '';
                            selectHospitalId = '';
                            allRxIs = true;
                            notViewIs = false;
                            viewIs = false;
                            notViewRxList.clear();
                            viewRxList.clear();
                            currentIndex = 0;
                            setState(() {
                              selectThana = v.toString();
                              findHospital();
                              finalRxList = filterData(); //must be open
                              for (var rx in filterData()) {
                                if (rx.viewingFlag == 0) {
                                  notViewRxList.add(rx);
                                } else {
                                  viewRxList.add(rx);
                                }
                              }
                            });
                            viewResponse();
                            //filerSidePanData(finalRxList);
                          },
                        ),
                      ),
                //end select thana

                //start select hospital
                selectDistrict == ''
                    ? SizedBox()
                    : slidingPanelVisibleIs()
                        ? Expanded(
                            flex: 2,
                            child: DropdownSearch<dynamic>(
                              selectedItem: selectHospital == '' ? 'Select Hospital' : selectHospital,
                              dropdownButtonProps: DropdownButtonProps(
                                  icon: selectHospital == ''
                                      ? Icon(Icons.arrow_drop_down)
                                      : IconButton(
                                          onPressed: () {
                                            allRxIs = true;
                                            notViewIs = false;
                                            viewIs = false;
                                            notViewRxList.clear();
                                            viewRxList.clear();
                                            currentIndex = 0;
                                            setState(() {
                                              selectHospital = '';
                                              selectHospitalId = '';
                                              finalRxList = filterData(); //must be open
                                              selectHospitalIs = false;
                                              // titleClick = true;
                                              for (var rx in filterData()) {
                                                if (rx.viewingFlag == 0) {
                                                  notViewRxList.add(rx);
                                                } else {
                                                  viewRxList.add(rx);
                                                }
                                              }
                                            });
                                            viewResponse();
                                            //filerSidePanData(finalRxList);
                                          },
                                          icon: Icon(
                                            Icons.close,
                                            size: 20,
                                            color: AppConstant.backgroundColor,
                                          ))),
                              dropdownBuilder: (context, selectedItem) {
                                return Text(
                                  selectedItem ?? "",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppConstant.backgroundColor, fontWeight: FontWeight.normal, fontSize: 14),
                                );
                              },
                              popupProps: const PopupProps.menu(showSearchBox: true, fit: FlexFit.loose),
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                  textAlignVertical: TextAlignVertical.center,
                                  dropdownSearchDecoration: InputDecoration(hintText: 'Hospital', isDense: true, border: InputBorder.none)),
                              items: hospitalList,
                              onChanged: (v) {
                                allRxIs = true;
                                notViewIs = false;
                                viewIs = false;
                                notViewRxList.clear();
                                viewRxList.clear();
                                currentIndex = 0;
                                setState(() {
                                  selectHospital = v.toString();
                                  for (int i = 0; i < hospitalList.length; i++) {
                                    if (hospitalList[i] == selectHospital) {
                                      selectHospitalId = hospitalListId[i];
                                    }
                                  } //must be open
                                  finalRxList = filterData(); //must be open
                                  selectHospitalIs = true;
                                  titleClick = false;

                                  for (var rx in filterData()) {
                                    if (rx.viewingFlag == 0) {
                                      notViewRxList.add(rx);
                                    } else {
                                      viewRxList.add(rx);
                                    }
                                  }
                                });
                                viewResponse();
                                //filerSidePanData(finalRxList);
                              },
                            ),
                          )
                        : SizedBox()
                //start select hospital
              ],
            ),
            titleSpacing: 0,
            elevation: 0,
            bottom: PreferredSize(
                child: selectDistrict == ''
                    ? SizedBox()
                    : slidingPanelVisibleIs()
                        ? SizedBox()
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Expanded(
                              child: DropdownSearch<dynamic>(
                                selectedItem: selectHospital == '' ? 'Select Hospital' : selectHospital,
                                dropdownButtonProps: DropdownButtonProps(
                                    icon: selectHospital == ''
                                        ? Icon(Icons.arrow_drop_down)
                                        : IconButton(
                                            onPressed: () {
                                              setState(() {
                                                selectHospital = '';
                                                selectHospitalId = '';
                                                finalRxList = filterData(); //must be open
                                                selectHospitalIs = false;
                                                // titleClick = true;
                                              });
                                            },
                                            icon: Icon(
                                              Icons.close,
                                              size: 20,
                                              color: AppConstant.backgroundColor,
                                            ))),
                                dropdownBuilder: (context, selectedItem) {
                                  return Text(
                                    selectedItem ?? "",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppConstant.backgroundColor, fontWeight: FontWeight.w500),
                                  );
                                },
                                popupProps: const PopupProps.menu(showSearchBox: true, fit: FlexFit.loose),
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                    textAlignVertical: TextAlignVertical.center,
                                    dropdownSearchDecoration: InputDecoration(hintText: 'Hospital', isDense: true, border: InputBorder.none)),
                                items: hospitalList,
                                onChanged: (v) {
                                  setState(() {
                                    selectHospital = v.toString();
                                    for (int i = 0; i < hospitalList.length; i++) {
                                      if (hospitalList[i] == selectHospital) {
                                        selectHospitalId = hospitalListId[i];
                                      }
                                    }
                                    finalRxList = filterData(); //must be open
                                    selectHospitalIs = true;
                                    titleClick = false;
                                  });
                                },
                              ),
                            ),
                          ),
                preferredSize: Size.fromHeight(preferredSize)),
            actions: [
              //for autoplay
              _getAppPolicyController.autoSlid.toString() == '1' && finalRxList.isNotEmpty
                  ? autoPlayIs
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              autoPlayIs = false;
                            });
                          },
                          icon: const Icon(Icons.pause_rounded))
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              autoPlayIs = true;
                            });
                          },
                          icon: const Icon(Icons.play_arrow_rounded))
                  : const SizedBox()
            ],
          ),
          drawer: myNewDrawer(context),

          // body: finalRxList.isEmpty && !clickFromSidePane
          body: finalRxList.isEmpty
              ? Center(
                  child: hasData ? const CupertinoActivityIndicator() : const Text('No data found'),
                )
              : slidingPanelVisibleIs()
                  ?
              //for landscape mood
          Container(
                      height: double.infinity,
                      width: double.infinity,
                      child: Row(
                        children: [
                          rxSideBar(),

                          //for rx more info side panel
                          _getAppPolicyController.showRxDetailsSidePanel.value.toString() == "1"?
                          Expanded(
                            flex: 2,
                            child: slidingPanelUpPanel(),
                          ):SizedBox(),
                          _getAppPolicyController.showRxDetailsSidePanel.value.toString() == "1"?
                          VerticalDivider():SizedBox(),
                          //end rx more info side panel

                          //for rx image
                          Expanded(
                            flex: 3,
                            child: slidingPanelUpBody(),
                          ),
                          //end rx image
                        ],
                      ),
                    )
          //end landscape mood
                  :
              //for portrait mood
          SlidingUpPanel(
                      minHeight: 90,
                      maxHeight: panelSized(selectedRX.medDetails!.split('\n').length == 0
                              ? 18
                              : selectedRX.medDetails!.split('\n').length) +
                          73,
                      boxShadow: [BoxShadow(color: Colors.transparent)],
                      onPanelSlide: (position) {
                        setState(() {
                          underImageHeight = position * (100) + 170 + preferredSize;
                        });
                      },
                      panel: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //start only divider
                              Center(
                                child: Container(
                                  margin: EdgeInsets.all(8),
                                  height: 5,
                                  width: 50,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppConstant.shadowColor),
                                ),
                              ),
                              //end only divider

                              Row(
                                children: [
                                  RotatedBox(
                                      quarterTurns: 3,
                                      child: Text(
                                        'Rx Info',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                      )),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        //start show medicine
                                        Html(data: """
                      <html>
<title>Online HTML Editor</title>
<head>
    <style>
        table {
            width: 100%; border-collapse: collapse; align: left;
        }
        
        th {
            border: 1px solid #c6c6c6; text-align: center; padding: 8px;
        }
        td {
            border: 1px solid #dddddd; text-align: center; padding: 2px;
        }
        tr:nth-child(even) {
          background-color: #f8f8f8;
       }
    </style>
</head>
<body>
<table >
    ${finalRxList.isNotEmpty ? selectedRX.medDetails : ' '}
</table>
</body>
</html> 
                      """, style: {
                                          "thead": Style(
                                            backgroundColor: Colors.grey.shade300,
                                          ),
                                        }),
                                        // ),
                                        //end show medicine
                                        SizedBox(
                                          height: 8,
                                        ),
                                        //start performer name
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Text(
                                            "${selectedRX.udCreateBy} ${selectedRX.udCreateBy!.isEmpty ? '' : '::'} ${selectedRX.performerName} ${selectedRX.performerName!.isEmpty ? '' : '::'} ${selectedRX.performDate}",
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        //end performer name
                                        //start capture date
                                        selectedRX.rxCaptureDtTm!.isEmpty
                                            ? SizedBox()
                                            : Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                                child: Text(
                                                    "${selectedRX.rxCaptureDtTm!.isEmpty ? '' : 'Rx Capture Date & Time: ${selectedRX.rxCaptureDtTm}'}"),
                                              ),
                                        //end capture date
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          )),
                      //add GestureDetector only for scroll detect
                      body: GestureDetector(
                        onVerticalDragStart: (dragDetails) {
                          startVerticalDragDetails = dragDetails;
                        },
                        onVerticalDragUpdate: (dragDetails) {
                          updateVerticalDragDetails = dragDetails;
                        },
                        onVerticalDragEnd: (endDetails) {
                          double dx = updateVerticalDragDetails.globalPosition.dx - startVerticalDragDetails.globalPosition.dx;
                          double dy = updateVerticalDragDetails.globalPosition.dy - startVerticalDragDetails.globalPosition.dy;
                          double velocity = endDetails.primaryVelocity ?? 0;

                          //Convert values to be positive
                          if (dx < 0) dx = -dx;
                          if (dy < 0) dy = -dy;

                          if (velocity < 0) {
                            //onSwipeUp();
                            setState(() {
                              titleClick = false;
                            });
                            print("up.....");
                          } else {
                            setState(() {
                              titleClick = true;
                            });
                            print("down.....");
                            //onSwipeDown();
                          }
                        },
                        child: CarouselSlider(
                          options: CarouselOptions(
                              height: MediaQuery.of(context).size.height,
                              autoPlay: autoPlayIs,
                              autoPlayInterval: Duration(seconds: _getAppPolicyController.autoPlayInterval.value),
                              viewportFraction: 1,
                              initialPage: currentIndex,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  currentIndex = index;
                                  selectedRX.evfcFg = 5;
                                  saveVisible = false;
                                  quarterTurns = 0;
                                  rotateDrg = 0;
                                });
                                //start view response
                                viewResponse();
                                //end view response
                              }),
                          items: finalRxList.map((i) {
                            return Builder(
                              builder: (BuildContext context) {
                                hasData = true;
                                var rx = selectedRX;
                                return Column(
                                  children: [
                                    //start content
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          // start hospital name
                                          titleClick
                                              ? selectHospitalIs
                                                  ? SizedBox()
                                                  : HtmlWidget(
                                                      "${rx.hosCareName}",
                                                      textStyle: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    )
                                              : SizedBox(),
                                          // end hospital name

                                          // start hospital address
                                          titleClick
                                              ? selectHospitalIs
                                                  ? SizedBox()
                                                  : Text(rx.hcpAddress ?? '')
                                              : SizedBox(),
                                          // end hospital address

                                          Text(
                                            "${rx.drName} ${rx.drName!.isEmpty ? '' : '::'} ${rx.drDegree} ${rx.drDegree!.isEmpty ? '' : '::'} ${rx.speciality}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //end content

                                    //start image
                                    Expanded(
                                        child: InkWell(
                                      onTap: () {
                                        quarterTurns = 0;
                                        saveVisible = false;
                                        rotateDrg = 0;
                                        showGeneralDialog(
                                            context: context,
                                            barrierColor: Colors.black12.withOpacity(0.6),
                                            barrierDismissible: false,
                                            barrierLabel: 'Dialog',
                                            transitionDuration: const Duration(milliseconds: 400),
                                            pageBuilder: (_, __, ___) {
                                              return StatefulBuilder(builder: (context, setState) {
                                                return Material(
                                                  child: SafeArea(
                                                    child: CarouselSlider(
                                                      items: finalRxList
                                                          .map((e) => Builder(
                                                                builder: (context) {
                                                                  var myRx = rx;
                                                                  return Column(
                                                                  children: [
                                                                    //start content & cross
                                                                    Container(
                                                                      color: AppConstant.backgroundColor,
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          //start content
                                                                          Expanded(
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(myRx.hosCareName ?? ''),
                                                                                  Text(myRx.hcpAddress ?? ''),
                                                                                  Text(
                                                                                      "${myRx.drName} ${myRx.drName!.isEmpty ? '' : '::'} ${myRx.drDegree} ${myRx.drDegree!.isEmpty ? '' : '::'} ${myRx.speciality}"),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          //end content

                                                                          //start cross
                                                                          IconButton(
                                                                              onPressed: () {
                                                                                quarterTurns = 0;
                                                                                saveVisible = false;
                                                                                rotateDrg = 0;
                                                                                Navigator.pop(context);
                                                                                setState(() {
                                                                                  currentIndex = currentIndex;
                                                                                });
                                                                              },
                                                                              icon: Icon(
                                                                                Iconsax.close_circle,
                                                                                color: Colors.red,
                                                                              )),
                                                                          //end cross
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    //end content & cross

                                                                    //start image
                                                                    Expanded(
                                                                      child: RotatedBox(
                                                                        quarterTurns: quarterTurns,
                                                                        child: CachedNetworkImage(
                                                                          imageUrl: "${AppConstant.imageUrl}/${myRx.imgLink}",
                                                                          placeholder: (context, url) =>
                                                                              Center(child: const CupertinoActivityIndicator()),
                                                                          imageBuilder: (context, imageProvider) => Stack(
                                                                              alignment:
                                                                                  currentIndex == 0 ? Alignment.centerLeft : Alignment.centerRight,
                                                                              children: [
                                                                                RotatedBox(
                                                                                    quarterTurns: currentIndex == 0 ? 3 : 1,
                                                                                    child: Text(
                                                                                      currentIndex == 0
                                                                                          ? 'This is the first Rx of the base criteria'
                                                                                          : 'This is the last Rx of the base criteria',
                                                                                      style: TextStyle(color: Colors.redAccent),
                                                                                    )),
                                                                                PhotoViewGallery.builder(
                                                                                  scrollPhysics: const BouncingScrollPhysics(),
                                                                                  pageController: PageController(initialPage: currentIndex),
                                                                                  builder: (BuildContext context, int index) {
                                                                                    return PhotoViewGalleryPageOptions(
                                                                                      imageProvider: imageProvider,
                                                                                      initialScale: PhotoViewComputedScale.contained,
                                                                                    );
                                                                                  },
                                                                                  itemCount: finalRxList.length,
                                                                                  onPageChanged: (v) {
                                                                                    int newIndex = v;
                                                                                    int testIndex = finalRxList.length == newIndex
                                                                                        ? finalRxList.length - 1
                                                                                        : newIndex;
                                                                                    setState(() {
                                                                                      currentIndex = testIndex;
                                                                                      myRx.evfcFg = 5;
                                                                                      saveVisible = false;
                                                                                      quarterTurns = 0;
                                                                                      rotateDrg = 0;
                                                                                    });
                                                                                    //start view response
                                                                                    viewResponse();
                                                                                    //end view response
                                                                                  },
                                                                                  backgroundDecoration:
                                                                                      BoxDecoration(color: AppConstant.backgroundColor),
                                                                                ),
                                                                              ]),
                                                                          errorWidget: (context, url, error) => Center(
                                                                            child: Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Icon(Iconsax.image),
                                                                                Text('  Image not found'),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    //end image

                                                                    //start rotate & save
                                                                    SizedBox(
                                                                      height: 40,
                                                                      width: double.infinity,
                                                                      child: Row(
                                                                        children: [
                                                                          //left
                                                                          Expanded(
                                                                            child: InkWell(
                                                                                onTap: () {
                                                                                  setState(() {
                                                                                    quarterTurns--;
                                                                                  });

                                                                                  if (quarterTurns == -4) {
                                                                                    setState(() {
                                                                                      quarterTurns = 0;
                                                                                      rotateDrg = 0;
                                                                                      saveVisible = false;
                                                                                    });
                                                                                  } else {
                                                                                    setState(() {
                                                                                      rotateDrg = rotateDrg - 90;
                                                                                      saveVisible = true;
                                                                                    });
                                                                                  }
                                                                                },
                                                                                child: Container(
                                                                                    height: 40,
                                                                                    alignment: Alignment.center,
                                                                                    color: AppConstant.primarySwatchColor,
                                                                                    child: Icon(
                                                                                      Iconsax.rotate_left_1,
                                                                                      color: AppConstant.backgroundColor,
                                                                                    ))),
                                                                          ),
                                                                          //right
                                                                          Expanded(
                                                                            child: InkWell(
                                                                                onTap: () {
                                                                                  setState(() {
                                                                                    quarterTurns++;
                                                                                  });

                                                                                  if (quarterTurns == 4) {
                                                                                    setState(() {
                                                                                      quarterTurns = 0;
                                                                                      rotateDrg = 0;
                                                                                      saveVisible = false;
                                                                                    });
                                                                                  } else {
                                                                                    setState(() {
                                                                                      rotateDrg = rotateDrg + 90;
                                                                                      saveVisible = true;
                                                                                    });
                                                                                  }
                                                                                },
                                                                                child: Container(
                                                                                    height: 40,
                                                                                    alignment: Alignment.center,
                                                                                    color: AppConstant.primarySwatchColor,
                                                                                    child: Icon(
                                                                                      Iconsax.rotate_right_1,
                                                                                      color: AppConstant.backgroundColor,
                                                                                    ))),
                                                                          ),
                                                                          //save
                                                                          saveVisible
                                                                              ? Expanded(
                                                                                  child: InkWell(
                                                                                      onTap: () {
                                                                                        myLoaderDialog(context, '  Saving..');
                                                                                        storeFileFromNetwork(
                                                                                            "${AppConstant.imageUrl}/${myRx.imgLink}");
                                                                                        saveVisible = false;
                                                                                      },
                                                                                      child: Container(
                                                                                          height: 40,
                                                                                          alignment: Alignment.center,
                                                                                          color: AppConstant.primarySwatchColor,
                                                                                          child: Icon(
                                                                                            Iconsax.tick_square,
                                                                                            color: AppConstant.backgroundColor,
                                                                                          ))),
                                                                                )
                                                                              : SizedBox(),
                                                                        ],
                                                                      ),
                                                                    )
                                                                    //end rotate & save
                                                                  ],
                                                                );
                                                                },
                                                              ))
                                                          .toList(),
                                                      options: CarouselOptions(
                                                          height: MediaQuery.of(context).size.height,
                                                          viewportFraction: 1,
                                                          autoPlay: autoPlayIs,
                                                          initialPage: currentIndex,
                                                          onPageChanged: (index, reason) {
                                                            setState(() {
                                                              currentIndex = index;
                                                              rx.evfcFg = 5;
                                                              saveVisible = false;
                                                              quarterTurns = 0;
                                                              rotateDrg = 0;
                                                            });
                                                            //start view response
                                                            viewResponse();
                                                            //end view response
                                                            print('4th currentIndex: $currentIndex');
                                                          }),
                                                    ),
                                                  ),
                                                );
                                              });
                                            }).then((value) => setState(() {}));
                                      },
                                      child: Stack(
                                        alignment: Alignment.topCenter,
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: "${AppConstant.imageUrl}/${rx.imgLink}",
                                            placeholder: (context, url) => Center(child: const CupertinoActivityIndicator()),
                                            imageBuilder: (context, imageProvider) =>
                                                Stack(alignment: currentIndex == 0 ? Alignment.centerLeft : Alignment.centerRight, children: [
                                              RotatedBox(
                                                  quarterTurns: currentIndex == 0 ? 3 : 1,
                                                  child: Text(
                                                    currentIndex == 0
                                                        ? 'This is the first Rx of the base criteria'
                                                        : 'This is the last Rx of the base criteria',
                                                    style: TextStyle(color: Colors.redAccent),
                                                  )),
                                              PhotoViewGallery.builder(
                                                scrollPhysics: const BouncingScrollPhysics(),
                                                pageController: PageController(initialPage: currentIndex),
                                                builder: (BuildContext context, int index) {
                                                  return PhotoViewGalleryPageOptions(
                                                    imageProvider: imageProvider,
                                                    // controller: zoomController,
                                                    initialScale: PhotoViewComputedScale.contained,
                                                  );
                                                },
                                                itemCount: finalRxList.length,
                                                onPageChanged: (v) {
                                                  int newIndex = v;
                                                  int testIndex = finalRxList.length == newIndex ? finalRxList.length - 1 : newIndex;
                                                  setState(() {
                                                    currentIndex = testIndex;
                                                    rx.evfcFg = 5;
                                                    saveVisible = false;
                                                    quarterTurns = 0;
                                                    rotateDrg = 0;
                                                  });
                                                  //start view response
                                                  viewResponse();
                                                  //end view response
                                                },
                                                backgroundDecoration: BoxDecoration(color: AppConstant.backgroundColor),
                                              ),
                                            ]),
                                            errorWidget: (context, url, error) => Center(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Iconsax.image),
                                                  Text('  Image not found'),
                                                ],
                                              ),
                                            ),
                                          ),

                                          //for date and view count
                                          SizedBox(
                                            width: double.infinity,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [

                                                //this is new add
                                                Container(
                                                  padding: EdgeInsets.all(5),
                                                  margin: EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(5),
                                                    color: Colors.black26,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      finalRxList.isEmpty || finalRxList[currentIndex].viewingFlag == 0
                                                          ? Icon(Iconsax.eye_slash, size: 14, color: AppConstant.backgroundColor)
                                                          : Icon(Iconsax.eye, size: 14, color: AppConstant.backgroundColor),
                                                      Text(
                                                        '${currentIndex + 1}/${finalRxList.length}',
                                                        style: TextStyle(fontWeight: FontWeight.w500, color: AppConstant.backgroundColor),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    )),

                                    //end image
                                    SizedBox(
                                      height: underImageHeight,
                                    )
                                  ],
                                );
                              },
                            );
                          }).toList(),
                        ),
                      )),
          //end portrait mood
          floatingActionButton: finalRxList.isNotEmpty
              ? FloatingActionButton.small(
                  onPressed: () {
                    shareRemark = '';
                    userRole = '';
                    mkgProfNo = '';
                    rxShareFlag = 1;
                    shareId = 0;
                    sendRemarksPayload.clear();
                    oneTime = true;
                    //start get shareable user
                    var rx = selectedRX;
                    if (rx.thanaName!.isNotEmpty) {
                      getShareableUser(rx.thanaName ?? '');
                    } else if (rx.districtName!.isNotEmpty) {
                      getShareableUser(rx.districtName ?? '');
                    } else if (rx.divisionName!.isNotEmpty) {
                      getShareableUser(rx.divisionName ?? '');
                    } else {
                      getShareableUser('');
                    }
                    //end get shareable user
                  },
                  child: const Icon(Iconsax.send_2),
                  backgroundColor: selectedRX.totalShare! > 0 ? Colors.blue : AppConstant.primarySwatchColor,
                )
              : SizedBox(),
          floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        ));
  }

}
