import 'package:flutter/cupertino.dart';
import 'package:rx_view/components/back_to_exit.dart';
import 'package:rx_view/controllers/app_policy/app_policy_con.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rx_view/commons/Constant.dart';
import 'package:rx_view/components/my_new_drawer.dart';
import 'package:rx_view/controllers/app_policy/get_app_policy_con.dart';
import 'package:rx_view/controllers/setting/setting_con.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  final AppPolicyController _appPolicyController = Get.put(AppPolicyController());
  final SettingController _controller = Get.put(SettingController());
  final GetAppPolicyController _getAppPolicyController = Get.put(GetAppPolicyController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _appPolicyController.getAppPolicy();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: ()=>backToExit(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Setting'),
          elevation: 0,
        ),
        drawer: myNewDrawer(context),
        // drawer: myDrawer(context),
        body: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            //start rx info side panel
            /*
            Container(
              margin: const EdgeInsets.only(
                  top: 12,
                  left: 10,
                  right: 10),
              decoration: BoxDecoration(
                color: AppConstant.backgroundColor,
                borderRadius:
                const BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: AppConstant.shadowColor.withAlpha(26),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ExpansionTile(
                leading: const Icon(Iconsax.document5),
                title: const Text('Show Rx Details Panel'),
                trailing: Obx(
                      () => CupertinoSwitch(
                      value: _controller.rxInfoSideVisible.value,
                      onChanged: (v) {
                        _controller.rxInfoSideVisible.value = v;
                        _controller.tempSaveSetting();
                      }),
                ),
              ),
            ),

             */
            //end rx info side panel

            //start refresh alert
            Container(
              margin: const EdgeInsets.only(
                  top: 12,
                  left: 10,
                  right: 10),
              decoration: BoxDecoration(
                color: AppConstant.backgroundColor,
                borderRadius:
                const BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: AppConstant.shadowColor.withAlpha(26),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ExpansionTile(
                leading: const Icon(Iconsax.refresh_25),
                title: const Text('Rx Refresh Alert'),
                subtitle: Obx(() =>
                    Text("Status: ${_controller.refreshAlertIs.isTrue?'On':'Off'}  ${_controller.refreshAlertIs.isTrue?"Duration: ${_controller.refreshAlertDuration.value} Minutes":''}",style: TextStyle(color: AppConstant.disableTextColor))
                ),
                trailing: Obx(
                      () => CupertinoSwitch(
                      value: _controller.refreshAlertIs.value,
                      onChanged: (v) {
                        _controller.refreshAlertIs.value = v;
                        _controller.tempSaveSetting();
                      }),
                ),
                children: [
                  const Divider(),
                  //for division
                  Obx(
                        () => RadioListTile(
                          title: Text("5 Minutes"),
                          value: '5',
                          groupValue: _controller.refreshAlertDuration.value,
                          onChanged: (value){
                            setState(() {
                              _controller.refreshAlertDuration.value = value.toString();
                            });
                            _controller.tempSaveSetting();
                          },
                        ),
                  ),
                  Obx(
                        () => RadioListTile(
                      title: Text("10 Minutes"),
                      value: '10',
                      groupValue: _controller.refreshAlertDuration.value,
                      onChanged: (value){
                        setState(() {
                          _controller.refreshAlertDuration.value = value.toString();
                        });
                        _controller.tempSaveSetting();
                      },
                    ),
                  ),

                ],
              ),
            ),
            //end refresh alert

            //start auto slider time
            _getAppPolicyController.autoSlid.toString()=='0'?
                const SizedBox():
            Container(
              margin: const EdgeInsets.only(
                  top: 12,
                  left: 10,
                  right: 10),
              decoration: BoxDecoration(
                color: AppConstant.backgroundColor,
                borderRadius:
                const BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: AppConstant.shadowColor.withAlpha(26),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ExpansionTile(
                  leading: const Icon(Iconsax.slider5),
                  title: const Text('Rx Auto Play Interval'),
                subtitle: Text('Duration: ${_getAppPolicyController.autoPlayInterval.toString()} Seconds',style: TextStyle(color: AppConstant.disableTextColor),),
                  children: [
                    const Divider(),
                    Obx(
                          () => RadioListTile(
                        title: Text("8 Seconds"),
                        value: 8,
                        groupValue: _getAppPolicyController.autoPlayInterval.value,
                        onChanged: (value){
                          setState(() {
                            _getAppPolicyController.autoPlayInterval.value = int.parse(value.toString());
                          });
                        },
                      ),
                    ),

                    Obx(
                          () => RadioListTile(
                        title: Text("12 Seconds"),
                        value: 12,
                        groupValue: _getAppPolicyController.autoPlayInterval.value,
                        onChanged: (value){
                          setState(() {
                            _getAppPolicyController.autoPlayInterval.value = int.parse(value.toString());
                          });
                        },
                      ),
                    ),

                    Obx(
                          () => RadioListTile(
                        title: Text("16 Seconds"),
                        value: 16,
                        groupValue: _getAppPolicyController.autoPlayInterval.value,
                        onChanged: (value){
                          setState(() {
                            _getAppPolicyController.autoPlayInterval.value = int.parse(value.toString());
                          });
                        },
                      ),
                    ),

                    Obx(
                          () => RadioListTile(
                        title: Text("20 Seconds"),
                        value: 20,
                        groupValue: _getAppPolicyController.autoPlayInterval.value,
                        onChanged: (value){
                          setState(() {
                            _getAppPolicyController.autoPlayInterval.value = int.parse(value.toString());
                          });
                        },
                      ),
                    ),
                  ],
              ),
            ),
            //end auto slider time


            //start default tab open
            Container(
              margin: const EdgeInsets.only(
                  top: 12,
                  left: 10,
                  right: 10),
              decoration: BoxDecoration(
                color: AppConstant.backgroundColor,
                borderRadius:
                const BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: AppConstant.shadowColor.withAlpha(26),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ExpansionTile(
                leading: const Icon(Iconsax.directbox_default5),
                title: const Text('Default Rx View'),
                subtitle: Text('Mode: ${_controller.defaultRxViewTab.toString()}',style: TextStyle(color: AppConstant.disableTextColor),),
                children: [
                  const Divider(),
                  Obx(
                        () => RadioListTile(
                      title: Text("All"),
                      value: 'All',
                      groupValue: _controller.defaultRxViewTab.toString(),
                      onChanged: (value){
                        setState(() {
                          _controller.defaultRxViewTab.value = value.toString();
                        });
                        _controller.tempSaveSetting();
                      },
                    ),
                  ),
                  Obx(
                        () => RadioListTile(
                      title: Text("Pending"),
                      value: 'Pending',
                      groupValue: _controller.defaultRxViewTab.toString(),
                      onChanged: (value){
                        setState(() {
                          _controller.defaultRxViewTab.value = value.toString();
                        });
                        _controller.tempSaveSetting();
                      },
                    ),
                  ),
                  Obx(
                        () => RadioListTile(
                      title: Text("View"),
                      value: 'View',
                      groupValue: _controller.defaultRxViewTab.toString(),
                      onChanged: (value){
                        setState(() {
                          _controller.defaultRxViewTab.value = value.toString();
                        });
                        _controller.tempSaveSetting();
                      },
                    ),
                  ),
                ],
              ),
            ),
            //end default tab open

            //start calender view duration
            Container(
              margin: const EdgeInsets.only(
                  top: 12,
                  left: 10,
                  right: 10),
              decoration: BoxDecoration(
                color: AppConstant.backgroundColor,
                borderRadius:
                const BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: AppConstant.shadowColor.withAlpha(26),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ExpansionTile(
                leading: const Icon(Iconsax.calendar5),
                title: const Text('Rx View Calender Range'),
                subtitle: Text("Duration: ${int.parse(_controller.calenderMonthDuration.toString()) < 3?
                '${int.parse(_controller.calenderMonthDuration.toString())+1} Months':
                // '${int.parse(_controller.calenderMonthDuration.toString())} Months':
                '${int.parse(_controller.calenderDayDuration.toString())} Days'}",style: TextStyle(color: AppConstant.disableTextColor),),
                children: [
                  const Divider(),
                  Obx(
                        () => RadioListTile(
                      title: Text("7 Days"),
                      value: '7',
                      groupValue: _controller.calenderMonthDuration.toString(),
                      onChanged: (value){
                        setState(() {
                          _controller.calenderMonthDuration.value = value.toString();
                          _controller.calenderDayDuration.value = value.toString();
                        });
                        _controller.tempSaveSetting();
                      },
                    ),
                  ),
                  Obx(
                        () => RadioListTile(
                      title: Text("15 Days"),
                      value: '15',
                      groupValue: _controller.calenderMonthDuration.toString(),
                      onChanged: (value){
                        setState(() {
                          _controller.calenderMonthDuration.value = value.toString();
                          _controller.calenderDayDuration.value = value.toString();
                        });
                        _controller.tempSaveSetting();
                      },
                    ),
                  ),
                  Obx(
                        () => RadioListTile(
                      title: Text("1 Months"),
                      value: '0',
                      groupValue: _controller.calenderMonthDuration.toString(),
                      onChanged: (value){
                        setState(() {
                          _controller.calenderMonthDuration.value = value.toString();
                          _controller.calenderDayDuration.value = '30';
                        });
                        _controller.tempSaveSetting();
                        print('object _controller.calenderMonthDuration.value: ${_controller.calenderMonthDuration.value}');
                      },
                    ),
                  ),
                  Obx(
                        () => RadioListTile(
                      title: Text("2 Months"),
                      value: '1',
                      groupValue: _controller.calenderMonthDuration.toString(),
                      onChanged: (value){
                        setState(() {
                          _controller.calenderMonthDuration.value = value.toString();
                          _controller.calenderDayDuration.value = '0';
                        });
                        _controller.tempSaveSetting();
                      },
                    ),
                  ),
                  Obx(
                        () => RadioListTile(
                      title: Text("3 Months"),
                      value: '2',
                      groupValue: _controller.calenderMonthDuration.toString(),
                      onChanged: (value){
                        setState(() {
                          _controller.calenderMonthDuration.value = value.toString();
                          _controller.calenderDayDuration.value = '0';
                        });
                        _controller.tempSaveSetting();
                      },
                    ),
                  ),
                ],
              ),
            ),
            //end calender view duration

            /*
            //start zone
            Container(
              margin: const EdgeInsets.only(
                  top: 12,
                  left: 10,
                  right: 10),
              decoration: BoxDecoration(
                color: AppConstant.backgroundColor,
                borderRadius:
                const BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: AppConstant.shadowColor.withAlpha(26),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ExpansionTile(
                leading: const Icon(Iconsax.location5),
                title: const Text('Filter By Administrative Geography of Bangladesh in Rx Details'),
                subtitle: Obx(() =>
                _controller.zoneVisible.isTrue?
                Text(
                    "Open:${_controller.divisionVisible.isTrue ? 'Division' : ''}${_controller.districtVisible.isTrue ? ',District' : ''}${_controller.thanaVisible.isTrue ? ',Thana' : ''}",style: TextStyle(color: AppConstant.disableTextColor))
                    :const SizedBox()),
                trailing: Obx(
                      () => CupertinoSwitch(
                      value: _controller.zoneVisible.value,
                      onChanged: (v) {
                        _controller.zoneVisible.value = v;
                        _controller.divisionVisible.value = v;
                        _controller.districtVisible.value = v;
                        _controller.thanaVisible.value = v;
                      }),
                ),
                children: [
                  const Divider(),
                  //for division
                  Obx(
                        () => SwitchListTile(
                        title: const Text('Division'),
                        value: _controller.divisionVisible.value,
                        onChanged: (v) {
                          _controller.divisionVisible.value = v;
                          _controller.updateZoneVisible();
                        }),
                  ),

                  // const Divider(),
                  //for district
                  Obx(
                        () => SwitchListTile(
                        title: const Text('District'),
                        value: _controller.divisionVisible.value == true
                            ? _controller.districtVisible.value
                            : false,
                        onChanged: (v) {
                          if (_controller.divisionVisible.value == true) {
                            _controller.districtVisible.value = v;
                            _controller.thanaVisible.value = false;
                            _controller.updateZoneVisible();
                          } else {
                            Get.snackbar('Warning', 'At first open division');
                          }
                        }),
                  ),

                  // const Divider(),
                  //for thana
                  Obx(
                        () => SwitchListTile(
                        title: const Text('Thana'),
                        value: _controller.districtVisible.value == true &&
                            _controller.divisionVisible.value == true
                            ? _controller.thanaVisible.value
                            : false,
                        onChanged: (v) {
                          if (_controller.districtVisible.value == true &&
                              _controller.divisionVisible.value == true) {
                            _controller.thanaVisible.value = v;
                            _controller.updateZoneVisible();
                          } else {
                            Get.snackbar('Warning', 'At first open district');
                          }
                        }),
                  ),
                ],
              ),
            ),
            //end zone

            //start hospital
            Container(
              margin: const EdgeInsets.only(
                  top: 12,
                  left: 10,
                  right: 10),
              decoration: BoxDecoration(
                color: AppConstant.backgroundColor,
                borderRadius:
                const BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: AppConstant.shadowColor.withAlpha(26),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                  leading: const Icon(Iconsax.hospital5),
                  title: const Text('Filter By Hospital in Rx Details'),
                  trailing: Obx(
                        () => CupertinoSwitch(
                        value: _controller.hospitalVisible.value,
                        onChanged: (v) {
                          _controller.hospitalVisible.value = v;
                        }),
                  )),
            ),
            //end hospital

            //start Performer
            Container(
              margin: const EdgeInsets.only(
                  top: 12,
                  left: 10,
                  right: 10),
              decoration: BoxDecoration(
                color: AppConstant.backgroundColor,
                borderRadius:
                const BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: AppConstant.shadowColor.withAlpha(26),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                  leading: const Icon(Iconsax.profile_2user5),
                  title: const Text('Filter By Performer in Rx Details'),
                  trailing: Obx(
                        () =>
                        CupertinoSwitch(
                            value: _controller.performerVisible.value,
                            onChanged: (v) {
                              _controller.performerVisible.value = v;
                            }),
                  )),
            ),
            //end Performer

             */
            SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }
}
