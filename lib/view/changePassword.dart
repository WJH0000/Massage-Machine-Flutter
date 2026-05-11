import 'package:control_app/utils/apiRequest.dart';
import 'package:control_app/utils/loader.dart';
import 'package:control_app/utils/showMessageTools.dart';
import 'package:control_app/providers/userProvider.dart';
import 'package:control_app/request/userRequest.dart';
import 'package:control_app/view/homePage.dart';
import 'package:control_app/widgets/navigation_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ChangePasswordPage extends StatefulWidget {
  static const routeName = '/changePasswordPage';
  final pageRouteName = routeName;
  final bool isRequiredChangePasswordAfterLogin;
  ChangePasswordPage(this.isRequiredChangePasswordAfterLogin, {Key? key}) : super(key: key);
  @override
  _ChangePasswordPagePageState createState() => new _ChangePasswordPagePageState();
}

class _ChangePasswordPagePageState extends State<ChangePasswordPage> {
  //Text Controller
  TextEditingController oldPasswordText = new TextEditingController();
  TextEditingController passwordText = new TextEditingController();
  TextEditingController confirmPasswordText = new TextEditingController();

  //Text Field Empty Check
  bool isOldPasswordEmpty = false;
  bool isPasswordEmpty = false;
  bool isConfirmPasswordEmpty = false;
  bool isPasswordHidden = true;
  bool isFulfillPasswordComplexity = true;
  bool isConfirmPasswordHidden = true;
  bool isConfirmPasswordMatch = true;

  validateAllInput() {
    if (oldPasswordText.text.isEmpty && !widget.isRequiredChangePasswordAfterLogin) {
      setState(() {
        isPasswordEmpty = true;
      });
    }

    if (passwordText.text.isEmpty) {
      setState(() {
        isPasswordEmpty = true;
      });
    }

    if (confirmPasswordText.text.isEmpty) {
      setState(() {
        isConfirmPasswordEmpty = true;
      });
    }

    if (passwordText.text != confirmPasswordText.text) {
      setState(() {
        isConfirmPasswordMatch = false;
      });
    }

    if (!RegExp(r'\d').hasMatch(passwordText.text) && !RegExp('[a-zA-Z]').hasMatch(passwordText.text) && (passwordText.text.length < 6)) {
      setState(() {
        isFulfillPasswordComplexity = false;
      });
    }

    if (widget.isRequiredChangePasswordAfterLogin ? oldPasswordText.text.isEmpty : oldPasswordText.text.isNotEmpty && passwordText.text.isNotEmpty && confirmPasswordText.text.isNotEmpty) {
      updateApiRequest();
    }
  }

  updateApiRequest() async {
    try {
      //Show loading
      showLoader(context);
      UserRequest user = new UserRequest(
          userId: Provider.of<UserProvider>(context, listen: false).getUserDetails.userId,
          firstName: "",
          lastName: "",
          userName: "",
          email: "",
          previousPassword: widget.isRequiredChangePasswordAfterLogin ? "" : oldPasswordText.text,
          password: passwordText.text,
          reEnterPassword: confirmPasswordText.text,
          role: "",
          registerType: "",
          modifiedAt: Provider.of<UserProvider>(context, listen: false).getUserDetails.modifiedAt);

      // Convert to json data
      var convertUserToJson = user.toJson();

      //Get Token
      String? token = Provider.of<UserProvider>(context, listen: false).getUserDetails.token.toString();

      //add Header token
      ApiRequest _apiRepositary = new ApiRequest("Bearer " + token);
      //url for request
      String url = widget.isRequiredChangePasswordAfterLogin ? "api/User/UpdateUserPasswordAfterLogin" : "api/User/updateUserPassword";
      await _apiRepositary.httpPostRequest(url, convertUserToJson, context).then(
        (response) async {
          Loader.hide();
          if (response!.statusCode == 200) {
            dynamic decodedJson = json.decode(response.toString());

            ShowMessageTools.displayToast(decodedJson['jsonLanguageKey'].toString().tr());

            Navigator.pushReplacement(context, PageTransition(alignment: Alignment.bottomCenter, duration: const Duration(milliseconds: 500), type: PageTransitionType.scale, child: HomePage()));
          } else {
            ShowMessageTools.displayToast('systemError'.tr());
          }
        },
        onError: (exception) {
          Loader.hide();
          print("error " + exception.message.toString());
        },
      );
    } on Exception catch (e) {
      print(e.toString());
      Loader.hide();
      ShowMessageTools.displayToast('systemError'.tr());
    }
  }

  @override
  void dispose() {
    super.dispose();
    Loader.hide();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    context.locale;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: widget.isRequiredChangePasswordAfterLogin ? null : NavigationDrawerWidget(widget.pageRouteName),
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(45.0),
          child: AppBar(
            centerTitle: true,
            backgroundColor: Color(0xF6698FFa),
            brightness: Brightness.light,
            leading: widget.isRequiredChangePasswordAfterLogin
                ? null
                : Builder(
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
              "changePassword",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ).tr(),
          )),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              widget.isRequiredChangePasswordAfterLogin
                  ? Text("")
                  : TextField(
                      cursorColor: Color(0xF6698FFa),
                      controller: oldPasswordText,
                      onChanged: (text) {
                        if (isOldPasswordEmpty && text != "") {
                          setState(() {
                            isOldPasswordEmpty = false;
                          });
                        }
                      },
                      decoration: InputDecoration(
                          hintText: 'enterOldPassword'.tr(),
                          labelText: "oldPassword".tr(),
                          errorText: isOldPasswordEmpty ? "valueCannotEmpty".tr() : null,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xF6698FFa)),
                          ),
                          labelStyle: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500),
                          hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                          counterText: ""),
                      maxLength: 30,
                    ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: passwordText,
                cursorColor: Color(0xF6698FFa),
                onChanged: (text) {
                  if (isPasswordEmpty && text != "") {
                    setState(() {
                      isPasswordEmpty = false;
                    });
                  }

                  if (RegExp(r'\d').hasMatch(passwordText.text) && RegExp('[a-zA-Z]').hasMatch(passwordText.text) && (passwordText.text.length >= 6)) {
                    setState(() {
                      isFulfillPasswordComplexity = true;
                    });
                  } else {
                    setState(() {
                      isFulfillPasswordComplexity = false;
                    });
                  }
                },
                decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xF6698FFa)),
                    ),
                    hintText: "enterPassword".tr(),
                    labelText: widget.isRequiredChangePasswordAfterLogin ? "password".tr() : "newPassword".tr(),
                    errorText: isPasswordEmpty
                        ? "valueCannotEmpty".tr()
                        : isFulfillPasswordComplexity
                            ? null
                            : "passwordComplexityNotFulfill".tr(),
                    labelStyle: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500),
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    suffixIcon: IconButton(
                      color: Color(0xF6698FFa),
                      onPressed: () {
                        setState(() {
                          isPasswordHidden = !isPasswordHidden;
                        });
                      },
                      icon: isPasswordHidden ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
                    ),
                    counterText: ""),
                obscureText: isPasswordHidden,
                maxLength: 15,
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: confirmPasswordText,
                cursorColor: Color(0xF6698FFa),
                onChanged: (text) {
                  if (isConfirmPasswordEmpty && text != "") {
                    setState(() {
                      isConfirmPasswordEmpty = false;
                    });
                  }

                  if (passwordText.text != text) {
                    setState(() {
                      isConfirmPasswordMatch = false;
                    });
                  } else {
                    setState(() {
                      isConfirmPasswordMatch = true;
                    });
                  }
                },
                decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xF6698FFa)),
                    ),
                    hintText: "enterConfirmPassword".tr(),
                    labelText: "confirmPassword".tr(),
                    errorText: isConfirmPasswordEmpty
                        ? "valueCannotEmpty".tr()
                        : isConfirmPasswordMatch
                            ? null
                            : "passwordNotMatch".tr(),
                    labelStyle: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500),
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    suffixIcon: IconButton(
                      color: Color(0xF6698FFa),
                      onPressed: () {
                        setState(() {
                          isConfirmPasswordHidden = !isConfirmPasswordHidden;
                        });
                      },
                      icon: isConfirmPasswordHidden ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
                    ),
                    counterText: ""),
                obscureText: isConfirmPasswordHidden,
                maxLength: 15,
              ),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.2,
                child: ElevatedButton(
                  child: Text(
                    'update',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ).tr(),
                  onPressed: () {
                    validateAllInput();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xF6698FFa),
                    onPrimary: Colors.white,
                    padding: EdgeInsets.all(12),
                  ),
                ),
              ),
              widget.isRequiredChangePasswordAfterLogin
                  ? Container(
                      width: MediaQuery.of(context).size.width - 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      margin: EdgeInsets.only(top: 60, left: 10, right: 10, bottom: 20),
                      child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "note",
                                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                    ).tr(),
                                    Flexible(
                                      child: Text(
                                        "promptChangePassword",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ).tr(),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          )))
                  : Text("")
            ],
          ),
        ),
      )),
    );
  }
}
