import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:easy_localization/easy_localization.dart';

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    context.locale;
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            // Text(
            //   'Bluetooth Adapter is ${state != null ? state!.isEnabled.toString() : 'not available'}.',
            //   style: Theme.of(context)
            //       .primaryTextTheme
            //       .subhead
            //       ?.copyWith(color: Colors.white),
            // ),
            Text(
              'bluetoothNotOn',
            ).tr(),
          ],
        ),
      ),
    );
  }
}
