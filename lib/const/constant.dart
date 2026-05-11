import 'dart:ui';

import 'package:google_sign_in/google_sign_in.dart';

// enum fileType { sheet, pdf, video, document }

List<String> displayTime = [
  '1',
  '10',
  '20',
  '30',
];
//const String baseUrl = "https://remotemassager.azurewebsites.net/";
//const String baseUrl = "https://192.168.29.82:45456/";
//const String baseUrl = "http://10.1.0.117:45455/";
//const String baseUrl = "https://remotebackend.conveyor.cloud/";
//const String baseUrl = "http://10.0.0.129:45456/";
const String baseUrl = "https://remotebackend.serviceguardian.sg/";


const List<String> LOGIN_TYPES = [
  'GOOGLE',
  'FACEBOOK',
  'APP',
];

//Google Sign In
GoogleSignIn googleSignIn = GoogleSignIn();

// List<Map<String, dynamic>> progressItems = [
//   {
//     'color': Color(0xff3a49f6),
//     'progress': .1,
//   },
//   {
//     'color': Color(0xfff7bc48),
//     'progress': .1,
//   },
//   {
//     'color': Color(0xffef5b54),
//     'progress': .5,
//   },
//   {
//     'color': Color(0xff5dcb86),
//     'progress': .3,
//   }
// ];

// List<Map<String, dynamic>> filesList = [
//   {'name': 'sheet.xlsx', 'date': '13/10/2019', 'size': '10 KB', 'type': fileType.sheet},
//   {'name': 'Cybdom Course.pdf', 'date': '13/09/2019', 'size': '29 MB', 'type': fileType.pdf},
//   {'name': 'Provider Video.mp4', 'date': '04/10/2019', 'size': '293 MB', 'type': fileType.video},
//   {'name': 'invoice.docx', 'date': '04/10/2019', 'size': '293 MB', 'type': fileType.document},
//   {'name': 'sheet.xlsx', 'date': '13/10/2019', 'size': '10 KB', 'type': fileType.sheet},
//   {'name': 'Cybdom Course.pdf', 'date': '13/09/2019', 'size': '29 MB', 'type': fileType.pdf},
//   {'name': 'Provider Video.mp4', 'date': '04/10/2019', 'size': '293 MB', 'type': fileType.video},
//   {'name': 'invoice.docx', 'date': '04/10/2019', 'size': '293 MB', 'type': fileType.document},
// ];

const String PAUSED = "P";
const String RESUME = "R";
const String STOPPED = "ST";

const String LOGIN_PLATFORM_APP = 'APP_PLATFORM';
