
import 'dart:io';
import 'package:control_app/providers/massageSettingProvider.dart';
import 'package:control_app/providers/userProvider.dart';
import 'package:control_app/view/homePage.dart';
import 'package:control_app/view/login.dart';
import 'package:control_app/view/splashScreen.dart';
import 'package:control_app/view/userAccount.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  //debug configuration
  ErrorWidget.builder = (FlutterErrorDetails details) {
    bool inDebug = false;
    assert(() {
      inDebug = true;
      return true;
    }());
    // In debug mode, use the normal error widget which shows
    // the error message:
    if (inDebug) {
      return ErrorWidget(details.exception);
    }
    return new Material
    (
        type: MaterialType.transparency,
        child: new Container(
          decoration: new BoxDecoration(color: Colors.white),
          child: new Center(
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Image.asset(
                "assets/img/systemError.png",
                width: 80,
                height: 80,
              ),
              Container(
                height: 20,
              ),
              Text(
                "Error Occur",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              Text(
                "Please Restart the application",
                style: TextStyle(fontSize: 15),
              ),
            ]),
          ),
        ));
  };
  HttpOverrides.global = new MyHttpOverrides();
  runApp(
    EasyLocalization(
        supportedLocales: [Locale('en'), Locale('zh')],
        path: 'assets/translations', // <-- change the path of the translation files
        fallbackLocale: Locale('en'),
        child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => UserProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => MassageSettingProvider(),
          ),
        ],
        child: MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            debugShowCheckedModeBanner: false,
            locale: context.locale,
            title: 'Massager App',
            routes: <String, WidgetBuilder>{
              LoginPage.routeName: (BuildContext context) => LoginPage(),
              HomePage.routeName: (BuildContext context) => HomePage(),
              UserAccountPage.routeName: (BuildContext context) => UserAccountPage(),
            },
            theme: ThemeData(
              primarySwatch: Colors.blue,
              accentColor: Colors.white,
              textTheme: ThemeData.light().textTheme.copyWith(
                    headline5: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
            home: AnimatedSplashScreen(
                duration: 1000,
                splash: new Image(
                  image: AssetImage('assets/img/logo.png'),
                  width: 150,
                  height: 150,
                ),
                nextScreen: SplashScreen(),
                pageTransitionType: PageTransitionType.fade,
                splashTransition: SplashTransition.sizeTransition,
                backgroundColor: Color(0xFFa2bffc))));
  }
}
