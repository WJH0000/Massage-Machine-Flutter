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
import 'package:im_stepper/stepper.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ControlConnectedDevicePage3 extends StatefulWidget {
  const ControlConnectedDevicePage3({Key? key}) : super(key: key);

  @override
  _ControlConnectedDevicePageState createState() => _ControlConnectedDevicePageState();
}

class _ControlConnectedDevicePageState extends State<ControlConnectedDevicePage3> {
  // THE FOLLOWING TWO VARIABLES ARE REQUIRED TO CONTROL THE STEPPER.
  int activeStep = 5; // Initial step set to 5.

  int upperBound = 6; // upperBound MUST BE total number of icons minus 1.

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            IconStepper(
              enableStepTapping: false,
              // activeStepBorderColor: Colors.red,
              // activeStepColor: Colors.red,
              // stepReachedAnimationEffect: Curves.easeInOutQuint,
              // stepReachedAnimationDuration: Duration(seconds: 1),
              icons: [
                Icon(
                  Icons.supervised_user_circle,
                  semanticLabel: "sasa",
                ),
                Icon(Icons.flag),
                Icon(Icons.access_alarm),
                Icon(Icons.supervised_user_circle),
                Icon(Icons.flag),
                Icon(Icons.access_alarm),
                Icon(Icons.supervised_user_circle),
              ],

              // activeStep property set to activeStep variable defined above.
              activeStep: activeStep,

              // This ensures step-tapping updates the activeStep.
              onStepReached: (index) {
                setState(() {
                  activeStep = index;
                });
              },
            ),
            header(),
            Expanded(
              child: FittedBox(
                child: Center(
                  child: Text('$activeStep'),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                previousButton(),
                nextButton(),
              ],
            ),
          ],
        ),
      ),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  /// Returns the next button.
  Widget nextButton() {
    return ElevatedButton(
      onPressed: () {
        // Increment activeStep, when the next button is tapped. However, check for upper bound.
        if (activeStep < upperBound) {
          setState(() {
            activeStep++;
          });
        }
      },
      child: Text('Next'),
    );
  }

  /// Returns the previous button.
  Widget previousButton() {
    return ElevatedButton(
      onPressed: () {
        // Decrement activeStep, when the previous button is tapped. However, check for lower bound i.e., must be greater than 0.
        if (activeStep > 0) {
          setState(() {
            activeStep--;
          });
        }
      },
      child: Text('Prev'),
    );
  }

  /// Returns the header wrapping the header text.
  Widget header() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              headerText(),
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Returns the header text based on the activeStep.
  String headerText() {
    switch (activeStep) {
      case 1:
        return 'Preface';

      case 2:
        return 'Table of Contents';

      case 3:
        return 'About the Author';

      case 4:
        return 'Publisher Information';

      case 5:
        return 'Reviews';

      case 6:
        return 'Chapters #1';

      default:
        return 'Introduction';
    }
  }
}
