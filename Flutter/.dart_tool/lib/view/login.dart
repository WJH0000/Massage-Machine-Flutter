import 'dart:convert';
import 'dart:typed_data';
import 'package:control_app/utils/apiRequest.dart';
import 'package:control_app/utils/loader.dart';
import 'package:control_app/utils/showMessageTools.dart';
import 'package:control_app/const/constant.dart';
import 'package:control_app/db/massage_database.dart';
import 'package:control_app/providers/userProvider.dart';
import 'package:control_app/request/socialAccountLoginRequest.dart';
import 'package:control_app/request/loginRequest.dart';
import 'package:control_app/model/user.dart';
import 'package:control_app/utils/uint8ListConverter.dart';
import 'package:control_app/view/changePassword.dart';
import 'package:control_app/view/forgetPassword.dart';
import 'package:control_app/view/homePage.dart';
import 'package:control_app/view/setLanguage.dart';
import 'package:control_app/view/register.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:provider/provider.dart';
import 'package:control_app/const/constant.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/loginPage';
  final pageRouteName = routeName;
  LoginPage({Key? key}) : super(key: key);
  @override
  LoginPageState createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  //Text Controller
  TextEditingController usernameText = new TextEditingController();
  TextEditingController passwordText = new TextEditingController();

  //Text Field Empty Check
  bool isUsernameEmpty = false;
  bool isPasswordEmpty = false;

  //Check whether text field is dirty
  bool isUsernameDirty = false;
  bool isPasswordDirty = false;

  //Hide password
  bool hidePassword = true;

  //For Google Authentication extract data
  static Map<String, dynamic>? googleAuthenticationParseJwt(String token) {
    // validate token
    // ignore: unnecessary_null_comparison
    if (token == null) return null;
    final List<String> parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }
    // retrieve token payload
    final String payload = parts[1];
    final String normalized = base64Url.normalize(payload);
    final String resp = utf8.decode(base64Url.decode(normalized));
    // convert to Map
    final payloadMap = json.decode(resp);
    if (payloadMap is! Map<String, dynamic>) {
      return null;
    }
    return payloadMap;
  }

  //Vqalidate login details
  validateAllInput() async {
    if (usernameText.text.isEmpty) {
      setState(() {
        isUsernameEmpty = true;
      });
    }

    if (passwordText.text.isEmpty) {
      setState(() {
        isPasswordEmpty = true;
      });
    }

    if (usernameText.text.isNotEmpty && passwordText.text.isNotEmpty) {
      LoginRequest loginRequest = new LoginRequest(
          username: usernameText.text,
          password: passwordText.text,
          loginPlatform: LOGIN_TYPES[2]);

      // Convert to json data
      dynamic convertLoginRequestToJson = loginRequest.toJson();

      String url = "api/Authentication/authenticateUser";

      //Show loading
      showLoader(context);
      await postApiRequest(url, convertLoginRequestToJson);
    }

    Uint8List bytes =
        (await NetworkAssetBundle(Uri.parse(baseUrl + 'images/default.png'))
                .load(baseUrl + 'images/default.png'))
            .buffer
            .asUint8List();
  }

  postApiRequest(String url, dynamic convertLoginToJson) async {
    try {
      //add Header token
      ApiRequest _apiRepositary = new ApiRequest("");
      await _apiRepositary
          .httpPostRequest(url, convertLoginToJson, context)
          .then(
        (response) async {
          if (response!.statusCode == 200) {
            dynamic decodedJson = json.decode(response.toString());

            //authentication token
            var token = decodedJson['data']['token'];

            //Convert from json to user object
            User user = User.fromJson(decodedJson['data']['user'], token);

            //complete url path for the profile image
            String fullImagePath = baseUrl + user.profileImagePath!;

            //download the profile image source
            Uint8List profileImageSource =
                await Uint8ListConverter.networkImageToUint8List(fullImagePath);

            //assign base64 souce to user object
            user.setProfileImageSource = profileImageSource;

            //Save user info to sqlite
            await MassageDatabase.instance.addUser(user);

            //Check before allow login
            try {
              User retrieveUser =
                  await MassageDatabase.instance.getUser(user.userId);
              if (retrieveUser.userId != 0) {
                // add user to provider
                Provider.of<UserProvider>(context, listen: false).setUser(user);

                bool isRequiredChangePassword =
                    decodedJson['isRequiredChangePassword'];
                if (isRequiredChangePassword) {
                  Navigator.pushReplacement(
                      context,
                      PageTransition(
                          childCurrent: LoginPage(),
                          type: PageTransitionType.rightToLeftJoined,
                          child: ChangePasswordPage(true)));
                } else {
                  ShowMessageTools.displayToast(
                      decodedJson['jsonLanguageKey'].toString().tr());
                  Navigator.pushReplacement(
                      context,
                      PageTransition(
                          alignment: Alignment.bottomCenter,
                          duration: const Duration(milliseconds: 500),
                          type: PageTransitionType.scale,
                          child: HomePage()));
                }
              } else {
                ShowMessageTools.displayToast("loginFailed".tr());
              }
            } on Exception catch (e) {
              print(e);
              ShowMessageTools.displayToast("loginFailed".tr());
            }
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

  facebookLogin() async {
    //Show loading
    showLoader(context);
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      ); // by default we request the email and the public profile

      if (result.status == LoginStatus.success) {
        // you are logged

        //Retrieve token
        final AccessToken accessToken = result.accessToken!;

        final socialAccountInfo = await FacebookAuth.instance.getUserData(
          fields: "first_name,last_name, name,email, picture.width(200)",
        );

        String profileImageUrl = socialAccountInfo['picture']['data']['url'];

        String convertedbase64Image =
            await networkImageToBase64(profileImageUrl);

        //Construct social account login request
        SocialAccountLoginRequest socialAccountLoginRequest =
            new SocialAccountLoginRequest(
                firstName: socialAccountInfo['first_name'],
                lastName: socialAccountInfo['last_name'],
                userName: socialAccountInfo['name'],
                email: socialAccountInfo['email'],
                socialAccountToken: accessToken.token.toString(),
                socialAccountId: socialAccountInfo['id'],
                registerType: LOGIN_TYPES[1],
                base64ProfileImage: convertedbase64Image);

        // Convert to json data
        dynamic convertSocialAccountLoginRequestToJson =
            socialAccountLoginRequest.toJson();

        String url = "api/Authentication/socialAccountLogin";

        //API Request
        await postApiRequest(url, convertSocialAccountLoginRequestToJson);
      } else {
        //Hide loader
        Loader.hide();

        //Display and snackBar
        final SnackBar snackBar = SnackBar(
          content: Text(
            "loginFailed",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ).tr(),
          backgroundColor: Colors.redAccent,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } on Exception catch (e) {
      print(e.toString());
      Loader.hide();
      ShowMessageTools.displayToast('systemError'.tr());
    }
  }

  googleLogin() async {
    //Show loading
    showLoader(context);

    try {
      //Sign In Google Account+
      await googleSignIn.signIn().then((userData) async {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await userData!.authentication;

        //Extract data from idToken
        Map<String, dynamic>? socialAccountInfo =
            googleAuthenticationParseJwt(googleSignInAuthentication.idToken!);

        String profileImageUrl = socialAccountInfo!['picture'];

        String convertedbase64Image =
            await networkImageToBase64(profileImageUrl);

        //Construct social account login request
        SocialAccountLoginRequest socialAccountLoginRequest =
            new SocialAccountLoginRequest(
                firstName: socialAccountInfo['given_name'],
                lastName: socialAccountInfo['family_name'],
                userName: socialAccountInfo['name'],
                email: socialAccountInfo['email'],
                socialAccountToken:
                    googleSignInAuthentication.idToken.toString(),
                socialAccountId: socialAccountInfo['sub'],
                registerType: LOGIN_TYPES[0],
                base64ProfileImage: convertedbase64Image);

        // Convert to json data
        dynamic convertSocialAccountLoginRequestToJson =
            socialAccountLoginRequest.toJson();

        String url = "api/Authentication/socialAccountLogin";

        //API Request
        await postApiRequest(url, convertSocialAccountLoginRequestToJson);
      }).catchError((e) {
        //Hide loader
        Loader.hide();

        //Display and snackBar
        final SnackBar snackBar = SnackBar(
          content: Text(
            "loginFailed",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ).tr(),
          backgroundColor: Colors.redAccent,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } on Exception catch (e) {
      print(e.toString());
      Loader.hide();
      ShowMessageTools.displayToast('systemError'.tr());
    }
  }

  //convert network image to base64
  Future<String> networkImageToBase64(String imageUrl) async {
    http.Response response = await http.get(Uri.parse(imageUrl));

    final bytes = response.bodyBytes;

    String base64 = base64Encode(bytes);

    return base64;
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
  }

  @override
  Widget build(BuildContext context) {
    context.locale;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            top: false,
            child: new Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  image: new DecorationImage(
                      image: AssetImage('assets/img/background.png'),
                      fit: BoxFit.fill),
                ),
                child: SingleChildScrollView(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new SizedBox(
                        height: 20.0,
                      ),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          IconButton(
                            padding: EdgeInsets.only(top: 20),
                            icon: Icon(
                              Icons.language,
                              size: 35,
                            ),
                            onPressed: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => SetLanguagePage(
                              //             isAfterLogin: false,
                              //           )),
                              // );

                              Navigator.push(
                                  context,
                                  PageTransition(
                                      //    alignment: Alignment.center,
                                      childCurrent: LoginPage(),
                                      type:
                                          PageTransitionType.rightToLeftJoined,
                                      child: SetLanguagePage(
                                        isAfterLogin: false,
                                      )));
                            },
                          ),
                          new SizedBox(
                            width: 10.0,
                          ),
                        ],
                      ),
                      new Container(
                          child: new Image(
                        image: AssetImage('assets/img/logo.png'),
                        width: 150,
                        height: 150,
                      )),
                      new SizedBox(
                        height: 15.0,
                      ),
                      new Text(
                        "welcome",
                        style: new TextStyle(fontSize: 22.0),
                      ).tr(),
                      new SizedBox(
                        height: 20.0,
                      ),
                      new SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 1.2,
                        height: 45,
                        padding: EdgeInsets.only(left: 15, right: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 3)
                            ]),
                        child: TextField(
                          maxLength: 30,
                          controller: usernameText,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.person_outline,
                              color: Color(0xF6698FFa),
                            ),
                            hintText: isUsernameEmpty
                                ? tr('pleaseEnterUserName')
                                : tr('userName'),
                            hintStyle: isUsernameEmpty
                                ? TextStyle(fontSize: 14, color: Colors.red)
                                : TextStyle(fontSize: 14),
                            counterText: "",
                            suffixIcon: isUsernameDirty
                                ? InkWell(
                                    onTap: () {
                                      setState(() {
                                        usernameText.clear();
                                        isUsernameDirty = false;
                                      });
                                    },
                                    child: Container(
                                      decoration: new BoxDecoration(
                                        borderRadius: new BorderRadius.all(
                                            new Radius.circular(40.0)),
                                        color: Colors.grey[300],
                                      ),
                                      margin: EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 9,
                                          bottom: 9),
                                      child: Icon(
                                        Icons.clear,
                                        size: 13,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            if (value.isEmpty) {
                              setState(() {
                                isUsernameDirty = false;
                              });
                            } else {
                              setState(() {
                                isUsernameDirty = true;
                              });
                            }
                          },
                          cursorColor: Colors.blue[900],
                        ),
                      ),
                      new SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 1.2,
                        height: 45,
                        padding: EdgeInsets.only(left: 15, right: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 3)
                            ]),
                        child: TextField(
                          maxLength: 30,
                          controller: passwordText,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                Icons.lock_outline,
                                color: Color(0xF6698FFa),
                                size: 20,
                              ),
                              hintText: isPasswordEmpty
                                  ? tr('pleaseEnterPassword')
                                  : tr('password'),
                              hintStyle: isPasswordEmpty
                                  ? TextStyle(fontSize: 14, color: Colors.red)
                                  : TextStyle(fontSize: 14),
                              counterText: "",
                              suffixIcon: isPasswordDirty
                                  ? InkWell(
                                      onTap: () {
                                        setState(() {
                                          //passwordText.clear();
                                          hidePassword = !hidePassword;
                                          // isPasswordDirty = false;
                                        });
                                      },
                                      child: Container(
                                        // decoration: new BoxDecoration(
                                        //   borderRadius: new BorderRadius.all(new Radius.circular(40.0)),
                                        //   color: Colors.grey[300],
                                        // ),
                                        margin: EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 9,
                                            bottom: 9),
                                        child: hidePassword
                                            ? Icon(
                                                Icons.visibility_off,
                                                size: 20,
                                              )
                                            : Icon(
                                                Icons.visibility,
                                                size: 20,
                                              ),
                                      ),
                                    )
                                  : null),
                          obscureText: hidePassword,
                          cursorColor: Colors.blue[900],
                          onChanged: (value) {
                            if (value.isEmpty) {
                              setState(() {
                                isPasswordDirty = false;
                              });
                            } else {
                              setState(() {
                                isPasswordDirty = true;
                              });
                            }
                          },
                        ),
                      ),
                      new SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.2,
                        child: ElevatedButton(
                          child: Text(
                            'login',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ).tr(),
                          onPressed: () {
                            // Navigator.pushReplacement(
                            //     context,
                            //     PageTransition(
                            //         type: PageTransitionType.bottomToTop,
                            //         child: HomePage()));
                            validateAllInput();
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xF6698FFa),
                            onPrimary: Colors.white,
                            padding: EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                          ),
                        ),
                      ),
                      new SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.2,
                        child: ElevatedButton(
                          child: Text(
                            'register',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ).tr(),
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => RegisterPage()),
                            // );
                            Navigator.push(
                                context,
                                PageTransition(
                                    childCurrent: LoginPage(),
                                    type: PageTransitionType.rightToLeftJoined,
                                    child: RegisterPage()));
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFFa2bffc),
                            onPrimary: Colors.white,
                            padding: EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                          ),
                        ),
                      ),
                      new SizedBox(
                        height: 25,
                      ),
                      InkWell(
                        // When the user taps the button, show a snackbar.
                        onTap: () {
                          // ScaffoldMessenger.of(context)
                          //     .showSnackBar(const SnackBar(
                          //   content: Text('Tap'),
                          // ));
                          Navigator.push(
                              context,
                              PageTransition(
                                  childCurrent: LoginPage(),
                                  type: PageTransitionType.rightToLeftJoined,
                                  child: RetrievePasswordByEmailPage()));
                        },
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text('forgePassword').tr(),
                        ),
                      ),
                      new SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 50,
                            icon: const Icon(Icons.facebook),
                            color: Colors.blue,
                            onPressed: () async {
                              facebookLogin();
                            },
                          ),
                          IconButton(
                            iconSize: 37,
                            icon: Image.asset('assets/img/google.png'),
                            color: Colors.blue,
                            onPressed: () async {
                              await googleLogin();
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ))));
  }
}
