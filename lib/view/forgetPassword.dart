import 'dart:convert';
import 'package:control_app/utils/apiRequest.dart';
import 'package:control_app/utils/loader.dart';
import 'package:control_app/utils/showMessageTools.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

class RetrievePasswordByEmailPage extends StatefulWidget {
  RetrievePasswordByEmailPage({Key? key}) : super(key: key);
  @override
  RetrievePasswordByEmailPageState createState() => new RetrievePasswordByEmailPageState();
}

class RetrievePasswordByEmailPageState extends State<RetrievePasswordByEmailPage> {
  //Text Controller
  var emailText = new TextEditingController();

  //Text Field Empty Check
  bool isEmailEmpty = false;
  bool isEmailFormatCorrect = true;

  //Validate email input
  validateInput() async {
    if (emailText.text.isEmpty) {
      setState(() {
        isEmailEmpty = true;
      });
    }

    if (emailText.text.isNotEmpty && isEmailFormatCorrect) {
      String url = "api/ResetPassword/resetPassword/?email=" + emailText.text;
      //Show loading
      showLoader(context);
      await postApiRequest(url, null);
    }
  }

  postApiRequest(String url, dynamic convertLoginToJson) async {
    try {
      //add Header token
      ApiRequest _apiRepositary = new ApiRequest("");
      await _apiRepositary.httpPostRequest(url, convertLoginToJson, context).then(
        (response) async {
          if (response!.statusCode == 200) {
            dynamic decodedJson = json.decode(response.toString());
            ShowMessageTools.displayToast(decodedJson['jsonLanguageKey'].toString().tr());

            Navigator.pop(context);
          } else {
            ShowMessageTools.displayToast('systemError'.tr());
          }
          Loader.hide();
        },
        onError: (exception) {
          Loader.hide();
        },
      );
    } on Exception catch (e) {
      print(e.toString());
      Loader.hide();
      ShowMessageTools.displayToast('systemError'.tr());
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    //hide loader
    Loader.hide();
    // MassageDatabase.instance.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(45.0),
            child: new AppBar(
              backgroundColor: Color(0xF6698FFa),
              title: Text(
                "forgePassword",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ).tr(),
              centerTitle: true,
              brightness: Brightness.light,
              leading: IconButton(
                icon: Icon(
                  Icons.keyboard_arrow_left,
                  size: 30,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context, false),
              ),
            )),
        body: SafeArea(
            child: Container(
                margin: EdgeInsets.all(40),
                child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                  Text(
                    "retrievePasswordByEmail",
                    style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ).tr(),
                  SizedBox(
                    height: 30,
                  ),
                  TextField(
                      controller: emailText,
                      onChanged: (text) {
                        bool isValidEmailFormat = EmailValidator.validate(text);

                        if (isEmailEmpty && text != "") {
                          setState(() {
                            isEmailEmpty = false;
                          });
                        }

                        if (!isValidEmailFormat && text != "") {
                          setState(() {
                            isEmailFormatCorrect = false;
                          });
                        } else {
                          setState(() {
                            isEmailFormatCorrect = true;
                          });
                        }
                      },
                      decoration: InputDecoration(
                          hintText: 'enterEmail'.tr(),
                          errorText: isEmailEmpty
                              ? "valueCannotEmpty".tr()
                              : !isEmailFormatCorrect
                                  ? "emailFormatIncorrect".tr()
                                  : null,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xF6698FFa)),
                          ),
                          hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                          labelStyle: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500),
                          counterText: ""),
                      maxLength: 30),
                  SizedBox(
                    height: 80,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.2,
                    child: ElevatedButton(
                      child: Text(
                        'submit',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ).tr(),
                      onPressed: () async {
                        await validateInput();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xF6698FFa),
                        onPrimary: Colors.white,
                        padding: EdgeInsets.all(12),
                      ),
                    ),
                  ),
                ]))));
  }
}
