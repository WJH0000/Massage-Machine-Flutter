import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:control_app/widgets/bluetoothDeviceListEntry.dart'; // Adjust path if needed
import 'package:easy_localization/easy_localization.dart';
import 'package:control_app/widgets/navigation_drawer.dart';


class DevicePage extends StatefulWidget {
  static const routeName = '/devicePage';

  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  List<BluetoothDevice> devices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getBondedDevices();
  }

  void getBondedDevices() async {
    List<BluetoothDevice> bondedDevices =
        await FlutterBluetoothSerial.instance.getBondedDevices();
    setState(() {
      devices = bondedDevices;
      isLoading = false;
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    try {
      BluetoothConnection connection =
          await BluetoothConnection.toAddress(device.address);
      print('Connected to ${device.name}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connected to ${device.name}")),
      );

      // You can store the connection for later use
    } catch (e) {
      print('Error connecting: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to connect to ${device.name}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.locale;
    return Scaffold(
      drawer: NavigationDrawerWidget(DevicePage.routeName),
      appBar: AppBar(
        title: Text("Devices"),
        backgroundColor: Color(0xF6698FFa),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : devices.isEmpty
              ? Center(child: Text("No paired devices found"))
              : ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return BluetoothDeviceListEntry(
                      device: device,
                      onTap: () => connectToDevice(device),
                    );
                  },
                ),
    );
  }
}
