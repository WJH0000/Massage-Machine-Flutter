// ignore_for_file: deprecated_member_use

import 'package:control_app/model/doctorRecommendMassageSetting.dart';
import 'package:control_app/utils/loader.dart';
import 'package:control_app/utils/showMessageTools.dart';
import 'package:control_app/view/ControlPageDesign2.dart';
import 'package:control_app/widgets/bluetoothOffScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


//import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:http/http.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:easy_localization/easy_localization.dart';
import 'device.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothListPage extends StatefulWidget {
  final bool isGetDoctorRecommend;
  final DoctorRecommendMassageSetting doctorRecommendMassageSetting;
  BluetoothListPage({
    required this.isGetDoctorRecommend,
    required this.doctorRecommendMassageSetting,
    Key? key,
  }) : super(key: key);

  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = [];
  final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();

  @override
  _BluetoothListPageState createState() => _BluetoothListPageState();
}

class _BluetoothListPageState extends State<BluetoothListPage> {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = [];
  final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();
  final _writeController = TextEditingController();
  late BluetoothDevice _connectedDevice;
  late BluetoothDeviceState _bluetoothState=BluetoothDeviceState.disconnected;
  List<BluetoothService> _services= [];
  //status to prevent snackbar show repeat
  bool _isSnackbarActive = false;

  //refresh controller
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
 
  bool isConnected=false;

  _addDeviceTolist(final BluetoothDevice device) {
    if (!devicesList.contains(device)) {
      setState(() {
        devicesList.add(device);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    FlutterBlue.instance.state.listen((state) {
if (state == BluetoothState.off) {

  final SnackBar snackBar = SnackBar(
        content: Text(
          "Turn on Bluetooth to Continue..",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ).tr(),
        backgroundColor: Colors.redAccent,
      );
ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
else if(state==BluetoothState.on)
{
    flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }
    });
    flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
    flutterBlue.startScan();
}
});
    
 }
    

  ListView _buildListViewOfDevices() {
    List<Container> containers = [];
    for (BluetoothDevice device in devicesList) {
      containers.add(
        Container(
          height: 50,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(device.name == '' ? '(unknown device)' : device.name),
                    Text(device.id.toString()),
                  ],
                ),
              ),
              FlatButton(
                  color: Colors.blue,
                  child: Text(
                    'Connect',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    //showLoader(context);
                    initializeBluetoothConnection(device);
                  }),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  initializeBluetoothConnection(BluetoothDevice device) {

    setState(() {
   widget.flutterBlue.stopScan();
   try {
     device.connect();
     _connectedDevice = device;
 _bluetoothState=BluetoothDeviceState.connected;
     Loader.hide();
      final SnackBar snackBar = SnackBar(
        content: Text(
          device.name+" connected",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ).tr(),
        backgroundColor: Colors.redAccent,
      );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print('Device Connected');
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.topToBottom,
              child: ControlConnectedDevicePage2(
                  isGetDoctorRecommend: widget.isGetDoctorRecommend,
                  doctorRecommendMassageSetting:
                      widget.doctorRecommendMassageSetting,
                  bluetoothConnection: _connectedDevice,
                  bluetoothState: _bluetoothState,
                 )));
                
   } catch (e) {
     Loader.hide();
      final SnackBar snackBar = SnackBar(
        content: Text(
          "failConnectBluetoothDevice",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ).tr(),
        backgroundColor: Colors.redAccent,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print('Cannot connect, exception occured');
      throw e;
   } finally {
     //_services = await device.discoverServices();
   }
 });
    //showLoader(context);
    
    
    
  }

  //Update snacbar to false when
  updateSnackbarToFalse() {
    setState(() {
      _isSnackbarActive = false;
    });
  }

  ListView _buildView() {
    
return _buildListViewOfDevices();
      // if (_connectedDevice != null) {
      //   return _buildConnectDeviceView();
      // }
  }

  ListView _buildConnectDeviceView() {
    List<Container> containers = [];
    for (BluetoothService service in _services) {
      containers.add(
        Container(
          height: 50,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(service.uuid.toString()),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(45.0),
          child: new AppBar(
            title: Text('deviceList').tr(),
            backgroundColor: Color(0xF6698FFa),
            actions: <Widget>[
              FlatButton.icon(
                  highlightColor: Color(0xFFa5c1fa),
                  focusColor: Color(0xFFa5c1fa),
                  hoverColor: Color(0xFFa5c1fa),
                  disabledColor: Color(0xFFa5c1fa),
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                  label: Text(
                    "refresh",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ).tr(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  splashColor: Colors.deepPurple,
                   onPressed: () async {}
                 
                  //   await loadPairedDevices().then((_) {
                  //     // show('listRefreshed'.tr());
                  //     ShowMessageTools.showSnackBar('listRefreshed'.tr(),
                  //         updateSnackbarToFalse, _isSnackbarActive, context);
                  //   });
                  // }
                  ),
            ],
            leading: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_left,
                size: 30,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        body:SafeArea(child: Column(children: [
          Expanded(child: _buildView(),),
          Container(
                  width: MediaQuery.of(context).size.width - 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  margin:
                      EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 20),
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "note",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ).tr(),
                                Flexible(
                                  child: Text(
                                    "doctorRecommendNote",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ).tr(),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      )))
        ],),) 
      );

  @override
  void dispose() {
    super.dispose();
  }

  loadPairedDevices() {}
}
