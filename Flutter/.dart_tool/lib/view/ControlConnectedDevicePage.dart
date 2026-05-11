import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:control_app/utils/apiRequest.dart';
import 'package:control_app/utils/loader.dart';
import 'package:control_app/utils/showMessageTools.dart';
import 'package:control_app/db/massage_database.dart';
import 'package:control_app/model/massageSetting.dart';
import 'package:control_app/providers/massageSettingProvider.dart';
import 'package:control_app/providers/userProvider.dart';
import 'package:control_app/request/massageSettingRequest.dart';
import 'package:control_app/widgets/contralFrontPage.dart';
import 'package:control_app/widgets/controlBackPage.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

class ControlConnectedDevicePage extends StatefulWidget {
  //final BluetoothDevice server;
  final BluetoothConnection bluetoothConnection;

  const ControlConnectedDevicePage(
      {required this.bluetoothConnection, Key? key})
      : super(key: key);

  @override
  _ControlConnectedDevicePageState createState() =>
      _ControlConnectedDevicePageState();
}

class _ControlConnectedDevicePageState
    extends State<ControlConnectedDevicePage> {
  //Button status
  bool isStart = false;
  bool isPause = false;

  //Bluetooth Connection
  //late BluetoothConnection connection;
  bool isConnecting = true;
  bool get isConnected =>
      widget.bluetoothConnection != null &&
      widget.bluetoothConnection.isConnected;
  bool dataReply = false;

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

  //Massage Configuration
  String massageConfiguration = "";

  //Timer for animation
  Timer? _incrementCounterTimer;

  //Padding value for animation
  double activePaddingValue = 1;

  //Flip Card Value
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  //Process index for the time
  int _processIndex = 0;

  //Process display text
  List<dynamic> processDisplayText = [];

  //Show the current process while it running
  int currentStep = 0;

  //Show the time left
  String currentProcessTimeLeft = "";

  //Update the strength process
  updateStrengthValue(value) {
    //Avoid set current value
    if ((_processIndex == 0 || _processIndex == 1) &&
        value == 0 &&
        timeDurationList[_processIndex + 1] != 0) {
      setState(() {
        timeDurationList[_processIndex] = 10;
      });
    } else {
      //update duration list value
      setState(() {
        // _currentHorizontalIntValue = value,
        timeDurationList[_processIndex] = value;
      });
    }

    // Construct json data send to bluetooth device
    List<dynamic> processList = [];
    timeDurationList.asMap().forEach((index, element) {
      if (element != 0) {
        processList.add({'s': (element + 80)});
        //  example "[{\"s\":100},{\"s\":200},{\"s\":300}]"
      }
    });

    //Set the massage configuration
    setState(() {
      massageConfiguration = jsonEncode(processList);
    });
  }

  stepIndicatorOnChange(bool isBack) {
    if (isBack) {
      if (_processIndex != 0) {
        setState(() {
          _processIndex = (_processIndex - 1);
        });
      }
    } else {
      if (_processIndex != 2) {
        setState(() {
          _processIndex = (_processIndex + 1);
        });
      }
    }
  }

//start the animation
  startProgressAnimation() {
    _incrementCounterTimer =
        Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (activePaddingValue == 1) {
        if (mounted)
          setState(() {
            activePaddingValue = 5;
          });
      } else {
        if (mounted)
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
          processDisplayText.clear();

          //get current step
          int currentStep = int.parse(jsonData["c"].toString());

          //get a list of process
          List<dynamic> processes = jsonData["p"];

          //construct time text
          processes.asMap().forEach((index, value) {
            String displayText = "";
            if (index == 0) {
              displayText = "1 - 10";
            } else if (index == 1) {
              displayText = "10 - 20";
            } else if (index == 2) {
              displayText = "20 - 30";
            }

            //add duration for each step
            timeDurationList[index] = value["s"] - 80;

            //add time text for each step
            processDisplayText
                .add({"strength": value["s"] - 80, "displayText": displayText});
          });

          startProgressAnimation();
          cardKey.currentState!.toggleCard();
        }

        //Get current process in seconds
        int seconds = int.parse(jsonData["r"].toString());

        //update the current process
        setState(() {
          currentProcessTimeLeft = formatedTime(seconds);
          currentStep = int.parse(jsonData["c"].toString());
        });
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
        print("waiting");

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

  void sendProcessToDevice(String text) async {
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
    //Show loading
    showLoader(context);

    try {
      //Get Token
      String? token = Provider.of<UserProvider>(context, listen: false)
          .getUserDetails
          .token
          .toString();

      //add Header token
      ApiRequest _apiRepositary = new ApiRequest("Bearer " + token);

      //Get user Id
      String? userId = Provider.of<UserProvider>(context, listen: false)
          .getUserDetails
          .userId;

      await _apiRepositary
          .httpGetRequest(
              "api/MassageSetting/getUserMassageSetting/?userId=" +
                  userId.toString(),
              context)
          .then(
        (response) async {
          if (response!.statusCode == 200) {
            dynamic decodedJson = json.decode(response.toString());

            if (decodedJson['data'] != null) {
              //Convert from json to massageSetting object
              MassageSetting massageSetting =
                  MassageSetting.fromJson(decodedJson['data']);

              //Update massageSetting to sqlite
              await MassageDatabase.instance.addMassageSetting(massageSetting);

              setLocalMassageDataAndUpdateProvider(massageSetting);
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
      setState(() {
        massageConfiguration = "[{\"s\":100},{\"s\":200},{\"s\":300}]";
      });
    }
  }

  //Set MassageSetting Parameter
  setLocalMassageDataAndUpdateProvider(MassageSetting massageSetting) {
    // Update user to provider
    Provider.of<MassageSettingProvider>(context, listen: false)
        .setMassageSetting(massageSetting);

    //set local massage configuration string
    setState(() {
      massageConfiguration = massageSetting.massageConfiguration!;
    });

    //construct time text
    jsonDecode(massageConfiguration).asMap().forEach((index, value) {
      setState(() {
        timeDurationList[index] = (value["s"] - 80);
      });
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

  @override
  void initState() {
    super.initState();

    //Massage setting from api
    new Future.delayed(Duration.zero).then((value) async {
      await getMassageSetting(context);

      //Initialize bluetooth listener
      initializeBluetoothListener();
    });
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
                    front: ControlFrontPage(
                        processIndex: _processIndex,
                        timeDurationList: timeDurationList,
                        updateStrengthValue: updateStrengthValue,
                        stepIndicatorOnChange: stepIndicatorOnChange),
                    back: processDisplayText.length == 0
                        ? Text("")
                        : ControlBackPage(
                            activePaddingValue: activePaddingValue,
                            processStep: processDisplayText,
                            currentStep: currentStep,
                            currentProcessTimeLeft: currentProcessTimeLeft,
                            isPause: isPause),
                  ),
                  // RaisedButton(
                  //   onPressed: () => cardKey.currentState!.toggleCard(),
                  //   child: Text('turn'),
                  // ),

                  // RaisedButton(
                  //   onPressed: () {
                  //     _incrementCounterTimer.cancel();
                  //     setState(() {
                  //       paddingValue = 5;
                  //     });
                  //   },
                  //   child: Text('test Buton'),
                  // ),
                  // RaisedButton(
                  //   onPressed: () {
                  //     _incrementCounter();
                  //   },
                  //   child: Text('test Buton'),
                  // ),
                  SizedBox(
                    height: 10,
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 90.0,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: isStart == false
                                ? Color(0xF6698FFa)
                                : Colors.red,
                            onPrimary: Colors.white,
                            onSurface: Colors.grey,
                          ),
                          onPressed: isConnecting ||
                                  !dataReply ||
                                  timeDurationList[0] == 0
                              ? null
                              : () {
                                  //Show Loading
                                  showLoader(context);
                                  String postData = "";

                                  //Check current condition
                                  if (isStart) {
                                    //Stop the process
                                    postData = jsonEncode({"s": "S"});
                                  } else {
                                    //Start a new massage process
                                    // List<dynamic> processList = [];
                                    // timeDurationList.asMap().forEach((index, element) {
                                    //   if (element != 0) {
                                    //     processList.add({"s": (element + 80)});
                                    //     //  example "[{\"s\":100},{\"s\":200},{\"s\":300}]"
                                    //   }
                                    // });
                                    postData = massageConfiguration;
                                  }

                                  //send massage process
                                  sendProcessToDevice(postData);

                                  //update current state
                                  setState(() => {
                                        currentLoading =
                                            isStart ? STOPPED : RUNNING
                                      });

                                  Fluttertoast.showToast(
                                      msg: "Message Sent",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Color(0xF6698FFa),
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                },
                          child: Text(isStart ? 'stop'.tr() : 'start'.tr()),
                        ),
                      ),
                      SizedBox(
                        width: 90.0,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: isPause
                                ? Colors.green[500]
                                : Colors.yellow[400],
                            onPrimary: isPause ? Colors.white : Colors.black,
                            onSurface: Colors.grey,
                          ),
                          onPressed: isStart && dataReply
                              ? () {
                                  //show loading
                                  showLoader(context);
                                  String json = isPause
                                      ? jsonEncode({"s": "R"})
                                      : jsonEncode({"s": "P"});

                                  //send massage process
                                  sendProcessToDevice(json);

                                  //update current state
                                  setState(() => {
                                        currentLoading =
                                            isPause ? RESUME : PAUSED
                                      });
                                }
                              : null,
                          child: Text(isPause ? 'resume'.tr() : 'pause'.tr()),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
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
                      margin: EdgeInsets.only(
                          top: 20, left: 10, right: 10, bottom: 20),
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "First 10 Minutes : ",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Flexible(
                                      child: Text(
                                        timeDurationList[0] == 0
                                            ? "-"
                                            : "With strength level of " +
                                                timeDurationList[0].toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Next 10 Minutes : ",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Flexible(
                                      child: Text(
                                        timeDurationList[1] == 0
                                            ? "-"
                                            : "With strength level of " +
                                                timeDurationList[1].toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Last 10 Minutes : ",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Flexible(
                                      child: Text(
                                        timeDurationList[2] == 0
                                            ? "-"
                                            : "With strength level of " +
                                                timeDurationList[2].toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ))),
                  SizedBox(
                    width: 90.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.lightBlue,
                        onPrimary: Colors.white,
                        onSurface: Colors.grey,
                      ),
                      onPressed: () async {
                        if (massageConfiguration != "") {
                          await updateOrAddMassageSetting();
                        } else {
                          Fluttertoast.showToast(
                              msg: "massageSettingEmpty".tr(),
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Color(0xF6698FFa),
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      },
                      child: Text('save'.tr()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )));
  }
}
