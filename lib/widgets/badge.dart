import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

Widget buildBadge() => RotationTransition(
      turns: AlwaysStoppedAnimation(-45 / 360),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 25),
        width: 160,
        color: Colors.white,
        child: Text(
          'comingSoon',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ).tr(),
      ),
    );
