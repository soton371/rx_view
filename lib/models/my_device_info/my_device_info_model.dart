// To parse this JSON data, do
//
//     final myDeviceInfoModel = myDeviceInfoModelFromJson(jsonString);

import 'dart:convert';

MyDeviceInfoModel myDeviceInfoModelFromJson(String str) => MyDeviceInfoModel.fromJson(json.decode(str));

String myDeviceInfoModelToJson(MyDeviceInfoModel data) => json.encode(data.toJson());

class MyDeviceInfoModel {
  MyDeviceInfoModel({
    this.message,
    this.statusCode,
    this.objResponse,
  });

  String? message;
  int? statusCode;
  ObjResponse? objResponse;

  factory MyDeviceInfoModel.fromJson(Map<String, dynamic> json) => MyDeviceInfoModel(
    message: json["message"]??'',
    statusCode: json["statusCode"]??'',
    objResponse: ObjResponse.fromJson(json["objResponse"]??''),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "statusCode": statusCode,
    "objResponse": objResponse!.toJson(),
  };
}

class ObjResponse {
  ObjResponse({
    this.deviceIdPk,
  });

  int? deviceIdPk;

  factory ObjResponse.fromJson(Map<String, dynamic> json) => ObjResponse(
    deviceIdPk: json["deviceIdPk"]??'',
  );

  Map<String, dynamic> toJson() => {
    "deviceIdPk": deviceIdPk,
  };
}
