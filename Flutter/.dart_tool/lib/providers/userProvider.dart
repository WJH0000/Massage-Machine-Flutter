import 'package:control_app/model/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  User _user = new User();

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  User get getUserDetails {
    return _user;
  }

  void clearUser() {
    _user = new User();
    notifyListeners();
  }
}
