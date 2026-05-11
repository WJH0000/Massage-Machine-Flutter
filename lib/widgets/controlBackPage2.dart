import 'dart:convert';

import 'package:control_app/const/constant.dart';
import 'package:control_app/utils/loader.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:im_stepper/stepper.dart';

class ControlBackPage2 extends StatelessWidget {
  final double activePaddingValue;
  final int currentStep;
  final List<dynamic> processList;
  final String totalProcessTimeLeft;
  final String currentProcessTimeLeft;
  final Function sendMassageProcessToDevice;
  final Function updateTheCurrentLoadingState;
  final bool isPause;

  ControlBackPage2(
      {required this.activePaddingValue,
      required this.currentStep,
      required this.processList,
      required this.totalProcessTimeLeft,
      required this.currentProcessTimeLeft,
      required this.sendMassageProcessToDevice,
      required this.updateTheCurrentLoadingState,
      required this.isPause});

  @override
  Widget build(BuildContext context) {
    context.locale;

    return Container(
        width: MediaQuery.of(context).size.width - 18,
        // padding: EdgeInsets.all(10),
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
        margin: EdgeInsets.only(top: 20, bottom: 20),
        child: Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Color(0xF6698FFa),
                    borderRadius: BorderRadius.only(topRight: Radius.circular(10.0), topLeft: Radius.circular(10.0)),
                  ),
                  child: Text(
                    totalProcessTimeLeft,
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "currentProcess",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ).tr(),
                SizedBox(
                  height: 5,
                ),
                Column(
                  children: [
                    Container(
                      height: 85,
                      width: MediaQuery.of(context).size.width - 120,
                      child: AnimatedPadding(
                        padding: EdgeInsets.all(activePaddingValue),
                        duration: Duration(milliseconds: 1000),
                        curve: Curves.easeInOut,
                        child: Container(
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text(
                                'minutesWithValue'.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ).tr(namedArgs: {'value': currentProcessTimeLeft.toString()}),
                              Image.asset(
                                'assets/img/progress.gif',
                                fit: BoxFit.fitWidth,
                                width: 500,
                                height: 30,
                              ),
                              // Flexible(
                              //     child: isPause
                              //         ? Text("paused",
                              //             style: TextStyle(
                              //               fontSize: 25,
                              //               color: Colors.red,
                              //               fontWeight: FontWeight.bold,
                              //             )).tr()
                              //         : Image.asset(
                              //             'assets/img/progress.gif',
                              //             fit: BoxFit.fitWidth,
                              //             width: 500,
                              //             height: 30,
                              //           ))
                            ]),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              border: Border.all(color: Colors.red, width: 3),
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                            )),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  alignment: Alignment.center,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "currenteStrengthLevel",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ).tr(),
                      Flexible(
                        child: Text(
                          processList.length != 0 ? (processList[currentStep]["s"] - 80).toString() : "",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
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
                  alignment: Alignment.center,
                  child: processList.length == (currentStep + 1)
                      ? null
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "nextExecutionStrengthLevel",
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ).tr(),
                            Text(
                              (processList[currentStep + 1]["s"] - 80).toString(),
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                ),
                SizedBox(
                  height: 20,
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 90.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          onPrimary: Colors.white,
                          onSurface: Colors.grey,
                        ),
                        onPressed: () {
                          //Show Loading
                          showLoader(context);

                          String postData = "";

                          //Stop the process
                          postData = jsonEncode({"s": "S"});

                          //update the current state
                          updateTheCurrentLoadingState(STOPPED);

                          //send command to stop the massage
                          sendMassageProcessToDevice(postData);
                        },
                        child: Text('stop').tr(),
                      ),
                    ),
                    SizedBox(
                      width: 90.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: isPause ? Colors.green[500] : Colors.yellow[400],
                          onPrimary: isPause ? Colors.white : Colors.black,
                          onSurface: Colors.grey,
                        ),
                        onPressed: () {
                          //show loading
                          showLoader(context);

                          String postData = isPause ? jsonEncode({"s": "R"}) : jsonEncode({"s": "P"});

                          //update the current state
                          updateTheCurrentLoadingState(isPause ? RESUME : PAUSED);

                          //send command to paused or resume
                          sendMassageProcessToDevice(postData);
                        },
                        child: Text(isPause ? 'resume'.tr() : 'pause'.tr()),
                      ),
                    ),
                  ],
                ),
              ],
            )));
  }
}
