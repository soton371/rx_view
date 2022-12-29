// To parse this JSON data, do
//
//     final getPendingRxModel = getPendingRxModelFromJson(jsonString);

import 'dart:convert';

import 'package:get/get.dart';

List<GetPendingRxModel> getPendingRxModelFromJson(String str) => List<GetPendingRxModel>.from(json.decode(str).map((x) => GetPendingRxModel.fromJson(x)));

String getPendingRxModelToJson(List<GetPendingRxModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetPendingRxModel {
  GetPendingRxModel({
    this.msRxRecDate,
    this.totalRx,
    this.totalRxView,
    this.totalViewPending,
  });

  String? msRxRecDate;
  int? totalRx;
  int? totalRxView;
  int? totalViewPending;

  factory GetPendingRxModel.fromJson(Map<String, dynamic> json) => GetPendingRxModel(
    msRxRecDate: json["msRxRecDate"],
    totalRx: json["totalRx"]  == null || json["totalRx"]  == 'null' ? 0 : json["totalRx"],
    totalRxView: json["totalRxView"] == null ? 0 : json["totalRxView"],
    totalViewPending: json["totalViewPending"] == null ? 0 : json["totalViewPending"],
  );

  Map<String, dynamic> toJson() => {
    "msRxRecDate": msRxRecDate,
    "totalRx": totalRx,
    "totalRxView": totalRxView,
    "totalViewPending": totalViewPending,
  };
}
