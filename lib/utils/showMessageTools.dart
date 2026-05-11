import 'dart:convert';

import 'package:control_app/db/massage_database.dart';
import 'package:control_app/model/massageSetting.dart';
import 'package:control_app/providers/massageSettingProvider.dart';
import 'package:control_app/providers/userProvider.dart';
import 'package:control_app/request/ratingRequest.dart';
import 'package:control_app/utils/apiRequest.dart';
import 'package:control_app/utils/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:rating_dialog/rating_dialog.dart';

class ShowMessageTools {
  static void displayToast(String message) {
    Fluttertoast.showToast(
        msg: message, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Color(0xF6698FFa), textColor: Colors.white, fontSize: 17.0);
  }

  static displayDialog(String title, String message, BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
        actions: <Widget>[
          // TextButton(
          //   onPressed: () => Navigator.pop(context, 'Cancel'),
          //   child: const Text('Cancel'),
          // ),
          // TextButton(
          //   onPressed: () => Navigator.pop(context, 'CLOSE'),
          //   child: const Text('close').tr(),
          // ),

          ElevatedButton(
            child: Text(
              'close',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ).tr(),
            onPressed: () {
              Navigator.pop(context, 'CLOSE');
            },
            style: ElevatedButton.styleFrom(
              primary: Color(0xF6698FFa),
              onPrimary: Colors.white,
              padding: EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  static Future showSnackBar(
    String message,
    Function updateSnackbarToFalse,
    bool _isSnackbarActive,
    BuildContext context, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    if (!_isSnackbarActive) {
      _isSnackbarActive = true;
      await new Future.delayed(new Duration(milliseconds: 100));
      ScaffoldMessenger.of(context)
          .showSnackBar(
            new SnackBar(
              content: new Text(
                message,
              ),
              duration: duration,
            ),
          )
          .closed
          .then((SnackBarClosedReason reason) {
        updateSnackbarToFalse();
      });
    }
  }

  static displayRatingDialog(BuildContext context) {
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
                print('rating: ${response.rating}, comment: ${response.comment}');

                //Get massage setting from provider
                MassageSetting massageSetting = Provider.of<MassageSettingProvider>(context, listen: false).getMassageSetting;

                RatingRequest ratingRequest = new RatingRequest(
                  massageSettingId: massageSetting.massageSettingId,
                  userId: Provider.of<UserProvider>(context, listen: false).getUserDetails.userId,
                  rating: response.rating,
                  massageConfiguration: massageSetting.massageConfiguration,
                );

                // Convert to json data
                var convertRatingRequestToJson = ratingRequest.toJson();

                try {
                  //Get Token
                  String? token = Provider.of<UserProvider>(context, listen: false).getUserDetails.token.toString();

                  //add Header token
                  ApiRequest _apiRepositary = new ApiRequest("Bearer " + token);
                  await _apiRepositary.httpPostRequest("api/Rating/ratingMassage", convertRatingRequestToJson, context).then(
                    (response) async {
                      if (response!.statusCode == 200) {
                        dynamic decodedJson = json.decode(response.toString());

                        if (decodedJson['jsonLanguageKey'] != null && decodedJson['jsonLanguageKey'] != "") {
                          ShowMessageTools.displayDialog("dialogTitle".tr(), decodedJson['jsonLanguageKey'].toString().tr(), context);
                        } else {
                          ShowMessageTools.displayDialog("dialogTitle".tr(), "systemError".tr(), context);
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
              },
            ));
  }
}
