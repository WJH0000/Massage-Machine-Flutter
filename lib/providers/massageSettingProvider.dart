import 'package:control_app/model/massageSetting.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MassageSettingProvider with ChangeNotifier {
  MassageSetting _massageSetting = new MassageSetting();

  void setMassageSetting(MassageSetting massageSetting) {
    _massageSetting = massageSetting;
    notifyListeners();
  }

  MassageSetting get getMassageSetting {
    return _massageSetting;
  }

  void clearMassageSetting() {
    _massageSetting = new MassageSetting();
    notifyListeners();
  }
}
