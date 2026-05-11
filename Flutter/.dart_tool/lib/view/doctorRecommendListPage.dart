import 'dart:convert';

import 'package:control_app/db/massage_database.dart';
import 'package:control_app/model/doctorRecommendMassageSetting.dart';
import 'package:control_app/model/massageSetting.dart';
import 'package:control_app/providers/massageSettingProvider.dart';
import 'package:control_app/providers/userProvider.dart';
import 'package:control_app/utils/apiRequest.dart';
import 'package:control_app/utils/loader.dart';
import 'package:control_app/utils/showMessageTools.dart';
import 'package:control_app/view/ControlPageDesign2.dart';
import 'package:control_app/view/bluetoothList.dart';
import 'package:control_app/view/homePage.dart';
import 'package:control_app/widgets/bluetoothOffScreen.dart';
import 'package:control_app/widgets/massageSettingItem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:easy_localization/easy_localization.dart';
import 'device.dart';

class DoctorRecommendListPage extends StatefulWidget {
  @override
  DoctorRecommendListPage({Key? key}) : super(key: key);
  _DoctorRecommendListPageState createState() =>
      _DoctorRecommendListPageState();
}

class _DoctorRecommendListPageState extends State<DoctorRecommendListPage> {
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  // Get the instance of the bluetooth
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;

  //List of paired devices
  List<BluetoothDevice> devices = [];

  //status to prevent snackbar show repeat
  bool _isSnackbarActive = false;

  //refresh controller
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<DoctorRecommendMassageSetting> doctorRecommendMassageSetting = [];

  //first load
  bool _loaded = false;

  //load all paired bluetooth device
  Future<void> loadPairedDevices() async {
    // To get the list of paired devices
    try {
      List<BluetoothDevice> retrievedDevices =
          await bluetooth.getBondedDevices();
      setState(() {
        devices = retrievedDevices;
      });
    } on PlatformException {
      print("Error");
    }
  }

  //pass selected doctor recommend setting
  passDoctorRecommendSetting(DoctorRecommendMassageSetting doctorRecommendMassageSetting) async {
    String? userId =
        Provider.of<UserProvider>(context, listen: false).getUserDetails.userId;

    MassageSetting massageSetting = new MassageSetting(
        massageSettingId: doctorRecommendMassageSetting.massageSettingId,
        massageConfiguration:
            doctorRecommendMassageSetting.massageConfiguration,
        userId: userId);

    // Update massage setting to provider
    Provider.of<MassageSettingProvider>(context, listen: false)
        .setMassageSetting(massageSetting);

    //Update massageSetting to sqlite
    await MassageDatabase.instance.addMassageSetting(massageSetting);
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.topToBottom,
            child: BluetoothListPage(
              isGetDoctorRecommend: true,
              doctorRecommendMassageSetting: doctorRecommendMassageSetting,
            )));
  }

  //get current bluetooth state and check whether it on
  getCurrentBluetoothState() async {
    // get current state
    await FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });

      if (state == BluetoothState.STATE_ON) {
        loadPairedDevices();
      }

      if (state != BluetoothState.STATE_ON) {
        //Prompt User open bluetooth when it off
        FlutterBluetoothSerial.instance.requestEnable();
      }
    });
  }

  //Update snacbar to false when
  updateSnackbarToFalse() {
    setState(() {
      _isSnackbarActive = false;
    });
  }

  //refresh bluetooth device list
  void _onRefresh() async {
    // monitor network fetch
    // await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()

    await getMassageSettingList(context).then((_) {
      _refreshController.refreshCompleted();
      ShowMessageTools.showSnackBar('deviceListRefreshed'.tr(),
          updateSnackbarToFalse, _isSnackbarActive, context);
    });
  }

  // get massage configuration from api
  getMassageSettingList(context) async {
    try {
      showLoader(context);
      //Get Token 
      
      String? token = Provider.of<UserProvider>(context, listen: false)
          .getUserDetails
          .token
          .toString();

      //add Header token
      ApiRequest _apiRepositary = new ApiRequest("Bearer " + token);

      //Get user Id
      //int? userId = Provider.of<UserProvider>(context, listen: false).getUserDetails.userId;

      String apiPath =
          "api/MassageSetting/getDoctorRecommendMassageSettingList";

      await _apiRepositary.httpGetRequest(apiPath, context).then(
        (response) async {
          if (response!.statusCode == 200) {
            doctorRecommendMassageSetting = [];
            dynamic decodedJson = json.decode(response.toString());

            if (decodedJson['data'] != null) {
              print("test   " + decodedJson['data'].toString());
              decodedJson['data'].forEach((element) {
                setState(() {
                  doctorRecommendMassageSetting
                      .add(DoctorRecommendMassageSetting.fromJson(element));
                });
              });

              print("test " + doctorRecommendMassageSetting.length.toString());
              // jsonDecode(massageSetting.massageConfiguration!).forEach((element) {
              //   print("data " + element.toString());
              // });
              //Convert from json to massageSetting object
              //MassageSetting massageSetting = MassageSetting.fromJson(decodedJson['data']);

              // Update massage setting to provider
              //  Provider.of<MassageSettingProvider>(context, listen: false).setMassageSetting(massageSetting);

              //Update massageSetting to sqlite
              //  await MassageDatabase.instance.addMassageSetting(massageSetting);
            }
          } else {
            ShowMessageTools.displayToast('systemError'.tr());
          }
          Loader.hide();
        },
        onError: (exception) async {
          print("error " + exception.message.toString());
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
  didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      //Massage setting list from api
      getMassageSettingList(context);
      setState(() {
        _loaded = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // getCurrentBluetoothState();

    // FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) async {
    //   if (state == BluetoothState.STATE_ON) {
    //     List<BluetoothDevice> retrieveDevices = await bluetooth.getBondedDevices();

    //     if (this.mounted) {
    //       setState(() {
    //         devices = retrieveDevices;
    //       });
    //     }
    //   }
    //   if (this.mounted) {
    //     //check if the bluetooth turn off and in other page make it return to this page
    //     if (state != BluetoothState.STATE_ON && !ModalRoute.of(context)!.isCurrent) {
    //       Navigator.pop(context);
    //     }
    //     setState(() {
    //       _bluetoothState = state;
    //     });
    //   }
    // });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _bluetoothState = BluetoothState.UNKNOWN;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.locale;
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(45.0),
          child: new AppBar(
            title: Text('recommendList').tr(),
            backgroundColor: Color(0xF6698FFa),
            actions: <Widget>[
              FlatButton.icon(
                highlightColor: Color(0xFFa5c1fa),
                focusColor: Color(0xFFa5c1fa),
                hoverColor: Color(0xFFa5c1fa),
                disabledColor: Color(0xFFa5c1fa),
                icon: Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                label: Text(
                  "refresh",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ).tr(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                splashColor: Colors.deepPurple,
                onPressed: () async {
                  await getMassageSettingList(context);
                },
              ),
            ],
            leading: IconButton(
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
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: false,
                    header: WaterDropMaterialHeader(
                      backgroundColor: Color(0xF6698FFa),
                    ),
                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    //onLoading: _onLoading,
                    child: ListView.builder(
                        itemCount: doctorRecommendMassageSetting.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: <Widget>[
                              MassageSettingItem(
                                  title: doctorRecommendMassageSetting[index]
                                      .description!,
                                  description:
                                      doctorRecommendMassageSetting[index]
                                          .description!,
                                  count: index + 1,
                                  onTap: () {
                                    passDoctorRecommendSetting(
                                        doctorRecommendMassageSetting[index]);
                                  }),
                              Divider(), //                           <-- Divider
                            ],
                          );
                        }),
                  ),
                ),
              ),
              Container(
                  width: MediaQuery.of(context).size.width - 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  margin:
                      EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 20),
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "note",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ).tr(),
                                Flexible(
                                  child: Text(
                                    "doctorRecommendNote",
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
            ],
          ),
        ));
  }
}
