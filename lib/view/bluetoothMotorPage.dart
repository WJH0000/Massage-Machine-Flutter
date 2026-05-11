import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothMotorPage extends StatefulWidget {
  @override
  _BluetoothMotorPageState createState() => _BluetoothMotorPageState();
}

class _BluetoothMotorPageState extends State<BluetoothMotorPage> {
  BluetoothConnection? connection;
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;

  bool isConnecting = false;
  bool isConnected = false;

  final TextEditingController _sequenceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getBondedDevices();
  }

  Future<void> getBondedDevices() async {
    final bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
    setState(() {
      devices = bondedDevices.toList();
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    setState(() {
      isConnecting = true;
    });

    try {
      final conn = await BluetoothConnection.toAddress(device.address);
      setState(() {
        connection = conn;
        selectedDevice = device;
        isConnected = true;
        isConnecting = false;
      });

      print('Connected to ${device.name}');
      connection!.input!.listen((data) {
        final received = String.fromCharCodes(data);
        print('Received: $received');
      });
    } catch (e) {
      print('Connection failed: $e');
      setState(() {
        isConnecting = false;
      });
    }
  }

  void sendCommand(String command) {
    if (connection != null && connection!.isConnected) {
      connection!.output.add(Uint8List.fromList('$command\n'.codeUnits));
      connection!.output.allSent;
    }
  }

  @override
  void dispose() {
    connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bluetooth Motor Control"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isConnected
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Connected to: ${selectedDevice?.name ?? "Unknown"}",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  TextField(
                    controller: _sequenceController,
                    decoration: InputDecoration(
                      labelText: "Enter motor sequence (e.g. 4010000050050010)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final cmd = _sequenceController.text.trim();
                      if (cmd.isNotEmpty) sendCommand(cmd);
                    },
                    child: Text("Send Sequence"),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => sendCommand("off"),
                    child: Text("Stop Motor"),
                    style: ElevatedButton.styleFrom(primary: Colors.red),
                  ),
                ],
              )
            : Column(
                children: [
                  Text("Select a paired device:"),
                  DropdownButton<BluetoothDevice>(
                    value: selectedDevice,
                    hint: Text("Choose device"),
                    isExpanded: true,
                    items: devices
                        .map((device) => DropdownMenuItem(
                              value: device,
                              child: Text(device.name ?? device.address),
                            ))
                        .toList(),
                    onChanged: (device) {
                      setState(() => selectedDevice = device);
                    },
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: selectedDevice == null || isConnecting
                        ? null
                        : () => connectToDevice(selectedDevice!),
                    child: Text(isConnecting ? "Connecting..." : "Connect"),
                  ),
                ],
              ),
      ),
    );
  }
}
