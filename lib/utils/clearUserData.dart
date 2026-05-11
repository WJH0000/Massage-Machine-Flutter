import 'package:control_app/const/constant.dart';
import 'package:control_app/db/massage_database.dart';
import 'package:control_app/model/user.dart';
import 'package:control_app/providers/userProvider.dart';
import 'package:control_app/view/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ClearUserData {
  static clearUserDataAndNavigateToLoginPage(User user, BuildContext context) async {
    //clear database record
    await MassageDatabase.instance.deleteMassageTableAndUsetTableData();

    //Sign Out Google Account
    if (user.registerType == LOGIN_TYPES[0]) {
      await googleSignIn.disconnect();
    }

    //Sign Out Facebook
    if (user.registerType == LOGIN_TYPES[1]) {
      await FacebookAuth.instance.logOut();
    }

    //clear provider data
    Provider.of<UserProvider>(context, listen: false).clearUser();

    //Navigate to Login page
    Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.bottomToTop, child: LoginPage()));
  }
}
