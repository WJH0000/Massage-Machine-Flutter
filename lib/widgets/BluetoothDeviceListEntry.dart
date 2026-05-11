import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:control_app/styles/button_styles.dart';

class BluetoothDeviceListEntry extends StatelessWidget {
  final Function onTap;
  final BluetoothDevice device;

  const BluetoothDeviceListEntry({
    Key? key,
    required this.onTap,
    required this.device,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.devices),
      title: Text(
        device.name ?? "unknownDevice".tr(),
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(device.address.toString()),
      trailing: ElevatedButton(
        onPressed: () => onTap(),
        style: ButtonStyles.purpleButton, // 👈 using imported style
        child: Text("connect", style: TextStyle(fontSize: 16)).tr(),
      ),
    );
  }
}
