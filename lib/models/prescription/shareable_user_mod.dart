// To parse this JSON data, do
//
//     final shareableUserModel = shareableUserModelFromJson(jsonString);

import 'dart:convert';

List<ShareableUserModel> shareableUserModelFromJson(String str) => List<ShareableUserModel>.from(json.decode(str).map((x) => ShareableUserModel.fromJson(x)));

String shareableUserModelToJson(List<ShareableUserModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ShareableUserModel {
  ShareableUserModel({
    this.shareId,
    this.shareFlag,
    this.mktProfNo,
    this.mktProfName,
    this.profRole,
    this.isSelected
  });

  int? shareId;
  int? shareFlag;
  String? mktProfNo;
  String? mktProfName;
  String? profRole;
  bool? isSelected = true;

  factory ShareableUserModel.fromJson(Map<String, dynamic> json) => ShareableUserModel(
    shareId: json["shareId"],
    shareFlag: json["shareFlag"],
    mktProfNo: json["mktProfNo"],
    mktProfName: json["mktProfName"],
    profRole: json["profRole"],
    isSelected: json["isSelected"],
  );

  Map<String, dynamic> toJson() => {
    "shareId": shareId,
    "shareFlag": shareFlag,
    "mktProfNo": mktProfNo,
    "mktProfName": mktProfName,
    "profRole": profRole,
    "isSelected": isSelected,
  };
}
