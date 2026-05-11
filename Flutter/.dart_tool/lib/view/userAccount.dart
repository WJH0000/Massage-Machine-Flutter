import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:control_app/const/constant.dart';
import 'package:control_app/utils/apiRequest.dart';
import 'package:control_app/utils/loader.dart';
import 'package:control_app/utils/showMessageTools.dart';
import 'package:control_app/db/massage_database.dart';
import 'package:control_app/model/user.dart';
import 'package:control_app/providers/userProvider.dart';
import 'package:control_app/request/userRequest.dart';
import 'package:control_app/utils/uint8ListConverter.dart';
import 'package:control_app/widgets/navigation_drawer.dart';
import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UserAccountPage extends StatefulWidget {
  static const routeName = '/userAccountPage';
  final pageRouteName = routeName;
  UserAccountPage({Key? key}) : super(key: key);
  @override
  _UserAccountPageState createState() => new _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  //Text Controller
  TextEditingController _firstNameText = new TextEditingController();
  TextEditingController _lastNameText = new TextEditingController();
  TextEditingController _userNameText = new TextEditingController();
  TextEditingController _emailText = new TextEditingController();

  //Text Field Empty Check
  bool _isFirstNameEmpty = false;
  bool _isLastNameEmpty = false;
  bool _isUserNameEmpty = false;
  bool _isEmailEmpty = false;
  bool _isEmailFormatCorrect = true;

  //first load
  bool _loaded = false;

  //profile image
  XFile? _profileImage;

  Uint8List? _profileImageFromByte;

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

  validateAllInput() {
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

    if (_firstNameText.text.isNotEmpty && _lastNameText.text.isNotEmpty && _userNameText.text.isNotEmpty && _emailText.text.isNotEmpty) {
      updateApiRequest();
    }
  }

  updateApiRequest() async {
    //Show loading
    showLoader(context);
    try {
      // UserRequest user = new UserRequest(
      //     userId: Provider.of<UserProvider>(context, listen: false).getUserDetails.userId,
      //     firstName: _firstNameText.text,
      //     lastName: _lastNameText.text,
      //     userName: _userNameText.text,
      //     email: _emailText.text,
      //     previousPassword: "",
      //     password: "",
      //     reEnterPassword: "",
      //     role: "",
      //     registerType: "",
      //     modifiedAt: Provider.of<UserProvider>(context, listen: false).getUserDetails.modifiedAt);
      String modifiedDateTime = Provider.of<UserProvider>(context, listen: false).getUserDetails.modifiedAt.toString();

      var formData = FormData.fromMap({
        UserRequestFields.userId: Provider.of<UserProvider>(context, listen: false).getUserDetails.userId,
        UserRequestFields.firstName: _firstNameText.text,
        UserRequestFields.lastName: _lastNameText.text,
        UserRequestFields.userName: _userNameText.text,
        UserRequestFields.email: _emailText.text,
        UserRequestFields.previousPassword: '',
        UserRequestFields.password: '',
        UserRequestFields.reEnterPassword: '',
        UserRequestFields.role: '',
        UserRequestFields.registerType: '',
        UserRequestFields.modifiedAt: DateTime.tryParse(modifiedDateTime) == null ? null : DateTime.parse(modifiedDateTime.split("+08:00")[0]),
        UserRequestFields.profileImage: _profileImage != null ? await MultipartFile.fromFile(_profileImage!.path, filename: _profileImage!.name) : null
      });

      // Convert to json data
      // var convertUserToJson = user.toJson();

      //Get Token
      String? token = Provider.of<UserProvider>(context, listen: false).getUserDetails.token.toString();

      //add Header token
      ApiRequest _apiRepositary = new ApiRequest("Bearer " + token);
      await _apiRepositary.httpPostRequest("api/User/updateUserDetails", formData, context).then(
        (response) async {
          if (response!.statusCode == 200) {
            dynamic decodedJson = json.decode(response.toString());

            //Convert from json to user object
            User user = User.fromJson(decodedJson['data'], token);

            //complete url path for the profile image
            String fullImagePath = baseUrl + user.profileImagePath!;

            //download the profile image source
            Uint8List profileImageSource = await Uint8ListConverter.networkImageToUint8List(fullImagePath);

            //assign base64 souce to user object
            user.setProfileImageSource = profileImageSource;

            //Update user to sqlite
            await MassageDatabase.instance.updateUser(user);

            // Update user to provider
            Provider.of<UserProvider>(context, listen: false).setUser(user);

            ShowMessageTools.displayToast(decodedJson['jsonLanguageKey'].toString().tr());
          } else {
            ShowMessageTools.displayToast('systemError'.tr());
          }
          Loader.hide();
        },
        onError: (exception) async {
          Loader.hide();
          print("error " + exception.message.toString());

          if (exception.message.response!.data != null) {
            dynamic decodedJson = json.decode(exception.message.response.toString());

            if (decodedJson['data'] != null) {
              //Convert from json to user object
              User user = User.fromJson(decodedJson['data'], token);

              //Update user to sqlite
              await MassageDatabase.instance.updateUserModifyDate(user);
            }
          }
        },
      );
    } on Exception catch (e) {
      print(e.toString());
      Loader.hide();
      ShowMessageTools.displayToast('systemError'.tr());
    }
  }

  getUserDetails(context) async {
    //Show loading
    showLoader(context);

    try {
      //Get Token
      String? token = Provider.of<UserProvider>(context, listen: false).getUserDetails.token.toString();

      //add Header token
      ApiRequest _apiRepositary = new ApiRequest("Bearer " + token);

      //Get user Id
      //int? userId = Provider.of<UserProvider>(context, listen: false).getUserDetails.userId;

      await _apiRepositary.httpGetRequest("api/User/getUserDetails", context).then(
        (response) async {
          if (response!.statusCode == 200) {
            dynamic decodedJson = json.decode(response.toString());
            if (decodedJson['jsonLanguageKey'].toString() == "") {
              //Convert from json to user object
              User user = User.fromJson(decodedJson['data'], token);

              //complete url path for the profile image
              String fullImagePath = baseUrl + user.profileImagePath!;

              //download the profile image source
              Uint8List profileImageSource = await Uint8ListConverter.networkImageToUint8List(fullImagePath);

              setState(() {
                _profileImageFromByte = profileImageSource;
              });

              //assign base64 souce to user object
              user.setProfileImageSource = profileImageSource;

              //Update user to sqlite
              await MassageDatabase.instance.updateUser(user);

              // Update user to provider
              Provider.of<UserProvider>(context, listen: false).setUser(user);

              //initialize value
              _firstNameText.text = Provider.of<UserProvider>(context, listen: false).getUserDetails.firstName!;
              _lastNameText.text = Provider.of<UserProvider>(context, listen: false).getUserDetails.lastName!;
              _userNameText.text = Provider.of<UserProvider>(context, listen: false).getUserDetails.userName!;
              _emailText.text = Provider.of<UserProvider>(context, listen: false).getUserDetails.email!;
            }
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
  void dispose() {
    super.dispose();
    Loader.hide();
  }

  @override
  void initState() {
    super.initState();
    // new Future.delayed(Duration.zero).then((value) {
    //   getUserDetails(context);
    // });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      getUserDetails(context);
      setState(() {
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    context.locale;
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              "userDetails",
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
                                  child: _profileImageFromByte != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(50),
                                          child: Image.memory(
                                            _profileImageFromByte!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Icon(
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
                height: 10,
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
            ],
          ),
        ),
      )),
    );
  }
}
