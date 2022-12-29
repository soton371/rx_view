import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rx_view/commons/Constant.dart';
import 'package:rx_view/components/back_to_exit.dart';
import 'package:rx_view/components/myLoaderDialog.dart';
import 'package:rx_view/controllers/apis.dart';
import 'package:rx_view/controllers/my_device_info/my_device_info.dart';
import 'package:rx_view/local_db/app_policy/app_policy_db.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> with TickerProviderStateMixin{

  final MyDeviceInfoController myDeviceInfoController = Get.put(MyDeviceInfoController());
  // final CheckUpdateController _checkUpdateController = Get.put(CheckUpdateController());

  String email = '';
  String password = '';
  bool passwordVisible = true;

  String deviceIdPk = '';
  getDeviceIdPk()async{
    final prefs = await SharedPreferences.getInstance();
    deviceIdPk = prefs.getInt('deviceIdPk').toString();
  }

  sendInsertDeviceInfo()async{
    Future.delayed(const Duration(milliseconds: 4000), () {
      myDeviceInfoController.insertDeviceInfo(deviceIdPk);
    });
  }

  late AnimationController controller1;
  late AnimationController controller2;
  late Animation<double> animation1;
  late Animation<double> animation2;
  late Animation<double> animation3;
  late Animation<double> animation4;

  @override
  void initState() {
    super.initState();
    getDeviceIdPk();
    sendInsertDeviceInfo();

    controller1 = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: 5,
      ),
    );
    animation1 = Tween<double>(begin: .1, end: .15).animate(
      CurvedAnimation(
        parent: controller1,
        curve: Curves.easeInOut,
      ),
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller1.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller1.forward();
        }
      });
    animation2 = Tween<double>(begin: .02, end: .04).animate(
      CurvedAnimation(
        parent: controller1,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
      setState(() {});
    });

    controller2 = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: 5,
      ),
    );
    animation3 = Tween<double>(begin: .41, end: .38).animate(CurvedAnimation(
      parent: controller2,
      curve: Curves.easeInOut,
    ))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller2.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller2.forward();
        }
      });
    animation4 = Tween<double>(begin: 170, end: 190).animate(
      CurvedAnimation(
        parent: controller2,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
      setState(() {});
    });

    Timer(Duration(milliseconds: 2500), () {
      controller1.forward();
    });

    controller2.forward();
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: ()=>backToExit(context),
      child: Scaffold(
        backgroundColor: AppConstant.backgroundColor,
        body: Stack(
          children: [
            Positioned(
              top: size.height * (animation2.value + .58),
              left: size.width * .21,
              child: CustomPaint(
                painter: MyPainter(50),
              ),
            ),
            Positioned(
              top: size.height * .98,
              left: size.width * .1,
              child: CustomPaint(
                painter: MyPainter(animation4.value - 30),
              ),
            ),
            Positioned(
              top: size.height * .5,
              left: size.width * (animation2.value + .8),
              child: CustomPaint(
                painter: MyPainter(30),
              ),
            ),
            Positioned(
              top: size.height * animation3.value,
              left: size.width * (animation1.value + .1),
              child: CustomPaint(
                painter: MyPainter(60),
              ),
            ),
            Positioned(
              top: size.height * .1,
              left: size.width * .8,
              child: CustomPaint(
                painter: MyPainter(animation4.value),
              ),
            ),

            Center(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                children: [
                  Text(
                    'Rx Viewer',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  SizedBox(height: 60,),

                  //for username
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaY: 15,
                        sigmaX: 15,
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          onChanged: (v){
                            email = v;
                          },
                          style: TextStyle(color: Colors.black.withOpacity(.8)),
                          cursorColor: Colors.black,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.account_circle_outlined,
                              color: Colors.black.withOpacity(.7),
                            ),
                            border: InputBorder.none,
                            hintMaxLines: 1,
                            hintText: 'User name...',
                            hintStyle:
                            TextStyle(fontSize: 14, color: Colors.black.withOpacity(.5)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15,),


                  //for password
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaY: 15,
                        sigmaX: 15,
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          onChanged: (v){
                            password = v;
                          },
                          style: TextStyle(color: Colors.black.withOpacity(.8)),
                          cursorColor: Colors.black,
                          obscureText: passwordVisible,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: (){
                                  setState(() {
                                    passwordVisible = !passwordVisible;
                                  });
                                },
                                icon: Icon(passwordVisible? Iconsax.eye_slash:Iconsax.eye, color: Colors.black.withOpacity(.5),size: 20,)
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.black.withOpacity(.7),
                            ),
                            border: InputBorder.none,
                            hintMaxLines: 1,
                            hintText: 'Password...',
                            hintStyle:
                            TextStyle(fontSize: 14, color: Colors.black.withOpacity(.5)),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30,),
                  component2(
                    'LOGIN',
                    2.58,
                        () async{
                      print('object needUpdate false');
                      myLoaderDialog(context,'  Login..');
                      doLogIn(context,email,password);
                      myDeviceInfoController.insertDeviceInfo(deviceIdPk);
                      await AppPolicyDb.instance.deleteAll();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget component2(String string, double width, VoidCallback voidCallback) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaY: 15, sigmaX: 15),
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: voidCallback,
          child: Container(
            padding: EdgeInsets.all(15),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              string,
              style: TextStyle(color: Colors.black.withOpacity(.8)),
            ),
          ),
        ),
      ),
    );
  }
}


class MyPainter extends CustomPainter {
  final double radius;

  MyPainter(this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
          colors: [AppConstant.primarySwatchColor, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight)
          .createShader(Rect.fromCircle(
        center: Offset(0, 0),
        radius: radius,
      ));

    canvas.drawCircle(Offset.zero, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}