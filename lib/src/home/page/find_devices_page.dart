import 'package:blee_sample_test/src/home/bluetooth/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import '../home_page.dart';
import 'device_page.dart';


class FindDevicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Devices'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(Duration(seconds: 2))
                    .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                initialData: [],
                builder: (c, snapshot) => Column(
                      children: snapshot.data
                          .map((d) => ListTile(
                                title: Text(d.name),
                                subtitle: Text(d.id.toString()),
                                trailing: StreamBuilder<BluetoothDeviceState>(
                                  stream: d.state,
                                  initialData:
                                      BluetoothDeviceState.disconnected,
                                  builder: (c, snapshot) {
                                    if (snapshot.data ==
                                        BluetoothDeviceState.connected) {
                                      return RaisedButton(
                                        child: Text('OPEN'),
                                        onPressed: () => Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) =>
                                                    DevicePage(device: d))),
                                      );
                                    }
                                    return Text(snapshot.data.toString());
                                  },
                                ),
                              ))
                          .toList(),
                    ),
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                      children: snapshot.data
                          .map(
                            (r) => ScanResultTile(
                                  result: r,
                                  onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        r.device.connect();
                                        return DevicePage(device: r.device);
                                      })),
                                ),
                          )
                          .toList(),
                    ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => FlutterBlue.instance
                    .startScan(timeout: Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}