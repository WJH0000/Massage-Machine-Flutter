import 'dart:io';

import 'package:control_app/utils/apiRequest.dart';
import 'package:control_app/utils/loader.dart';
import 'package:control_app/request/userRequest.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:control_app/const/constant.dart';
import 'package:control_app/utils/showMessageTools.dart';
import 'package:email_validator/email_validator.dart';
import 'package:image_picker/image_picker.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);
  @override
  _RegisterPageState createState() => new _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //Text Controller
  TextEditingController _firstNameText = new TextEditingController();
  TextEditingController _lastNameText = new TextEditingController();
  TextEditingController _userNameText = new TextEditingController();
  TextEditingController _emailText = new TextEditingController();
  TextEditingController _passwordText = new TextEditingController();
  TextEditingController _confirmPasswordText = new TextEditingController();

  //Text Field Empty Check
  bool _isFirstNameEmpty = false;
  bool _isLastNameEmpty = false;
  bool _isUserNameEmpty = false;
  bool _isEmailEmpty = false;
  bool _isEmailFormatCorrect = true;
  bool _isPasswordEmpty = false;
  bool _isConfirmPasswordEmpty = false;
  bool _isPasswordHidden = true;
  bool _isFulfillPasswordComplexity = true;
  bool _isConfirmPasswordHidden = true;
  bool _isConfirmPasswordMatch = true;

  //profile image
  XFile? _profileImage;

  //image picker library
  final ImagePicker _picker = ImagePicker();

  //take image from phone camera
  takeImageFromCamera() async {
    XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _profileImage = image;
    });
  }

  //take image from phone gallery
  takeImageFromGallery() async {
    XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _profileImage = image;
    });
  }

  //select source to take image
  void showSourceImagePicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext buildContext) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text(
                        'phoneGallery',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ).tr(),
                      onTap: () {
                        takeImageFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text(
                      'camera',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ).tr(),
                    onTap: () {
                      takeImageFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  //Validate all required fields
  validateAllInput() async {
    if (_firstNameText.text.isEmpty) {
      setState(() {
        _isFirstNameEmpty = true;
      });
    }

    if (_lastNameText.text.isEmpty) {
      setState(() {
        _isLastNameEmpty = true;
      });
    }

    if (_userNameText.text.isEmpty) {
      setState(() {
        _isUserNameEmpty = true;
      });
    }

    if (_emailText.text.isEmpty) {
      setState(() {
        _isEmailEmpty = true;
      });
    }

    if (_passwordText.text.isEmpty) {
      setState(() {
        _isPasswordEmpty = true;
      });
    }

    if (_confirmPasswordText.text.isEmpty) {
      setState(() {
        _isConfirmPasswordEmpty = true;
      });
    }

    if (_passwordText.text != _confirmPasswordText.text) {
      setState(() {
        _isConfirmPasswordMatch = false;
      });
    }

    if (!RegExp(r'\d').hasMatch(_passwordText.text) && !RegExp('[a-zA-Z]').hasMatch(_passwordText.text) && (_passwordText.text.length < 6)) {
      setState(() {
        _isFulfillPasswordComplexity = false;
      });
    }

    if (_firstNameText.text.isNotEmpty &&
        _lastNameText.text.isNotEmpty &&
        _userNameText.text.isNotEmpty &&
        _emailText.text.isNotEmpty &&
        _passwordText.text.isNotEmpty &&
        _confirmPasswordText.text.isNotEmpty &&
        _isEmailFormatCorrect) {
      await registerApiRequest();
    }
  }

  registerApiRequest() async {
    //Show loading
    showLoader(context);
    try {
      // UserRequest user = new UserRequest(
      //   userId: 0,
      //   firstName: _firstNameText.text,
      //   lastName: _lastNameText.text,
      //   userName: _userNameText.text,
      //   email: _emailText.text,
      //   previousPassword: "",
      //   password: _passwordText.text,
      //   reEnterPassword: _confirmPasswordText.text,
      //   role: "",
      //   registerType: LOGIN_TYPES[2],
      // );

      // Convert to json data
      //var convertUserToJson = user.toJson();

      var formData = FormData.fromMap({
        UserRequestFields.userId: 0,
        UserRequestFields.firstName: _firstNameText.text,
        UserRequestFields.lastName: _lastNameText.text,
        UserRequestFields.userName: _userNameText.text,
        UserRequestFields.email: _emailText.text,
        UserRequestFields.previousPassword: '',
        UserRequestFields.password: _passwordText.text,
        UserRequestFields.reEnterPassword: _confirmPasswordText.text,
        UserRequestFields.role: '',
        UserRequestFields.registerType: LOGIN_TYPES[2],
        UserRequestFields.profileImage: _profileImage != null ? await MultipartFile.fromFile(_profileImage!.path, filename: _profileImage!.name) : null
      });

      //add Header token
      ApiRequest _apiRepositary = new ApiRequest("");
      await _apiRepositary.httpPostRequest("api/User/addUser", formData, context).then(
        (response) {
          if (response!.statusCode == 200) {
            dynamic decodedJson = json.decode(response.toString());
            ShowMessageTools.displayToast(decodedJson['jsonLanguageKey'].toString().tr());
            Navigator.pop(context, false);
          } else {
            ShowMessageTools.displayToast('systemError'.tr());
          }
          Loader.hide();
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
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(45.0),
          child: AppBar(
            centerTitle: true,
            backgroundColor: Color(0xF6698FFa),
            brightness: Brightness.light,
            leading: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_left,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
            title: Text(
              "register",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ).tr(),
          )),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 10),
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(height: 100), // This container is needed only to set the overall stack height
                    // for Text to be a bit below Circleavatar
                    GestureDetector(
                      onTap: () {
                        showSourceImagePicker(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        height: 90.0,
                        width: 90.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(45),
                          color: Colors.red,
                          border: Border.all(width: 4, color: Colors.red),
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.grey[300],
                          child: _profileImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.file(
                                    File(_profileImage!.path),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(50)),
                                  width: 100,
                                  height: 100,
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.grey[800],
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35),
                          color: Colors.red,
                        ),
                        child: Text(
                          'tapToUpload',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ).tr(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Flexible(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new TextField(
                        cursorColor: Color(0xF6698FFa),
                        controller: _firstNameText,
                        onChanged: (text) {
                          if (_isFirstNameEmpty && text != "") {
                            setState(() {
                              _isFirstNameEmpty = false;
                            });
                          }
                        },
                        decoration: InputDecoration(
                            labelText: "firstName".tr(),
                            hintText: 'enterFirstName'.tr(),
                            errorText: _isFirstNameEmpty ? "valueCannotEmpty".tr() : null,
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xF6698FFa)),
                            ),
                            hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                            labelStyle: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500),
                            counterText: ""),
                        maxLength: 30,
                      ),
                    ],
                  )),
                  SizedBox(
                    width: 20.0,
                  ),
                  new Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        new TextField(
                          cursorColor: Color(0xF6698FFa),
                          controller: _lastNameText,
                          onChanged: (text) {
                            if (_isLastNameEmpty && text != "") {
                              setState(() {
                                _isLastNameEmpty = false;
                              });
                            }
                          },
                          decoration: InputDecoration(
                              labelText: "lastName".tr(),
                              hintText: 'enterLastName'.tr(),
                              errorText: _isLastNameEmpty ? "valueCannotEmpty".tr() : null,
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xF6698FFa)),
                              ),
                              hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                              labelStyle: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500),
                              counterText: ""),
                          maxLength: 30,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                cursorColor: Color(0xF6698FFa),
                controller: _userNameText,
                onChanged: (text) {
                  if (_isUserNameEmpty && text != "") {
                    setState(() {
                      _isUserNameEmpty = false;
                    });
                  }
                },
                decoration: InputDecoration(
                    labelText: "userName".tr(),
                    hintText: 'enterUserName'.tr(),
                    errorText: _isUserNameEmpty ? "valueCannotEmpty".tr() : null,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xF6698FFa)),
                    ),
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    labelStyle: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500),
                    counterText: ""),
                maxLength: 30,
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                cursorColor: Color(0xF6698FFa),
                controller: _emailText,
                onChanged: (text) {
                  bool isValidEmailFormat = EmailValidator.validate(text);

                  if (_isEmailEmpty && text != "") {
                    setState(() {
                      _isEmailEmpty = false;
                    });
                  }

                  if (!isValidEmailFormat) {
                    setState(() {
                      _isEmailFormatCorrect = false;
                    });
                  } else {
                    setState(() {
                      _isEmailFormatCorrect = true;
                    });
                  }
                },
                decoration: InputDecoration(
                    hintText: 'enterEmail'.tr(),
                    labelText: "email".tr(),
                    errorText: _isEmailEmpty
                        ? "valueCannotEmpty".tr()
                        : !_isEmailFormatCorrect
                            ? "emailFormatIncorrect".tr()
                            : null,
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
                controller: _passwordText,
                cursorColor: Color(0xF6698FFa),
                onChanged: (text) {
                  if (_isPasswordEmpty && text != "") {
                    setState(() {
                      _isPasswordEmpty = false;
                    });
                  }

                  if (RegExp(r'\d').hasMatch(_passwordText.text) && RegExp('[a-zA-Z]').hasMatch(_passwordText.text) && (_passwordText.text.length >= 6)) {
                    setState(() {
                      _isFulfillPasswordComplexity = true;
                    });
                  } else {
                    setState(() {
                      _isFulfillPasswordComplexity = false;
                    });
                  }
                },
                decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xF6698FFa)),
                    ),
                    hintText: "enterPassword".tr(),
                    labelText: "password".tr(),
                    errorText: _isPasswordEmpty
                        ? "valueCannotEmpty".tr()
                        : _isFulfillPasswordComplexity
                            ? null
                            : "passwordComplexityNotFulfill".tr(),
                    labelStyle: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500),
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    suffixIcon: IconButton(
                      color: Color(0xF6698FFa),
                      onPressed: () {
                        setState(() {
                          _isPasswordHidden = !_isPasswordHidden;
                        });
                      },
                      icon: _isPasswordHidden ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
                    ),
                    counterText: ""),
                obscureText: _isPasswordHidden,
                maxLength: 15,
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: _confirmPasswordText,
                cursorColor: Color(0xF6698FFa),
                onChanged: (text) {
                  if (_isConfirmPasswordEmpty && text != "") {
                    setState(() {
                      _isConfirmPasswordEmpty = false;
                    });
                  }

                  if (_passwordText.text != text) {
                    setState(() {
                      _isConfirmPasswordMatch = false;
                    });
                  } else {
                    setState(() {
                      _isConfirmPasswordMatch = true;
                    });
                  }
                },
                decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xF6698FFa)),
                    ),
                    hintText: "enterConfirmPassword".tr(),
                    labelText: "confirmPassword".tr(),
                    errorText: _isConfirmPasswordEmpty
                        ? "valueCannotEmpty".tr()
                        : _isConfirmPasswordMatch
                            ? null
                            : "passwordNotMatch".tr(),
                    labelStyle: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500),
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    suffixIcon: IconButton(
                      color: Color(0xF6698FFa),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                        });
                      },
                      icon: _isConfirmPasswordHidden ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
                    ),
                    counterText: ""),
                obscureText: _isConfirmPasswordHidden,
                maxLength: 15,
              ),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.2,
                child: ElevatedButton(
                  child: Text(
                    'register',
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
            ],
          ),
        ),
      )),
    );
  }
}
