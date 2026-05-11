import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:flutter/material.dart';

void showLoader(BuildContext context) {
  Loader.show(context,
      isAppbarOverlay: true,
      isBottomBarOverlay: true,
      progressIndicator: Center(
        child: Image.asset(
          'assets/img/loading.gif',
          width: 70,
          height: 70,
        ),
      ),
      themeData: Theme.of(context).copyWith(accentColor: Colors.black38),
      overlayColor: Color(0x99E8EAF6));
}
