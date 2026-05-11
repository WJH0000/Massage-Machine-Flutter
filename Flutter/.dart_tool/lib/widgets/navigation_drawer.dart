import 'dart:convert';
import 'dart:typed_data';
import 'package:control_app/utils/apiRequest.dart';
import 'package:control_app/utils/clearUserData.dart';
import 'package:control_app/utils/loader.dart';
import 'package:control_app/utils/showMessageTools.dart';
import 'package:control_app/const/constant.dart';
import 'package:control_app/providers/userProvider.dart';
import 'package:control_app/view/aboutUs.dart';
import 'package:control_app/view/changePassword.dart';
import 'package:control_app/view/homePage.dart';
import 'package:control_app/view/setLanguage.dart';
import 'package:control_app/view/userAccount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:control_app/view/device.dart';

class NavigationDrawerWidget extends StatelessWidget {
  final padding = EdgeInsets.symmetric(horizontal: 10);

  NavigationDrawerWidget(this.pageRouteName);

  final String pageRouteName;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).getUserDetails;

    logOutPostApiRequest(String url) async {
      //Show loading
      showLoader(context);

      String? token = Provider.of<UserProvider>(context, listen: false)
          .getUserDetails
          .token
          .toString();

      //add Header token
      ApiRequest _apiRepositary = new ApiRequest("Bearer " + token);

      try {
        await _apiRepositary.httpPostRequest(url, "", context).then(
          (response) async {
            if (response!.statusCode == 200) {
              dynamic decodedJson = json.decode(response.toString());

              //Get error flag
              bool isError = decodedJson['isError'];

              if (!isError) {
                // clear all user data

                await ClearUserData.clearUserDataAndNavigateToLoginPage(
                    user, context);
              } else {
                ShowMessageTools.displayToast('serverInternalError'.tr());
              }
            } else {
              ShowMessageTools.displayToast('serverInternalError'.tr());
            }
            Loader.hide();
          },
          onError: (exception) {
            Loader.hide();
            print("error " + exception.message.toString());
          },
        );
      } on Exception catch (e) {
        print(e);
        // ShowMessageTools.displayToast("systemErrorOccur".tr());
      }
    }

    return Drawer(
      child: Material(
        color: Color(0xF6698FFa),
        child: ListView(
          padding: padding,
          children: [
            buildHeader(
              name: user.userName.toString(),
              email: user.email.toString(),
              profileImage: user.profileImageSource,
              onClicked: () => selectedItem(context, 0),
            ),
            Divider(
              color: Colors.white70,
              thickness: 1,
            ),
            buildMenuItem(
                text: 'homePage'.tr(),
                icon: Icons.home,
                onClicked: () => selectedItem(context, 1)),
            // buildMenuItem(
            //     text: 'userDetails'.tr(),
            //     icon: Icons.person,
            //     onClicked: () => selectedItem(context, 2)),
            user.registerType == LOGIN_TYPES[2]
                ? buildMenuItem(
                    text: 'change Password'.tr(),
                    icon: Icons.password,
                    onClicked: () => selectedItem(context, 2))
                : SizedBox.shrink(),
            buildMenuItem(
                text: 'language Setting'.tr(),
                icon: Icons.language,
                onClicked: () => selectedItem(context, 3)),
            buildMenuItem(
                text: 'About Us'.tr(),
                icon: Icons.info_outline,
                onClicked: () => selectedItem(context, 4)),
            buildMenuItem(
              text: 'Finding Devices'
                  .tr(), // if using localization, else just use 'Bluetooth Devices'
              icon: Icons.bluetooth,
              onClicked: () => selectedItem(context, 5),
            ),

            Divider(
              color: Colors.white70,
              thickness: 1,
            ),
            buildMenuItem(
                text: 'logOut'.tr(),
                icon: Icons.logout,
                onClicked: () async {
                  String url = "api/Authentication/logOut";

                  //Deactivate session
                  await logOutPostApiRequest(url);
                }),
          ],
        ),
      ),
    );
  }

  Widget buildHeader({
    required String name,
    required String email,
    required Uint8List? profileImage,
    required VoidCallback onClicked,
  }) =>
      InkWell(
          onTap: onClicked,
          child: SafeArea(
              child: Wrap(children: [
            Container(
              padding: padding.add(EdgeInsets.symmetric(vertical: 20)),
              child: Row(
                children: [
                  Container(
                    // margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    height: 80.0,
                    width: 80.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(45),
                        color: Colors.purple,
                        border: Border.all(width: 4, color: Colors.purple),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: profileImage != null
                              ? MemoryImage(profileImage)
                              : AssetImage('assets/img/default.png')
                                  as ImageProvider,
                        )),
                  ),
                  //child: CircleAvatar(radius: 30, backgroundImage: NetworkImage(baseUrl + 'images/default.png')),

                  // Container(
                  //           decoration: BoxDecoration(
                  //               color: Colors.green,

                  //           child: Text("test dddddddddddddddddddddddd"),
                  //         ),
                  SizedBox(width: 10),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            softWrap: false,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(email,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            softWrap: false,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),

                  // Spacer(),
                ],
              ),
            ),
          ])));

  Widget buildMenuItem({
    required String text,
    required IconData icon,
    required VoidCallback onClicked,
  }) {
    final color = Colors.white;
    final hoverColor = Colors.white70;

    return ListTile(
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(text, style: TextStyle(color: color)),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  void selectedItem(BuildContext context, int index) {
    Navigator.of(context).pop();

    String currentRouteName = ModalRoute.of(context)!.settings.name.toString();
    print("test5 " + pageRouteName);

    switch (index) {
      case 0:
        // Navigator.of(context).pushReplacement(
        //     MaterialPageRoute(builder: (context) => HomePage()));
        if (pageRouteName != UserAccountPage.routeName) {
          Navigator.of(context).pop();
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: UserAccountPage()));
        }

        break;
      case 1:
        if (pageRouteName != HomePage.routeName) {
          Navigator.of(context).pop();
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft, child: HomePage()));
          // Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
        }
        break;
      case 2:
        if (pageRouteName != ChangePasswordPage.routeName) {
          Navigator.of(context).pop();
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: ChangePasswordPage(false)));
        }

        break;
      case 3:
        if (pageRouteName != SetLanguagePage.routeName) {
          Navigator.of(context).pop();
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: SetLanguagePage(isAfterLogin: true)));
        }
        break;
      case 4:
        if (pageRouteName != AboutUsPage.routeName) {
          Navigator.of(context).pop();

          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: AboutUsPage(false)));
        }
        break;
      case 5:
        if (pageRouteName != DevicePage.routeName) {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: DevicePage(),
            ),
          );
        }
        break;
    }
  }
}
