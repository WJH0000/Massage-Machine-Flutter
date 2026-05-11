import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:easy_localization/easy_localization.dart';

class MassageSettingItem extends StatelessWidget {
  final Function onTap;
  final String title;
  final String description;
  final int count;

  MassageSettingItem({required this.onTap, required this.title, required this.description, required this.count});

  @override
  Widget build(BuildContext context) {
    context.locale;
    return ListTile(
      leading: Icon(Icons.settings_accessibility),
      title: Text("recommend", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)).tr(namedArgs: {'value1': count.toString()}),
      subtitle: Text(description.toString()),
      trailing: SizedBox(
        child: ElevatedButton(
          child: Text(
            "select",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ).tr(),
          onPressed: () {
            onTap();
          },
          style: ElevatedButton.styleFrom(
            primary: Color(0xF6698FFa),
            onPrimary: Colors.white,
            padding: EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ),
    );
  }
}
