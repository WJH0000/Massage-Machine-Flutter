import 'dart:async';
import 'package:control_app/utils/showMessageTools.dart';
import 'package:control_app/db/massage_database.dart';
import 'package:control_app/model/user.dart';
import 'package:control_app/providers/userProvider.dart';
import 'package:control_app/view/homePage.dart';
import 'package:control_app/view/login.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  //Application Version
  String version = "";

  initPlatformState() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    setState(() {
      version = packageInfo.version;
    });

    String buildNumber = packageInfo.buildNumber;
  }

  getUserDetailFromLocal() async {
    try {
      bool isLocalUserDataExist = await MassageDatabase.instance.checkIsLocalUserDataEmpty();
      if (isLocalUserDataExist) {
        //Check before allow login
        User retrieveUser = await MassageDatabase.instance.getUserWithoutId();
        if (retrieveUser.userId != 0) {
          // add user to provider
          Provider.of<UserProvider>(context, listen: false).setUser(retrieveUser);

          //go to login page
          ShowMessageTools.displayToast('welcome'.tr());

          Navigator.pushReplacement(context, PageTransition(alignment: Alignment.bottomCenter, duration: const Duration(milliseconds: 500), type: PageTransitionType.scale, child: HomePage()));
        } else {
          //clear database record
          await MassageDatabase.instance.deleteMassageTableAndUsetTableData();
          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: LoginPage()));
        }
      } else {
        Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: LoginPage()));
      }
    } on Exception catch (e) {
      print(e.toString());
      Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: LoginPage()));
    }
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    //Check whether local store user detail
    Timer(Duration(seconds: 1), () => {getUserDetailFromLocal()});
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Container(
      decoration: BoxDecoration(
          //image: new DecorationImage(image: AssetImage('lib/assets/img/background.png'), fit: BoxFit.fill),
          color: Color(0xFFa2bffc)),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Container(
              child: Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
                  child: Image(
                    image: AssetImage('assets/img/logo.png'),
                    height: MediaQuery.of(context).size.width / 2,
                    width: MediaQuery.of(context).size.width / 2,
                  ))),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: Row(children: [
                    new Text("version", style: new TextStyle(fontSize: 12.0, color: Colors.black, fontWeight: FontWeight.bold)).tr(),
                    Text(" " + version, style: new TextStyle(fontSize: 12.0, color: Colors.black, fontWeight: FontWeight.bold))
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
