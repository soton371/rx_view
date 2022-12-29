import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:battery_info/battery_info_plugin.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:disk_space/disk_space.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rx_view/commons/Constant.dart';
import 'package:rx_view/models/my_device_info/my_device_info_model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:root/root.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_info2/system_info2.dart';

class MyDeviceInfoController extends GetxController{
  var userDeviceId = ''.obs;
  var phnFreeStorage = 0.0.obs;
  var phnStorage = 0.0.obs;
  var ram = ''.obs;
  var freeRam = ''.obs;
  var betteryCapacity = ''.obs;
  var rootedId = false.obs;
  var appId = ''.obs;
  // var versionCode = ''.obs;
  var osType = ''.obs;
  // var buildNumber  = ''.obs;


  //for device info
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> deviceDataInfo = <String, dynamic>{};

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
    deviceDataInfo = deviceData;
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Future<void> initDiskSpace() async {
    double diskSpace = 0;
    double diskSpaceAll = 0;

    diskSpace = (await DiskSpace.getFreeDiskSpace)!;
    diskSpaceAll = (await DiskSpace.getTotalDiskSpace)!;

    phnFreeStorage.value = diskSpace;
    phnStorage.value = diskSpaceAll;


  }

  int megaByte = 1024 * 1024;

  Future<void> fetchInfo()async{
    betteryCapacity.value = (await BatteryInfoPlugin().androidBatteryInfo)!.batteryCapacity.toString();

    var pram = '${SysInfo.getTotalPhysicalMemory() ~/ megaByte}';
    var vram = '${SysInfo.getTotalVirtualMemory() ~/ megaByte}';
    ram.value = (int.parse(pram)+int.parse(vram)).toString();
    var pfram = '${SysInfo.getFreePhysicalMemory() ~/ megaByte}';
    var vfram = '${SysInfo.getFreeVirtualMemory() ~/ megaByte}';
    freeRam.value = (int.parse(pfram)+int.parse(vfram)).toString();
    rootedId.value = (await Root.isRooted())!;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appId.value=packageInfo.packageName;
    // buildNumber.value = packageInfo.buildNumber;

    // versionCode.value = Platform.operatingSystemVersion.toString();
    osType.value = Platform.operatingSystem.toString();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initPlatformState();
    fetchInfo();
    initDiskSpace();
    //insertDeviceInfo();
  }

  Future<void> insertDeviceInfo(String deviceIdPk)async{
      var url = Uri.parse(AppConstant().insertDeviceInfoUrl);
      Map playLoad = {
        "deviceIdPk":deviceIdPk.toString(),
        "manufacturer":deviceDataInfo['manufacturer'].toString(),
        "brand":deviceDataInfo['brand'].toString(),
        "deviceModel":deviceDataInfo['model'].toString(),
        "deviceType":deviceDataInfo['type'].toString(),
        "osType":osType.toString(),
        "board":deviceDataInfo['board'].toString(),
        "buildId":deviceDataInfo['id'].toString(),
        "display":deviceDataInfo['display'].toString(),
        "product":deviceDataInfo['product'].toString(),
        "device":deviceDataInfo['device'].toString(),
        "socManufacturer":deviceDataInfo['manufacturer'].toString(),
        "socModel":deviceDataInfo['model'].toString(),
        "bootloader":deviceDataInfo['bootloader'].toString(),
        "hardware":deviceDataInfo['hardware'].toString(),
        "sku":'null',
        "odmSku":'null',
        "supportedAbis":deviceDataInfo['supportedAbis'].toString(),
        "supported32BitAbis":deviceDataInfo['supported32BitAbis'].toString(),
        "supported64BitAbis":deviceDataInfo['supported64BitAbis'].toString(),
        "release":deviceDataInfo['version.release'].toString(),
        "baseOs":osType.toString(),
        "securityPatch":deviceDataInfo['version.securityPatch'].toString(),
        "mediaPerformanceClass":'null',
        "sdkInt":deviceDataInfo['version.sdkInt'].toString(),
        "minSupportedTargetSdkInt":deviceDataInfo['version.previewSdkInt'].toString(),
        "tags":deviceDataInfo['tags'].toString(),
        "fingerprint":deviceDataInfo['fingerprint'].toString(),
        "buildTime":'null',
        "deviceHost":deviceDataInfo['host'].toString(),
        "deviceUser":'null',
        "isRooted":rootedId.toString(),
        "phnStorage":'${phnStorage.toString()} MB',
        "sdCardStorage":'null',
        "cpu":'null',
        "gpu":'null',
        "ram":'${ram.toString()} MB',
        "freeRam":'${freeRam.toString()} MB',
        "freePhnStorage":'${phnFreeStorage.toString()} MB',
        "freeSdCardStorage":'null',
        "androidVersionName":deviceDataInfo['version.codename'].toString(),
        "androidVersionCode":deviceDataInfo['version.sdkInt'].toString(),
        "isFingerSupport":"1",
        "defaultLanguage":'null',
        "deviceId":deviceDataInfo['id'].toString(),
        "fcmId":'null',
        "sensor":'null',
        "screenSize":'null',
        "blutoothVersion":'null',
        "wifiVersion":'null',
        "suppoertedNetwork":'null',
        "betteryCapacity":betteryCapacity.toString(),
        "totalInstalledApp":'null',
        "appId":Platform.isAndroid?"1":"2",
        "userId":'null',
        "udUserId":'null',
        "companyId":'null',
        "branchId":'null',
        "unitId":'null'
      };

      print('object playLoad: $playLoad');

      var response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(playLoad)
      );

      final myDeviceInfoModel = myDeviceInfoModelFromJson(response.body);
      var statusCode = myDeviceInfoModel.statusCode;

      switch(statusCode){
        case 200:{
          userDeviceId.value = myDeviceInfoModel.objResponse!.deviceIdPk.toString();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('deviceIdPk', int.parse(myDeviceInfoModel.objResponse!.deviceIdPk.toString()));
          print('object Success insertDeviceInfo');
          // print('object playload: $playLoad');
        }
        break;
        default:{
          print('object Failed insertDeviceInfo');
        }
      }

  }

}


