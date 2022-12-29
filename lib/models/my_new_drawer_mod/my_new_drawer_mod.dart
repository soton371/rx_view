// To parse this JSON data, do
//
//     final myNewDrawerModel = myNewDrawerModelFromJson(jsonString);

import 'dart:convert';

List<MyNewDrawerModel> myNewDrawerModelFromJson(String str) => List<MyNewDrawerModel>.from(json.decode(str).map((x) => MyNewDrawerModel.fromJson(x)));

String myNewDrawerModelToJson(List<MyNewDrawerModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MyNewDrawerModel {
  MyNewDrawerModel({
    this.menuId,
    this.menuUId,
    this.menuName,
    this.menuIcon,
    this.menuOrder,
    this.isContainSubMenu,
    this.isWelcomePage,
    this.subMenuList,
  });

  int? menuId;
  String? menuUId;
  String? menuName;
  String? menuIcon;
  int? menuOrder;
  int? isContainSubMenu;
  int? isWelcomePage;
  List<SubMenuList>? subMenuList;

  factory MyNewDrawerModel.fromJson(Map<String, dynamic> json) => MyNewDrawerModel(
    menuId: json["menuId"],
    menuUId: json["menuUId"],
    menuName: json["menuName"],
    menuIcon: json["menuIcon"],
    menuOrder: json["menuOrder"],
    isContainSubMenu: json["isContainSubMenu"],
    isWelcomePage: json["isWelcomePage"],
    subMenuList: json["subMenuList"] == null ? null : List<SubMenuList>.from(json["subMenuList"].map((x) => SubMenuList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "menuId": menuId,
    "menuUId": menuUId,
    "menuName": menuName,
    "menuIcon": menuIcon,
    "menuOrder": menuOrder,
    "isContainSubMenu": isContainSubMenu,
    "isWelcomePage": isWelcomePage,
    "subMenuList": subMenuList == null ? null : List<dynamic>.from(subMenuList!.map((x) => x.toJson())),
  };
}

class SubMenuList {
  SubMenuList({
    this.subMenuId,
    this.udSubMenuId,
    this.menuId,
    this.subMenuName,
    this.menuOrder,
    this.menuIcon,
    this.isWelcomePage,
  });

  int? subMenuId;
  String? udSubMenuId;
  int? menuId;
  String? subMenuName;
  int? menuOrder;
  String? menuIcon;
  int? isWelcomePage;

  factory SubMenuList.fromJson(Map<String, dynamic> json) => SubMenuList(
    subMenuId: json["subMenuId"],
    udSubMenuId: json["udSubMenuId"],
    menuId: json["menuId"],
    subMenuName: json["subMenuName"],
    menuOrder: json["menuOrder"],
    menuIcon: json["menuIcon"],
    isWelcomePage: json["isWelcomePage"],
  );

  Map<String, dynamic> toJson() => {
    "subMenuId": subMenuId,
    "udSubMenuId": udSubMenuId,
    "menuId": menuId,
    "subMenuName": subMenuName,
    "menuOrder": menuOrder,
    "menuIcon": menuIcon,
    "isWelcomePage": isWelcomePage,
  };
}
