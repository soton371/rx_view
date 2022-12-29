// To parse this JSON data, do
//
//     final rxModel = rxModelFromJson(jsonString);

import 'dart:convert';

List<RxModel> rxModelFromJson(String str) => List<RxModel>.from(json.decode(str).map((x) => RxModel.fromJson(x)));

String rxModelToJson(List<RxModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RxModel {
  RxModel({
     this.udHospitalId,
     this.hosCareName,
     this.hcpMobNo,
     this.hcpAddress,
     this.isSelect,
     this.drList,
     this.divisionName,
     this.districtName,
     this.thanaName,
  });

  String? udHospitalId;
  String? hosCareName;
  String? hcpMobNo;
  String? hcpAddress;
  bool? isSelect = false;
  List<DrList>? drList = [];
  String? divisionName;
  String? districtName;
  String? thanaName;

  factory RxModel.fromJson(Map<String, dynamic> json) => RxModel(
    udHospitalId: json["udHospitalId"]??'',
    hosCareName: json["hosCareName"]??'',
    hcpMobNo: json["hcpMobNo"]??'',
    hcpAddress: json["hcpAddress"]??'',
    isSelect: json["isSelect"]??false,
    drList: List<DrList>.from(json["drList"].map((x) => DrList.fromJson(x))),
    divisionName: json["divisionName"]??'',
    districtName: json["districtName"]??'',
    thanaName: json["thanaName"]??'',
  );

  Map<String, dynamic> toJson() => {
    "udHospitalId": udHospitalId,
    "hosCareName": hosCareName,
    "hcpMobNo": hcpMobNo,
    "hcpAddress": hcpAddress,
    "isSelect": isSelect,
    "drList": List<dynamic>.from(drList!.map((x) => x.toJson())),
    "divisionName": divisionName,
    "districtName": districtName,
    "thanaName": thanaName,
  };
}


class DrList {
  DrList({
    this.userDhcgNo,
    this.drName,
    this.drDegree,
    this.speciality,
    this.isSelect,
    this.rxList,
  });

  String? userDhcgNo;
  String? drName;
  String? drDegree;
  String? speciality;
  bool? isSelect;
  List<MyRxList>? rxList;

  factory DrList.fromJson(Map<String, dynamic> json) => DrList(
    userDhcgNo: json["userDHCGNo"]??'',
    drName: json["drName"]??'',
    drDegree: json["drDegree"]??'',
    speciality: json["speciality"]??'',
    isSelect: json["isSelect"]??false,
    rxList: List<MyRxList>.from(json["rxList"].map((x) => MyRxList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "userDHCGNo": userDhcgNo,
    "drName": drName,
    "drDegree": drDegree,
    "speciality": speciality,
    "isSelect": isSelect,
    "rxList": List<dynamic>.from(rxList!.map((x) => x.toJson())),
  };
}

class MyRxList {
  MyRxList({
    this.feedBackMstId,
    this.feedBackCreateDt,
    this.submitDt,
    this.userDhcgNo,
    this.udHospitalId,
    this.hosCareName,
    this.totalProd,
    this.feedbackSendBy,
    this.udCreateBy,
    this.drName,
    this.hcpRegNo,
    this.hcpMobNo,
    this.hcpAddress,
    this.drDegree,
    this.speciality,
    this.udMsRxNo,
    this.evfcFg,
    this.imgLink,
    this.medDetails,
    this.isSelect,
    this.divisionName,
    this.districtName,
    this.thanaName,
    this.performerName,
    this.performDate,
    this.totalView,
    this.viewTypeFlag,
    this.rxCaptureDtTm,
    this.viewingFlag,
    this.totalShare,
    this.mornEveningFlag,
  });

  int? feedBackMstId;
  String? feedBackCreateDt;
  String? submitDt;
  String? userDhcgNo;
  String? udHospitalId;
  String? hosCareName;
  int? totalProd;
  String? feedbackSendBy;
  String? udCreateBy;
  String? drName;
  String? hcpRegNo;
  String? hcpMobNo;
  String? hcpAddress;
  String? drDegree;
  String? speciality;
  String? udMsRxNo;
  int? evfcFg;
  String? imgLink;
  String? medDetails;
  bool? isSelect;
  String? divisionName;
  String? districtName;
  String? thanaName;
  String? performerName;
  String? performDate;
  int? totalView;
  int? viewTypeFlag;
  String? rxCaptureDtTm;
  int? viewingFlag;
  int? totalShare;
  String? mornEveningFlag;

  factory MyRxList.fromJson(Map<String, dynamic> json) => MyRxList(
    feedBackMstId: json["feedBackMstId"]??'',
    feedBackCreateDt: json["feedBackCreateDT"]??'',
    submitDt: json["submitDT"]??'',
    userDhcgNo: json["userDHCGNo"]??'',
    udHospitalId: json["udHospitalId"]??'',
    hosCareName: json["hosCareName"]??'',
    totalProd: json["totalProd"]??'',
    feedbackSendBy: json["feedbackSendBy"]??'',
    udCreateBy: json["udCreateBy"]??'',
    drName: json["drName"]??'',
    hcpRegNo: json["hcpRegNo"]??'',
    hcpMobNo: json["hcpMobNo"]??'',
    hcpAddress: json["hcpAddress"]??'',
    drDegree: json["drDegree"]??'',
    speciality: json["speciality"]??'',
    udMsRxNo: json["udMsRXNo"]??'',
    evfcFg: json["evfcFg"]??'',
    imgLink: json["imgLink"]??'',
    medDetails: json["medDetails"]??'',
    isSelect: json["isSelect"]??false,
    divisionName: json["divisionName"]??'',
    districtName: json["districtName"]??'',
    thanaName: json["thanaName"]??'',
    performerName: json["performerName"]??'',
    performDate: json["performDate"]??'',
    totalView: json["totalView"]??'',
    viewTypeFlag: json["viewTypeFlag"]??'',
    rxCaptureDtTm: json["rxCaptureDtTm"]??'',
    viewingFlag: json["viewingFlag"]??'',
    totalShare: json["totalShare"]??'',
    mornEveningFlag: json["mornEveningFlag"]??'',
  );

  Map<String, dynamic> toJson() => {
    "feedBackMstId": feedBackMstId,
    "feedBackCreateDT": feedBackCreateDt,
    "submitDT": submitDt,
    "userDHCGNo": userDhcgNo,
    "udHospitalId": udHospitalId,
    "hosCareName": hosCareName,
    "totalProd": totalProd,
    "feedbackSendBy": feedbackSendBy,
    "udCreateBy": udCreateBy,
    "drName": drName,
    "hcpRegNo": hcpRegNo,
    "hcpMobNo": hcpMobNo,
    "hcpAddress": hcpAddress,
    "drDegree": drDegree,
    "speciality": speciality,
    "udMsRXNo": udMsRxNo,
    "evfcFg": evfcFg,
    "imgLink": imgLink,
    "medDetails": medDetails,
    "isSelect": isSelect,
    "divisionName": divisionName,
    "districtName": districtName,
    "thanaName": thanaName,
    "performerName": performerName,
    "performDate": performDate,
    "totalView": totalView,
    "viewTypeFlag": viewTypeFlag,
    "rxCaptureDtTm": rxCaptureDtTm,
    "viewingFlag": viewingFlag,
    "totalShare": totalShare,
    "mornEveningFlag": mornEveningFlag,
  };
}

