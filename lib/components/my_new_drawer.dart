import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rx_view/commons/Constant.dart';
import 'package:rx_view/controllers/drawer_con/my_new_drawer_con.dart';
import 'package:rx_view/controllers/login_con.dart';
import 'package:rx_view/views/prescription/new_rx_view.dart';
import 'package:rx_view/views/setting/setting_screen.dart';

Widget myNewDrawer(context){

  final LoginController loginController = Get.put(LoginController());

  return Drawer(
    child: SafeArea(
        child: Column(
          children: [
            // start header
            const SizedBox(height: 10,),
            Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                const CircleAvatar(
                  radius: 20,
                  child: Icon(Iconsax.user),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  loginController.userNAme.string,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 25,
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.w300),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
            const SizedBox(height: 10,),
            // end header



            //start list of menu
            Expanded(
                child: GetBuilder<MyNewDrawerCon>(
                    builder: (data){
                      return data.menuList.isEmpty ?const SizedBox():
                      ListView.builder(
                        itemCount: data.menuList.length,
                          itemBuilder: (context,i){
                          var menu = data.menuList[i];
                          //for icon
                          menuIcon(icon){
                            if(icon == 'ic_home'){
                              return const Icon(Iconsax.home);
                            }else if(icon == 'ic_report'){
                              return const Icon(Iconsax.receipt);
                            }else if(icon == 'ic_rx'){
                              return const Icon(Iconsax.document);
                            }else if(icon == 'ic_settings'){
                              return const Icon(Iconsax.setting);
                            }else{
                              return const Icon(Iconsax.icon);
                            }
                          }
                          //for main menu page route
                          menuRoute(menuUId){
                            if(menuUId=='M009'){
                              Navigator.pop(context);
                              // return Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const NewHomeScreen()));
                            }else if(menuUId=='M010'){
                              Navigator.pop(context);
                              // return Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const ReportScreen()));
                            }else if(menuUId=='M012'){
                              Navigator.pop(context);
                              return Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const SettingScreen()));
                            }
                          }

                          singleSubMenuIcon(icon){
                            if(icon == 'ic_rx_details'){
                              return const Icon(Iconsax.presention_chart5);
                            }else if(icon == 'ic_rx_view'){
                              return const Icon(Iconsax.eye4);
                            }
                          }

                          singleSubMenuRoute(udSubMenuId){
                            if(udSubMenuId=='SM016'){
                              Navigator.pop(context);
                              // return Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const NewPrescriptionScreen()));
                            }else if(udSubMenuId=='SM017'){
                              Navigator.pop(context);
                              return Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> NewRxViewScreen()));
                            }
                          }

                          return menu.subMenuList != null && menu.subMenuList!.length==1?
                              //for single sub menu
                          ListTile(
                            onTap: (){
                              singleSubMenuRoute(menu.subMenuList![0].udSubMenuId);
                            },
                            leading: singleSubMenuIcon(menu.subMenuList![0].menuIcon),
                            title: Text(
                              "${menu.menuName??''}::${menu.subMenuList![0].subMenuName??''}",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                            ),
                          )
                              :
                              //for main menu
                            ExpansionTile(
                            leading: menuIcon(menu.menuIcon),
                              title:menu.subMenuList==null? InkWell(
                                onTap: (){
                                  //for main menu page route
                                  menuRoute(menu.menuUId);
                                },
                                  child: listTileTitle(menu.menuName??'')):
                              //for main sub menu
                              menu.subMenuList != null && menu.subMenuList!.isEmpty?const SizedBox():
                              listTileTitle(menu.menuName??''),

                            trailing: menu.subMenuList==null?const Icon(Icons.keyboard_arrow_down,color: Colors.transparent,):const Icon(Icons.keyboard_arrow_down),
                            children:menu.subMenuList!=null?
                            //for main sub menu
                            menu.subMenuList!.map((e) {

                              //for sub menu page route
                              subMenuRoute(udSubMenuId){
                                if(udSubMenuId=='SM016'){
                                  Navigator.pop(context);
                                  // return Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const NewPrescriptionScreen()));
                                }else if(udSubMenuId=='SM017'){
                                  Navigator.pop(context);
                                  return Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> NewRxViewScreen()));
                                }
                              }

                              //for icon
                              subMenuIcon(icon){
                                if(icon == 'ic_rx_details'){
                                  return const Icon(Iconsax.presention_chart5);
                                }else if(icon == 'ic_rx_view'){
                                  return const Icon(Iconsax.eye4);
                                }
                              }
                              return ListTile(
                                onTap: (){
                                  subMenuRoute(e.udSubMenuId);
                                },
                                contentPadding: const EdgeInsets.only(left: 40),
                                leading: subMenuIcon(e.menuIcon),
                                title: Text(e.subMenuName??''),
                              );
                            }
                            ).toList():
                                []
                          );
                          }
                      );
                    }
                )
            ),

            //end list of menu

            //start log out
            ListTile(
                onTap: (){
                  loginController.doLogOut(context);
                  // _myNewDrawerCon.menuList.clear();
                },
                leading: const Icon(Iconsax.logout),
                textColor: AppConstant.removeColor,
                iconColor: AppConstant.removeColor,
                title: listTileTitle('Log Out')),
            //end log out
          ],
        )
    ),
  );
}

Widget listTileTitle(String title) {
  return Text(
    title,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
  );
}