import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:control_app/model/doctorRecommendMassageSetting.dart';
import 'package:control_app/model/user.dart';
import 'package:control_app/request/ratingRequest.dart';
import 'package:control_app/utils/apiRequest.dart';
import 'package:control_app/utils/loader.dart';
import 'package:control_app/utils/showMessageTools.dart';
import 'package:control_app/db/massage_database.dart';
import 'package:control_app/model/massageSetting.dart';
import 'package:control_app/providers/massageSettingProvider.dart';
import 'package:control_app/providers/userProvider.dart';
import 'package:control_app/request/massageSettingRequest.dart';
import 'package:control_app/widgets/ControlFrontPage2.dart';
import 'package:control_app/widgets/contralFrontPage.dart';
import 'package:control_app/widgets/controlBackPage.dart';
import 'package:control_app/widgets/controlBackPage2.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:random_color/random_color.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:sweetsheet/sweetsheet.dart';
import 'package:collection/collection.dart';

class ControlConnectedDevicePage2 extends StatefulWidget {
  //final BluetoothDevice server;
  final BluetoothConnection bluetoothConnection;
  final BluetoothState bluetoothState;
  final bool isGetDoctorRecommend;
  final DoctorRecommendMassageSetting doctorRecommendMassageSetting;
  const ControlConnectedDevicePage2(
      {required this.isGetDoctorRecommend,
      required this.doctorRecommendMassageSetting,
      required this.bluetoothConnection,
      required this.bluetoothState,
      Key? key})
      : super(key: key);

  @override
  _ControlConnectedDevicePageState createState() =>
      _ControlConnectedDevicePageState();
}

class _ControlConnectedDevicePageState
    extends State<ControlConnectedDevicePage2> {
  //Button status
  bool isStart = false;
  bool isPause = false;

  //Bluetooth Connection
  //late BluetoothConnection connection;
  bool isConnecting = true;
  bool get isConnected => widget.bluetoothConnection.isConnected;
  bool dataReply = false;

  //first load
  bool _loaded = false;

  //Shortcut text
  static const String STOPPED = "ST";
  static const String PAUSED = "P";
  static const String RESUME = "R";
  static const String RUNNING = "R";
  static const String WAITING = "W";

  //Three Massage Duration
  List<int> timeDurationList = [0, 0, 0];

  //Current state of button
  String currentLoading = "";

  //MassageJson Configuration to be send
  String massageConfiguration = "";

  //Timer for animation
  Timer? _incrementCounterTimer;

  //Padding value for animation
  double activePaddingValue = 1;

  //Flip Card Value
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  //Process index for the time
  //int _processIndex = 0;

  //Process display text
  //List<dynamic> processDisplayText = [];

  //Show the current process while it running
  int currentStep = 0;

  //Show the time left
  String currentProcessTimeLeft = "";

  //Show the time left
  String totalProcessTimeLeft = "";

  //Duration for each strength level
  int durationMassage = 1;

  //Massage Strength level
  int strengthLevel = 10;

  //Max value for duration
  int maxDurationValue = 30;

  //random color object
  RandomColor _randomColor = RandomColor();

  //List of massage settings (default value)
  List<dynamic> processList = [];

  //process list without empty portion
  List<dynamic> processListWithoutEmptyPortion = [];

  //Time used for massage
  int usedTime = 0;

  //Delete confirmation
  final SweetSheet sweetSheet = SweetSheet();

//start the animation
  startProgressAnimation() {
    _incrementCounterTimer =
        Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (activePaddingValue == 1) {
        if (this.mounted)
          setState(() {
            activePaddingValue = 5;
          });
      } else {
        if (this.mounted)
          setState(() {
            activePaddingValue = 1;
          });
      }
    });
  }

  //stop progress animation
  stopProgressAnimation() {
    if (_incrementCounterTimer != null) {
      if (mounted) _incrementCounterTimer!.cancel();
    }
  }

  //initialize bluetooth connection
  initializeBluetoothListener() {
    setState(() {
      isConnecting = false;
    });

    widget.bluetoothConnection.input!.listen((Uint8List data) async {
      //Data entry point
      print("############################");
      print(ascii.decode(data));
      var jsonData = jsonDecode(ascii.decode(data));

      //if the process "p" not null will continue the process
      if (jsonData["p"] != null) {
        //flip only once when process in running
        if (cardKey.currentState!.isFront) {
          //clear the process time step

          int totalTime = 0;

          //get a list of process
          List<dynamic> processes = jsonData["p"];

          //remove all the process list
          processList.clear();

          //remove all records
          processListWithoutEmptyPortion.clear();

          //construct time text
          processes.asMap().forEach((index, value) {
            //random color
            Color randomPickColor = _randomColor.randomColor(
                colorBrightness: ColorBrightness.light);

            //Add the setting to local list
            processList.add({
              'duration': value["d"],
              'strengthLevel': (value["s"] - 80),
              'color': randomPickColor
            });

            //add the setting that wiothout empty portion
            if (value['s'] != 0) {
              processListWithoutEmptyPortion
                  .add({'d': value['d'], 's': (value['s'])});
              totalTime += int.parse(value['d'].toString());
            }

            //add time text for each step
            //processDisplayText.add({"strength": value["s"] - 80, "displayText": displayText});
          });

          //add empty portion for the array
          if (totalTime != 30) {
            processList.add({
              'duration': 30 - totalTime,
              'strengthLevel': 0,
              'color': Colors.grey[200]
            });
          }

          //update total time has been used
          setState(() {
            //update encode json  massage setting
            massageConfiguration = jsonEncode(processListWithoutEmptyPortion);
            usedTime = totalTime;
          });

          //start the animation
          startProgressAnimation();

          //hide the loader
          Loader.hide();
          cardKey.currentState!.toggleCard();
        }

        //add total time for all the massage
        int totalProcessTime = processListWithoutEmptyPortion.fold(
            0, (p, c) => int.parse(p.toString()) + (c["d"] * 60)) as int;

        //Get current massage in seconds
        int currentProcessTime = int.parse(jsonData["r"].toString());

        //get current step
        int currentStep = int.parse(jsonData["c"].toString());

        //minus current process time and add in current process time
        totalProcessTime = (totalProcessTime -
                (int.parse(jsonData["p"][currentStep]["d"].toString()) * 60)) +
            currentProcessTime;

        //update the current process
        setState(() {
          totalProcessTimeLeft = formatedTime(totalProcessTime);
          currentProcessTimeLeft = formatedTime(currentProcessTime);
          currentStep = currentStep;
        });
      }

      //flip the card when the process is ended
      if (jsonData["p"] == null && !cardKey.currentState!.isFront) {
        cardKey.currentState!.toggleCard();

        //display rating dialog for rate
        // Timer(Duration(seconds: 1), () => {ShowMessageTools.displayRatingDialog(context)});
        Timer(Duration(milliseconds: 500), () => {displayRatingDialog()});
      }

      //disable the loading
      if (currentLoading == jsonData["s"].toString()) {
        setState(() {
          currentLoading = "";
        });
        //hide loader when meet current state
        Loader.hide();
      }

      //compare device return status
      if (jsonData["s"].toString() == STOPPED) {
        print("stopped");

        setState(() {
          isStart = false;
          isPause = false;
        });
        if (!cardKey.currentState!.isFront) {
          stopProgressAnimation();
          cardKey.currentState!.toggleCard();

          //display rating dialog for rate
          Timer(Duration(milliseconds: 500), () => {displayRatingDialog()});
        }
      } else if (jsonData["s"].toString() == PAUSED) {
        print("paused");

        setState(() {
          isStart = true;
          isPause = true;
        });
      } else if (jsonData["s"].toString() == RUNNING) {
        print("running");
        setState(() {
          isStart = true;
          isPause = false;
        });
      } else if (jsonData["s"].toString() == WAITING) {
        // print("waiting");

        setState(() {
          isStart = false;
          isPause = false;
        });
      }

      if (!dataReply) {
        Loader.hide();
        print("data reply **********");
        setState(() {
          dataReply = true;
        });
      }
    });
  }

  updateTheCurrentLoadingState(String currentState) {
    //update current state
    setState(() => {currentLoading = currentState});
  }

  String formatedTime(int secTime) {
    String getParsedTime(String time) {
      if (time.length <= 1) return "0$time";
      return time;
    }

    int min = secTime ~/ 60;
    int sec = secTime % 60;

    String parsedTime =
        getParsedTime(min.toString()) + " : " + getParsedTime(sec.toString());

    return parsedTime;
  }

  //prepare message send to bluetooth device
  startMassageProcess() {
    //Show Loading
    showLoader(context);

    //update current state
    updateTheCurrentLoadingState(RUNNING);

    //send massage setting
    sendMassageProcessToDevice(massageConfiguration);
  }

  //send the massage setting to bluetooth device
  void sendMassageProcessToDevice(String text) async {
    text = text.trim();
    //textEditingController.clear();

    if (text.length > 0) {
      try {
        String textToSend = text + "\r\n";
        List<int> list = utf8.encode(textToSend);
        Uint8List bytes = Uint8List.fromList(list);
        widget.bluetoothConnection.output.add(bytes);
        await widget.bluetoothConnection.output.allSent;

        // setState(() {
        //   messages.add(_Message(clientID, text));
        // });

        // Future.delayed(Duration(milliseconds: 333)).then((_) {
        //   listScrollController.animateTo(
        //       listScrollController.position.maxScrollExtent,
        //       duration: Duration(milliseconds: 333),
        //       curve: Curves.easeOut);
        // });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }

  // get massage configuration from api
  getMassageSetting(context) async {
    try {
      //Get Token
      String? token = Provider.of<UserProvider>(context, listen: false)
          .getUserDetails
          .token
          .toString();

      //add Header token
      ApiRequest _apiRepositary = new ApiRequest("Bearer " + token);

      //Get user Id
      //  int? userId = Provider.of<UserProvider>(context, listen: false).getUserDetails.userId;

      String apiPath = "api/MassageSetting/getUserMassageSetting";

      //determine which massage Setting to get
      // if (widget.isGetDoctorRecommend) {
      //   apiPath = "api/MassageSetting/getDoctorRecommendMassageSetting;
      // } else {
      //   apiPath = "api/MassageSetting/getUserMassageSetting/?userId=";
      // }

      await _apiRepositary.httpGetRequest(apiPath, context).then(
        (response) async {
          if (response!.statusCode == 200) {
            dynamic decodedJson = json.decode(response.toString());

            if (decodedJson['data'] != null) {
              //Convert from json to massageSetting object
              MassageSetting massageSetting =
                  MassageSetting.fromJson(decodedJson['data']);

              // Update massage setting to provider
              Provider.of<MassageSettingProvider>(context, listen: false)
                  .setMassageSetting(massageSetting);

              //Update massageSetting to sqlite
              await MassageDatabase.instance.addMassageSetting(massageSetting);

              setLocalMassageDataAndUpdateProvider(massageSetting);
            } else {
              // setToDefaultValue();
              getDefaultMassageSetting(context);
            }
          } else {
            //setToDefaultValue();
            getDefaultMassageSetting(context);
            ShowMessageTools.displayToast('systemError'.tr());
          }
          Loader.hide();
        },
        onError: (exception) async {
          print("error " + exception.message.toString());
          await getMassageSettingFromLocal(exception);
          Loader.hide();
        },
      );
    } on Exception catch (e) {
      print(e.toString());
      Loader.hide();
      ShowMessageTools.displayToast('systemError'.tr());
    }
  }

  getDefaultMassageSetting(context) async {
    try {
      //Get Token
      String? token = Provider.of<UserProvider>(context, listen: false)
          .getUserDetails
          .token
          .toString();

      //add Header token
      ApiRequest _apiRepositary = new ApiRequest("Bearer " + token);

      String apiPath = "api/MassageSetting/getDefaultMassageSetting";

      await _apiRepositary.httpGetRequest(apiPath, context).then(
        (response) async {
          if (response!.statusCode == 200) {
            dynamic decodedJson = json.decode(response.toString());

            if (decodedJson['data'] != null) {
              //Convert from json to massageSetting object
              MassageSetting massageSetting =
                  MassageSetting.fromJson(decodedJson['data']);

              // Update massage setting to provider
              Provider.of<MassageSettingProvider>(context, listen: false)
                  .setMassageSetting(massageSetting);

              //Update massageSetting to sqlite
              await MassageDatabase.instance.addMassageSetting(massageSetting);

              setLocalMassageDataAndUpdateProvider(massageSetting);
            } else {
              ShowMessageTools.displayToast('systemError'.tr());
            }
          } else {
            ShowMessageTools.displayToast('systemError'.tr());
          }
          Loader.hide();
        },
        onError: (exception) async {
          print("error " + exception.message.toString());
          await getMassageSettingFromLocal(exception);
          Loader.hide();
        },
      );
    } on Exception catch (e) {
      print(e.toString());
      Loader.hide();
      ShowMessageTools.displayToast('systemError'.tr());
    }
  }

  //Set MassageSetting Parameter
  setLocalMassageDataAndUpdateProvider(MassageSetting massageSetting) {
    assignNewDataToProcessList(
        jsonDecode(massageSetting.massageConfiguration!));
  }

  //Try to get the massage setting from local storage
  getMassageSettingFromLocal(dynamic exception) async {
    //Get User Id
    String? userId =
        Provider.of<UserProvider>(context, listen: false).getUserDetails.userId;

    //Get Local Massage Setting
    MassageSetting retrieveMassageSetting =
        await MassageDatabase.instance.getMassageSetting(userId);

    if (retrieveMassageSetting.massageSettingId != 0) {
      setLocalMassageDataAndUpdateProvider(retrieveMassageSetting);
    } else {
      //Else use default setting
      setToDefaultValue();
    }

    Loader.hide();
  }

  setToDefaultValue() {
    List<dynamic> defaultProcessList = [
      {
        'd': 10,
        's': 100,
      },
      {
        'd': 5,
        's': 150,
      },
      {
        'd': 5,
        's': 120,
      },
    ];

    assignNewDataToProcessList(defaultProcessList);
  }

  //assign new valur to process list
  assignNewDataToProcessList(List<dynamic> massageProcessList) {
    int totalTime = 0;
    //clear process list
    processList.clear();
    processListWithoutEmptyPortion.clear();

    //construct time text
    massageProcessList.asMap().forEach((index, value) {
      //random color
      Color randomPickColor = _randomColor.randomColor(
          colorBrightness: ColorBrightness.veryLight,
          colorHue: ColorHue.blue,
          colorSaturation: ColorSaturation.highSaturation);

      if (value['s'] != 0) {
        //list use to show in ui
        processList.add({
          'duration': value['d'],
          'strengthLevel': (value['s'] - 80),
          'color': randomPickColor
        });

        //list use to send to bluetooth device
        processListWithoutEmptyPortion.add({'d': value['d'], 's': value['s']});

        totalTime += int.parse(value['d'].toString());
      }
    });

    //Add empty portion to array
    if (totalTime != 30) {
      processList.add({
        'duration': 30 - totalTime,
        'strengthLevel': 0,
        'color': Colors.grey[200]
      });
    }

    setState(() {
      massageConfiguration = jsonEncode(processListWithoutEmptyPortion);
      usedTime = totalTime;
    });
  }

  updateOrAddMassageSetting() async {
    try {
      //Get massage setting from provider
      MassageSetting massageSetting =
          Provider.of<MassageSettingProvider>(context, listen: false)
              .getMassageSetting;

      //Show loading
      showLoader(context);

      MassageSettingRequest massageSettingRequest = new MassageSettingRequest(
          massageSettingId: massageSetting.massageSettingId == null
              ? ''
              : massageSetting.massageSettingId,
          userId: Provider.of<UserProvider>(context, listen: false)
              .getUserDetails
              .userId,
          massageConfiguration: massageConfiguration,
          modifiedAt: massageSetting.modifiedAt);

      // Convert to json data
      var convertMassageSettingRequestToJson = massageSettingRequest.toJson();

      //Get Token
      String? token = Provider.of<UserProvider>(context, listen: false)
          .getUserDetails
          .token
          .toString();

      //add Header token
      ApiRequest _apiRepositary = new ApiRequest("Bearer " + token);
      await _apiRepositary
          .httpPostRequest("api/MassageSetting/addOrUpdateMassageSetting",
              convertMassageSettingRequestToJson, context)
          .then(
        (response) async {
          if (response!.statusCode == 200) {
            dynamic decodedJson = json.decode(response.toString());

            //Convert from json to massage setting object
            MassageSetting massageSetting =
                MassageSetting.fromJson(decodedJson['data']);

            //Update massage setting to sqlite
            await MassageDatabase.instance.updateMassageSetting(massageSetting);

            // Update massage setting to provider
            Provider.of<MassageSettingProvider>(context, listen: false)
                .setMassageSetting(massageSetting);

            ShowMessageTools.displayToast(
                decodedJson['jsonLanguageKey'].toString().tr());
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

  //delete confirmation dialog
  deleteConfirmationDialog(int index) {
    sweetSheet.show(
      isDismissible: true,
      context: context,
      title: Text("deleteConfirmationDialogTitle").tr(),
      description: Text("deleteConfirmationDialogText").tr(namedArgs: {
        'value1': processList[index]['duration'].toString(),
        'value2': processList[index]['strengthLevel'].toString()
      }),
      color: SweetSheetColor.DANGER,
      icon: Icons.delete,
      positive: SweetSheetAction(
        onPressed: () {
          performAddUpdateDeleteMassageSetting(index, false, true);
          Navigator.of(context).pop();
        },
        title: 'DELETE',
      ),
      negative: SweetSheetAction(
        onPressed: () {
          Navigator.of(context).pop();
        },
        title: 'CANCEL',
      ),
    );
  }

  //Initialize the bottom sheet value for edit
  initializeBottomSheetValueForOrAndEdit(int index, bool isUpdate) {
    //initialize the duration and strength value
    if (isUpdate) {
      //for update
      setState(() {
        durationMassage = processList[index]['duration'];
        strengthLevel = processList[index]['strengthLevel'];

        maxDurationValue = (30 - usedTime) == 0
            ? processList[index]['duration']
            : (processList[index]['duration'] + (30 - usedTime));
      });
    } else {
      //for new add
      setState(() {
        maxDurationValue = 30 - usedTime;
      });
    }

    showBottomSheetForAddOrUpdate(index, isUpdate);
  }

  //Show the bottom sheet to add massage time
  void showBottomSheetForAddOrUpdate(int index, bool isUpdate) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        context: context,
        builder: (context) {
          return Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(10),
                      topRight: const Radius.circular(10))),
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter stateSetter) {
                return Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Text('minutes',
                              style: Theme.of(context).textTheme.headline6)
                          .tr(),
                    ),
                    NumberPicker(
                      value: durationMassage,
                      minValue: 1,
                      maxValue: maxDurationValue,
                      step: 1,
                      itemHeight: 100,
                      axis: Axis.horizontal,
                      selectedTextStyle: TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 30),
                      onChanged: (value) {
                        stateSetter(() => durationMassage = value);
                      },
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
                          ),
                          border: Border.all(color: Colors.black26),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                spreadRadius: 2.0,
                                blurRadius: 5.0),
                          ]),
                    ),
                    Container(
                      margin: EdgeInsets.all(20),
                      child: Text('strength',
                              style: Theme.of(context).textTheme.headline6)
                          .tr(),
                    ),
                    NumberPicker(
                      value: strengthLevel,
                      minValue: 10,
                      maxValue: 100,
                      step: 10,
                      itemHeight: 100,
                      axis: Axis.horizontal,
                      selectedTextStyle: TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 30),
                      onChanged: (value) {
                        stateSetter(() => strengthLevel = value);
                      },
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
                          ),
                          border: Border.all(color: Colors.black26),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                spreadRadius: 2.0,
                                blurRadius: 5.0),
                          ]),
                    ),
                    Container(
                        padding: EdgeInsets.only(top: 10),
                        width: MediaQuery.of(context).size.width / 1.7,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 80,
                              child: ElevatedButton(
                                child: Text(
                                  "close",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ).tr(),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                  onPrimary: Colors.white,
                                  padding: EdgeInsets.all(12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: ElevatedButton(
                                child: Text(
                                  isUpdate ? "edit" : "save",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ).tr(),
                                onPressed: () {
                                  if (durationMassage == 0) {
                                    stateSetter(() => durationMassage = 1);
                                  } else if (strengthLevel == 0) {
                                    stateSetter(() => strengthLevel = 10);
                                  } else {
                                    performAddUpdateDeleteMassageSetting(
                                        index, isUpdate, false);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xF6698FFa),
                                  onPrimary: Colors.white,
                                  padding: EdgeInsets.all(12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                  ],
                );
              }));
        });
  }

  // example "[{\"s\":100},{\"s\":200},{\"s\":300}]"
  // example 2 [{\"d\":5,\"s\":100},{\"d\":2,\"s\":200},{\"d\":1,\"s\":300}]

  //Update the strength process
  performAddUpdateDeleteMassageSetting(
      int index, bool isUpdate, bool isDelete) {
    int totalTime = 0;

    //Remove unuse portion
    processList.removeWhere((item) => item['strengthLevel'] == 0);

    //remove all records
    processListWithoutEmptyPortion.clear();

    if (isUpdate) {
      //Update selected record
      processList[index]['duration'] = durationMassage;
      processList[index]['strengthLevel'] = strengthLevel;
    } else if (isDelete) {
      //remove specific item
      processList.removeAt(index);
    } else {
      //random color
      Color randomColor = _randomColor.randomColor(
          colorBrightness: ColorBrightness.veryLight,
          colorHue: ColorHue.blue,
          colorSaturation: ColorSaturation.highSaturation);

      //Add the setting to local list
      processList.add({
        'duration': durationMassage,
        'strengthLevel': strengthLevel,
        'color': randomColor
      });
    }

    // Construct json data send to bluetooth device
    processList.asMap().forEach((index, element) {
      if (element['strengthLevel'] != 0) {
        processListWithoutEmptyPortion.add(
            {'d': element['duration'], 's': (element['strengthLevel'] + 80)});
        totalTime += int.parse(element['duration'].toString());
      }
    });

    //Add empty portion to array
    if (totalTime != 30) {
      processList.add({
        'duration': 30 - totalTime,
        'strengthLevel': 0,
        'color': Colors.grey[200]
      });
    }

    //Convert list object to json
    setState(() {
      //update encode json  massage setting
      massageConfiguration = jsonEncode(processListWithoutEmptyPortion);
      //reset duration value
      durationMassage = 1;
      //reset strength value
      strengthLevel = 10;
      //reset the max value for duration
      maxDurationValue = isUpdate
          ? (30 - totalTime) == 0
              ? durationMassage
              : (durationMassage + (30 - totalTime))
          : (30 - totalTime);
      usedTime = totalTime;
    });

    if (!isDelete) {
      Navigator.pop(context);
    }
  }

  //show the dialog for rating
  displayRatingDialog() {
    showDialog<String>(
        context: context,
        barrierDismissible: false, // set to false if you want to force a rating

        builder: (BuildContext context) => RatingDialog(
              starSize: 30.0,
              // initialRating: 1.0,
              enableComment: false,
              // your app's name?
              title: Text(
                'massageRating',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xF6698FFa),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ).tr(),
              // encourage your user to leave a high rating?
              message: Text(
                'ratingDescription',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ).tr(),
              // your app's logo?
              image: Image.asset(
                'assets/img/logo.png',
                height: 80,
                width: 80,
              ),
              submitButtonText: 'Submit',
              commentHint: 'Set your custom comment hint',
              onCancelled: () => print('cancelled'),
              onSubmitted: (response) async {
                //Show loading
                showLoader(context);
                print(
                    'rating: ${response.rating}, comment: ${response.comment}');

                postRatingValue(response.rating);
              },
            ));
  }

  //save rating value
  postRatingValue(double rating) async {
    //Get massage setting from provider
    MassageSetting massageSetting =
        Provider.of<MassageSettingProvider>(context, listen: false)
            .getMassageSetting;

    RatingRequest ratingRequest = new RatingRequest(
      massageSettingId: massageSetting.massageSettingId,
      userId: Provider.of<UserProvider>(context, listen: false)
          .getUserDetails
          .userId,
      rating: rating,
      massageConfiguration: massageSetting.massageConfiguration,
    );

    // Convert to json data
    var convertRatingRequestToJson = ratingRequest.toJson();

    try {
      //Get Token
      String? token = Provider.of<UserProvider>(context, listen: false)
          .getUserDetails
          .token
          .toString();

      //add Header token
      ApiRequest _apiRepositary = new ApiRequest("Bearer " + token);
      await _apiRepositary
          .httpPostRequest(
              "api/Rating/ratingMassage", convertRatingRequestToJson, context)
          .then(
        (response) async {
          if (response!.statusCode == 200) {
            dynamic decodedJson = json.decode(response.toString());

            if (decodedJson['jsonLanguageKey'] != null &&
                decodedJson['jsonLanguageKey'] != "") {
              ShowMessageTools.displayDialog("dialogTitle".tr(),
                  decodedJson['jsonLanguageKey'].toString().tr(), context);
            } else {
              ShowMessageTools.displayDialog(
                  "dialogTitle".tr(), "systemError".tr(), context);
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
  void initState() {
    super.initState();

    // //Massage setting from api
    // new Future.delayed(Duration.zero).then((value) async {
    //   //get massage setting from api
      // getMassageSetting(context);

    //   //Initialize bluetooth listener
      initializeBluetoothListener();
    // });
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      //Massage setting from api
      if (widget.isGetDoctorRecommend) {
        assignNewDataToProcessList(json.decode(
            widget.doctorRecommendMassageSetting.massageConfiguration!));
        Loader.hide();
      } else {
        getMassageSetting(context);
      }

      //Initialize bluetooth listener
      initializeBluetoothListener();
      setState(() {
        _loaded = true;
      });
    }
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected && widget.bluetoothConnection.isConnected) {
      print("clear connection");
      widget.bluetoothConnection.dispose();
      // connection = null;
    }
    stopProgressAnimation();
    Loader.hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.locale;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(45.0),
          child: new AppBar(
            title: Text("deviceRemote").tr(),
            backgroundColor: Color(0xF6698FFa),
            actions: <Widget>[],
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_left,
                size: 30,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
          ),
        ),
        body: SingleChildScrollView(
            child: SafeArea(
          child: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                children: <Widget>[
                  FlipCard(
                    key: cardKey,
                    direction: FlipDirection.VERTICAL,
                    flipOnTouch: false,
                    front: ControlFrontPage2(
                        processList: processList,
                        usedTime: usedTime,
                        startMassageProcess: startMassageProcess,
                        deleteConfirmationDialog: deleteConfirmationDialog,
                        initializeBottomSheetValueForOrAndEdit:
                            initializeBottomSheetValueForOrAndEdit,
                        performAddUpdateDeleteMassageSetting:
                            performAddUpdateDeleteMassageSetting),
                    back: processListWithoutEmptyPortion.length == 0
                        ? Text("")
                        : ControlBackPage2(
                            activePaddingValue: activePaddingValue,
                            processList: processListWithoutEmptyPortion,
                            currentStep: currentStep,
                            totalProcessTimeLeft: totalProcessTimeLeft,
                            currentProcessTimeLeft: currentProcessTimeLeft,
                            sendMassageProcessToDevice:
                                sendMassageProcessToDevice,
                            updateTheCurrentLoadingState:
                                updateTheCurrentLoadingState,
                            isPause: isPause),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  widget.isGetDoctorRecommend
                      ? SizedBox(
                          height: 20,
                        )
                      : isStart
                          ? SizedBox(
                              height: 20,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                  Container(
                                    alignment: Alignment.center,
                                    padding:
                                        EdgeInsets.only(left: 30, right: 30),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "note",
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold),
                                        ).tr(),
                                        Flexible(
                                          child: Text(
                                            "hintToSaveMassageSetting",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          ).tr(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80.0,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: Color(0xF6698FFa),
                                        onPrimary: Colors.white,
                                        padding: EdgeInsets.all(12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      onPressed: () async {
                                        updateOrAddMassageSetting();
                                      },
                                      child: Text('save'.tr()),
                                    ),
                                  ),
                                ]),
                ],
              ),
            ),
          ),
        )));
  }
}
