import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class DeviceListWidget extends StatefulWidget {
  final Function(BluetoothDevice) onDeviceSelected;

  const DeviceListWidget({Key? key, required this.onDeviceSelected}) : super(key: key);

  @override
  _DeviceListWidgetState createState() => _DeviceListWidgetState();
}

class _DeviceListWidgetState extends State<DeviceListWidget> {
  List<BluetoothDevice> _devices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDevices();
  }

  void _fetchDevices() async {
    final devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    setState(() {
      _devices = devices.toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _devices.length,
            itemBuilder: (context, index) {
              final device = _devices[index];
              return ListTile(
                leading: Icon(Icons.bluetooth),
                title: Text(device.name ?? 'Unknown device'),
                subtitle: Text(device.address),
                onTap: () => widget.onDeviceSelected(device),
              );
            },
          );
  }
}
