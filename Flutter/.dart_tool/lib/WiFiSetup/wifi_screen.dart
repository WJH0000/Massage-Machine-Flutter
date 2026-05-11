import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:permission_handler/permission_handler.dart';

class WifiScreen extends StatefulWidget {
  const WifiScreen({super.key});

  @override
  State<WifiScreen> createState() => _WifiScreenState();
}

class _WifiScreenState extends State<WifiScreen> {
  List<WiFiAccessPoint> accessPoints = [];
  bool isScanning = false;

  Future<void> scanNetworks() async {
    setState(() => isScanning = true);

    // 1. Check and request location permission
    if (!await Permission.location.isGranted) {
      final status = await Permission.location.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission required')),
          );
        }
        setState(() => isScanning = false);
        return;
      }
    }

    try {
      // 2. Use instance method correctly
      final results = await WiFiScan.instance.getScannedResults();
      
      setState(() {
        accessPoints = results.value ?? []; // Handle the Result object
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wi-Fi scan failed: $e')),
        );
      }
      print('Wi-Fi scan failed: $e');
    } finally {
      if (mounted) {
        setState(() => isScanning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WiFi Networks')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: isScanning ? null : scanNetworks,
            child: isScanning
                ? const CircularProgressIndicator()
                : const Text('Scan Networks'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: accessPoints.length,
              itemBuilder: (context, index) {
                final ap = accessPoints[index];
                return ListTile(
                  title: Text(ap.ssid),
                  subtitle: Text('Signal: ${ap.level}dBm'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}