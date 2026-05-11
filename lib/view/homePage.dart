import 'dart:convert';
import 'dart:typed_data';
import 'package:control_app/const/constant.dart';
import 'package:control_app/model/doctorRecommendMassageSetting.dart';
import 'package:control_app/model/user.dart';
import 'package:control_app/providers/userProvider.dart';
import 'package:control_app/utils/showMessageTools.dart';
import 'package:control_app/view/doctorRecommendListPage.dart';
import 'package:control_app/widgets/badge.dart';
import 'package:control_app/widgets/navigation_drawer.dart';
import 'package:control_app/styles/button_styles.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:page_transition/page_transition.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'bluetoothList.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:control_app/view/SelfCustomizedPage.dart';


final TextEditingController _sequenceController = TextEditingController();

void sendSequenceToMotor(String sequence) async {
  final ip = 'http://10.0.0.106'; // replace with your ESP32 IP
  final url = Uri.parse('$ip/start?seq=$sequence');

  try {
    final response = await http.get(url);
    print('Response: ${response.body}');
  } catch (e) {
    print('Failed to send command: $e');
  }
}

class HomePage extends StatefulWidget {
  static const routeName = '/homePage';
  final pageRouteName = routeName;
  HomePage({Key? key}) : super(key: key);
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  bool emailEmpty = false;
  bool runCookies = false;
  bool getDataLoading = true;

  var emailText = new TextEditingController();

  var csrfNameKey = "";
  var csrfValueKey = "";
  var csrfName = "";
  var csrfValue = "";

  var userName = "";
  var currentLanguage = "";

  Map<String, String> headers = {};

  User user = new User();

  Future<Uint8List> networkImageToBase64(String imageUrl) async {
    http.Response response =
        await http.get(Uri.parse(baseUrl + 'images/default.png'));

    final bytes = response.bodyBytes;
    //return (bytes != null ? base64Encode(bytes) : null);
    String base64 = base64Encode(bytes);
    // final user = Provider.of<UserProvider>(context, listen: false).getUserDetails;

    return base64Decode(base64);
  }

  void sendCommandToMotor(String command) async {
    final ip = 'http://100.0.0.106'; // Replace with your ESP32 IP
    final url = Uri.parse('$ip/$command');

    try {
      final response = await http.get(url);
      print('Response: ${response.body}');
      // Optionally show a snackbar or dialog here
    } catch (e) {
      print('Failed to send command: $e');
    }
  }

  bool show = true;

  //
  final _dialog = RatingDialog(
    initialRating: 1.0,
    // your app's name?
    title: Text(
      'Rating Dialog',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
    ),
    // encourage your user to leave a high rating?
    message: Text(
      'Tap a star to set your rating. Add more description here if you want.',
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 15),
    ),
    // your app's logo?
    image: const FlutterLogo(size: 100),
    submitButtonText: 'Submit',
    commentHint: 'Set your custom comment hint',
    onCancelled: () => print('cancelled'),
    onSubmitted: (response) {
      print('rating: ${response.rating}, comment: ${response.comment}');

      // TODO: add your own logic
      if (response.rating < 3.0) {
        // send their comments to your email or anywhere you wish
        // ask the user to contact you instead of leaving a bad review
      } else {
        //_rateAndReviewApp();
      }
    },
  );

  @override
  void initState() {
    super.initState();
    setState(() {
      user = Provider.of<UserProvider>(context, listen: false).getUserDetails;
    });
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
    context.locale;
    return Scaffold(
        drawer: NavigationDrawerWidget(widget.pageRouteName),
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(45.0),
            child: new AppBar(
              backgroundColor: Color(0xF6698FFa),
              title: Text(
                "homePage",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ).tr(),
              centerTitle: true,
              brightness: Brightness.light,
            )),
        body: SingleChildScrollView(
            child: SafeArea(
                child: Container(
                    margin: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(top: 55),
                    child: Column(
                        //mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Material(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            elevation: 18,
                            color: Color(0xFFa2bffc),
                            clipBehavior: Clip.antiAlias, // Add This
                            child: InkWell(
                                // When the user taps the button, show a snackbar.
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.rightToLeft,
                                      child:
                                          SelfCustomizedPage(), // import this
                                    ),
                                  );
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.2,
                                  padding: EdgeInsets.only(bottom: 10, top: 15),
                                  child: Column(
                                    children: [
                                      new Image(
                                        image: AssetImage(
                                            'assets/img/holdPhone.png'),
                                        width: 150,
                                        height: 150,
                                      ),
                                      Text(
                                        "selfCustomize",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ).tr(),
                                    ],
                                  ),
                                )),
                          ),
                          new SizedBox(
                            height: 40,
                          ),
                          Material(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            elevation: 18,
                            color: Colors.blue,
                            clipBehavior: Clip.antiAlias, // Add This
                            child: InkWell(
                                // When the user taps the button, show a snackbar.
                                onTap: () {
                                  // ScaffoldMessenger.of(context)
                                  //     .showSnackBar(const SnackBar(
                                  //   content: Text('Tap'),
                                  // ));
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: BluetoothListPage(
                                            isGetDoctorRecommend: false,
                                            doctorRecommendMassageSetting:
                                                new DoctorRecommendMassageSetting(),
                                          )));
                                },
                                
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.2,
                                  // padding: EdgeInsets.only(bottom: 15, top: 15),
                                  height: 200,
                                  child: Stack(children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: new Image(
                                        image:
                                            AssetImage('assets/img/doctor.png'),
                                        width: 150,
                                        height: 150,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment(0.0, 0.9),
                                      child: Text(
                                        "doctorRecommend",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ).tr(),
                                    ),
                                    // Positioned(
                                    //   left: -35,
                                    //   top: 27,
                                    //   child: buildBadge(),
                                    // ),
                                  ]),
                                )),
                          ),
                          // Container(
                          //   decoration: BoxDecoration(
                          //       color: Colors.green,
                          //       image: DecorationImage(
                          //         image: MemoryImage(user.profileImageSource!),
                          //       )),
                          //   child: Text("test dddddddddddddddddddddddd"),
                          // ),
                          // IconButton(
                          //   iconSize: 37,
                          //   icon: Image.asset('assets/img/google.png'),
                          //   color: Colors.blue,
                          //   onPressed: () {
                          //     //  Image? image = await networkImageToBase64(baseUrl + 'images/default.png');
                          //     // var test = user;
                          //     //print(user.toString());

                          //     ShowMessageTools.displayRatingDialog(context);
                          //   },
                          // ),
                        ])))));
  }
}
