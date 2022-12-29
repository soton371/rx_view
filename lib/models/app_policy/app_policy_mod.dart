// To parse this JSON data, do
//
//     final appPolicyModel = appPolicyModelFromJson(jsonString);

import 'dart:convert';

List<AppPolicyModel> appPolicyModelFromJson(String str) => List<AppPolicyModel>.from(json.decode(str).map((x) => AppPolicyModel.fromJson(x)));

String appPolicyModelToJson(List<AppPolicyModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AppPolicyModel {
  AppPolicyModel({
    this.policyId,
    this.policyText,
    this.policyValue,
    this.apValueFg,
    this.policyVisibilityFg,
    this.globalPermissionFg,
  });

  String? policyId;
  String? policyText;
  int? policyValue;
  int? apValueFg;
  int? policyVisibilityFg;
  int? globalPermissionFg;

  factory AppPolicyModel.fromJson(Map<String, dynamic> json) => AppPolicyModel(
    policyId: json["policyID"],
    policyText: json["policyText"],
    policyValue: json["policyValue"],
    apValueFg: json["apValueFG"],
    policyVisibilityFg: json["policyVisibilityFg"],
    globalPermissionFg: json["globalPermissionFG"],
  );

  Map<String, dynamic> toJson() => {
    "policyID": policyId,
    "policyText": policyText,
    "policyValue": policyValue,
    "apValueFG": apValueFg,
    "policyVisibilityFg": policyVisibilityFg,
    "globalPermissionFG": globalPermissionFg,
  };
}
