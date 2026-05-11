import 'package:control_app/utils/showMessageTools.dart';
import 'package:control_app/db/massage_database.dart';
import 'package:control_app/model/user.dart';
import 'package:control_app/providers/userProvider.dart';
import 'package:control_app/view/homePage.dart';
import 'package:control_app/widgets/navigation_drawer.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class AboutUsPage extends StatefulWidget {
  static const routeName = '/aboutUsPage';
  final pageRouteName = routeName;
  final bool isRequiredChangePasswordAfterLogin;
  AboutUsPage(this.isRequiredChangePasswordAfterLogin);
  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
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

  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    super.dispose();
    //hide loader
    Loader.hide();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: NavigationDrawerWidget(widget.pageRouteName),
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(45.0),
          child: AppBar(
            centerTitle: true,
            backgroundColor: Color(0xF6698FFa),
            brightness: Brightness.light,
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                );
              },
            ),
            title: Text(
              "aboutUs",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ).tr(),
          )), //Image.asset("lib/assets/img/user.png",width: 50, height: 50,),
      body: Container(
        child: new Form(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Container(
                margin: EdgeInsets.only(top: 50),
                child: Image.asset(
                  "assets/img/logo.png",
                  width: 80,
                  height: 80,
                ),
              ),
              new SizedBox(
                height: 40.0,
              ),
              Container(
                // color: Colors.white,
                child: new Column(children: <Widget>[
                  Text(
                    "This a an Application ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ]),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 50),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[Text("version", style: TextStyle(color: Colors.blue[900], fontSize: 14)).tr(), Text(" " + version, style: TextStyle(color: Colors.blue[900], fontSize: 14))],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
