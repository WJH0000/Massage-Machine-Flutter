import 'dart:convert';
import 'package:control_app/providers/userProvider.dart';
import 'package:control_app/utils/clearUserData.dart';
import 'package:control_app/utils/showMessageTools.dart';
import 'package:control_app/const/constant.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

class ApiRequest {
  Dio? dio;

  ApiRequest(String token) {
    if (dio == null) {
      //Assign Header value
      Map<String, dynamic> headers = new Map<String, dynamic>();
      headers["Authorization"] = token;
      BaseOptions options = new BaseOptions(
          baseUrl: baseUrl,
          headers: headers,
          receiveDataWhenStatusError: true,
          connectTimeout: 60 * 2000, // 60 seconds
          receiveTimeout: 60 * 2000 // 60 seconds
          );

      dio = new Dio(options);
    }
  }

  //Post Request
  Future<Response?> httpPostRequest(String path, dynamic jsonRequestData, BuildContext context) async {
    try {
      Response response = await dio!.post(path, data: jsonRequestData);
      return response;
    } on DioError catch (ex) {
      if (ex.type == DioErrorType.connectTimeout) {
        ShowMessageTools.displayToast("connectionTimeout".tr());
      } else if (ex.type == DioErrorType.other) {
        ShowMessageTools.displayToast("connectionTimeout".tr());
      } else if (ex.response!.data != null) {
        if (ex.response!.statusCode == 401) {
          ShowMessageTools.displayToast('sessionExpired'.tr());

          final user = Provider.of<UserProvider>(context, listen: false).getUserDetails;

          await ClearUserData.clearUserDataAndNavigateToLoginPage(user, context);
        } else {
          dynamic decodedJson = json.decode(ex.response.toString());
          if (decodedJson['jsonLanguageKey'] != null && decodedJson['jsonLanguageKey'] != "") {
            ShowMessageTools.displayDialog("dialogTitle".tr(), decodedJson['jsonLanguageKey'].toString().tr(), context);
          } else {
            ShowMessageTools.displayDialog("dialogTitle".tr(), "systemError".tr(), context);
          }
        }
      } else {
        ShowMessageTools.displayToast('systemError'.tr());
      }
      throw Exception(ex);
    }
  }

  //Get Request
  Future<Response?> httpGetRequest(String path, BuildContext context) async {
    try {
      Response response = await dio!.get(path);
      return response;
    } on DioError catch (ex) {
      if (ex.type == DioErrorType.connectTimeout) {
        ShowMessageTools.displayToast("connectionTimeout".tr());
      } else if (ex.type == DioErrorType.other) {
        ShowMessageTools.displayToast("connectionTimeout".tr());
      } else if (ex.response!.data != null) {
        if (ex.response!.statusCode == 401) {
          ShowMessageTools.displayToast('sessionExpired'.tr());

          final user = Provider.of<UserProvider>(context, listen: false).getUserDetails;

          await ClearUserData.clearUserDataAndNavigateToLoginPage(user, context);
        } else {
          dynamic decodedJson = json.decode(ex.response.toString());
          if (decodedJson['jsonLanguageKey'] != null && decodedJson['jsonLanguageKey'] != "") {
            ShowMessageTools.displayDialog("dialogTitle".tr(), decodedJson['jsonLanguageKey'].toString().tr(), context);
          } else {
            ShowMessageTools.displayDialog("dialogTitle".tr(), "systemError".tr(), context);
          }
        }
      } else {
        ShowMessageTools.displayToast('systemError'.tr());
      }
      throw Exception(ex);
    }
  }
}
