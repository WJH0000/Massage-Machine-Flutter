import 'package:control_app/view/homePage.dart';
import 'package:control_app/widgets/navigation_drawer.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

class SetLanguagePage extends StatefulWidget {
  static const routeName = '/setLanguagePage';
  final pageRouteName = routeName;
  final bool isAfterLogin;
  SetLanguagePage({required this.isAfterLogin, Key? key}) : super(key: key);

  @override
  _SetLanguagePageState createState() => _SetLanguagePageState();
}

class _SetLanguagePageState extends State<SetLanguagePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    //hide loader
    Loader.hide();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: widget.isAfterLogin ? NavigationDrawerWidget(widget.pageRouteName) : null,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(45.0),
          child: new AppBar(
            backgroundColor: Color(0xF6698FFa),
            title: Text(
              'languageSetting',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ).tr(),
            centerTitle: true,
            brightness: Brightness.light,
            leading: widget.isAfterLogin
                ? Builder(
                    builder: (BuildContext context) {
                      return IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                      );
                    },
                  )
                : IconButton(
                    icon: Icon(
                      Icons.keyboard_arrow_left,
                      size: 30,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
          ),
        ),
        body: SafeArea(
          child: new Column(children: <Widget>[
            Container(
              height: 20,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 25),
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
            ),
            ListTile(
              leading: Text("简体中文", style: new TextStyle(fontSize: 14)), // item 前置图标
              trailing: Icon(
                context.locale.toString() == "zh" ? Icons.check_circle_outline : null,
                color: Color(0xF6698FFa),
              ),
              isThreeLine: false, // item 是否三行显示
              dense: true, // item 直观感受是整体大小
              contentPadding: EdgeInsets.only(left: 15, right: 20), // item 内容内边距
              enabled: true,
              onTap: () async {
                if (context.deviceLocale.toString() != "zh") {
                  await context.setLocale(Locale('zh'));

                  widget.isAfterLogin ? Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage())) : Navigator.pop(context);
                }
              }, // item onTap 点击事件
              selected: false,
              // item 是否选中状态
            ),
            Divider(
              height: 1,
            ),
            Divider(
              height: 1,
            ),
            ListTile(
              leading: Text("English", style: new TextStyle(fontSize: 14)), // item 前置图标
              trailing: Icon(
                context.locale.toString() == "en" ? Icons.check_circle_outline : null,
                color: Color(0xF6698FFa),
              ),
              isThreeLine: false, // item 是否三行显示
              dense: true, // item 直观感受是整体大小
              contentPadding: EdgeInsets.only(left: 15, right: 20), // item 内容内边距
              enabled: true,
              onTap: () async {
                if (context.deviceLocale.toString() != "en") {
                  await context.setLocale(Locale('en'));
                  widget.isAfterLogin ? Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage())) : Navigator.pop(context);
                }
              }, // item onTap 点击事件
              selected: false,
              // item 是否选中状态
            ),
            Divider(
              height: 1,
            ),
          ]),
        ));
  }
}
