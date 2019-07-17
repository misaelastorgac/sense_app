import 'package:flutter/material.dart';
import 'package:flutter_sensing_app/pages/authentication.dart';
import 'package:flutter_sensing_app/pages/instructionpage.dart';

import 'package:flutter/foundation.dart';
import 'package:device_info/device_info.dart';
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_sensing_app/pages/deviceinfo.dart';
import 'package:sensors/sensors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key key,
    this.auth,
    this.userId,
    this.onSignedOut,
    this.deviceId,
  }) : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;
  final String deviceId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String _deviceid = '';
  String _deviceUbication = '';
  String _deviceBrand = '';

  List<double> _accelerometerValues;
  List<double> _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  List<StreamSubscription<dynamic>> _streamGyroscopeSubscriptions =
      <StreamSubscription<dynamic>>[];

  _HomePageState() {
    getDeviceInfo();
  }

  void _setdeviceid(String deviceid) => setState(() => _deviceid = deviceid);
  void _setdeviceBrand(String deviceBrand) =>
      setState(() => _deviceBrand = deviceBrand);
  void _setdeviceUbication(String deviceUbication) =>
      setState(() => _deviceUbication = deviceUbication);

  String _deviceName,
      _semanticUbication,
      _habilityOne,
      _habilityTwo,
      _habilityThree;

//  final mainReference = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    listenInstructions();
    readDevicePreferences();
  }

  @override
  void dispose() {
    super.dispose();
  }

  onPlayGyroscope() {
    FirebaseDatabase database = new FirebaseDatabase();
    DatabaseReference _userRef =
        database.reference().child('devicedata/'+'$_deviceid' + '/gyroscope');
    _streamGyroscopeSubscriptions
        .add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
        _userRef.push().set({
          'x': event.x,
          'y': event.y,
          'z': event.z,
        });
      });
    }));
  }

  onStopGyroscope() {
    for (StreamSubscription<dynamic> subscription
        in _streamGyroscopeSubscriptions) {
      subscription.cancel();
    }
  }

  readDevicePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      _deviceName = prefs.getString("_deviceName");
      _semanticUbication = prefs.getString("_semanticUbication");
      _habilityOne = prefs.getString("_habilityOne");
      _habilityTwo = prefs.getString("_habilityTwo");
      _habilityThree = prefs.getString("_habilityThree");

      print(_deviceName);
    } catch (e) {
      e.toString();
      _deviceName = "";
      _semanticUbication = "";
      _habilityOne = "";
      _habilityTwo = "";
      _habilityThree = "";
    }
  }

  listenInstructions() {
    var userId = widget.userId;
    FirebaseDatabase database = new FirebaseDatabase();
    DatabaseReference _userRef = database.reference().child('instructions');

    _userRef.onChildAdded.listen(_onEntryAdded);
  }

  _onEntryAdded(Event event) {
    if (_deviceid == event.snapshot.value['deviceid']) {
      print((event.snapshot.value['instruction']) +
          "." +
          event.snapshot.value['deviceid'] +
          "." +
          event.snapshot.value['userid']);
      if (event.snapshot.value['instruction'] == "Start") {
        if (event.snapshot.value['habilityone'] == "If you are sick" ||
            event.snapshot.value['habilitytwo'] == "If you are sick" ||
            event.snapshot.value['habilitythree'] == "If you are sick") {
          onPlayAccelerometer();
        }
        if (event.snapshot.value['habilityone'] ==
                "If you are feeling lonely" ||
            event.snapshot.value['habilitytwo'] ==
                "if you are feeling lonely" ||
            event.snapshot.value['habilitythree'] ==
                "If you are feeling lonely") {
          print("Aqui");
          onPlayGyroscope();
        }

        if (event.snapshot.value['habilityone'] == "Your mood" ||
            event.snapshot.value['habilitytwo'] == "Your mood" ||
            event.snapshot.value['habilitythree'] == "Your mood") {
          onPlayAccelerometer();
          onPlayGyroscope();
        }

          if (event.snapshot.value['habilityone'] == "If you are sick" &&
            event.snapshot.value['habilitytwo'] == "If you are feeling lonely" ) {
          onPlayAccelerometer();
          onPlayGyroscope();
        }


      }
      if (event.snapshot.value['instruction'] == "Stop") {
        if (event.snapshot.value['habilityone'] == "If you are sick" ||
            event.snapshot.value['habilitytwo'] == "If you are sick" ||
            event.snapshot.value['habilitythree'] == "If you are sick") {
          onStopAccelerometer();
        }


if (event.snapshot.value['habilityone'] == "If you are sick" &&
            event.snapshot.value['habilitytwo'] == "If you are feeling lonely" ) {
          onStopAccelerometer();
          onStopGyroscope();
        }
        
        if (event
                    .snapshot.value['habilityone'] ==
                "If you are feeling lonely" ||
            event.snapshot.value['habilitytwo'] ==
                "if you are feeling lonely" ||
            event.snapshot.value['habilitythree'] ==
                "If you are feeling lonely") {
          onStopGyroscope();
        }

        if (event.snapshot.value['habilityone'] == "Your mood" ||
            event.snapshot.value['habilitytwo'] == "Your mood" ||
            event.snapshot.value['habilitythree'] == "Your mood") {
          onStopAccelerometer();
          onStopGyroscope();
        }

       
      }
    }
  }

  onPlayAccelerometer() {
    FirebaseDatabase database = new FirebaseDatabase();
    DatabaseReference _userRef =
        database.reference().child('devicedata/'+'$_deviceid' + '/accelerometer');

    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
        _userRef.push().set({
          'x': event.x,
          'y': event.y,
          'z': event.z,
        });
      });
    }));
  }

  onStopAccelerometer() {
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();

      String id = widget.userId;
      String documentid = '';

      Firestore.instance
          .collection('globaldevices')
          .where('id', isEqualTo: _deviceid)
          .snapshots()
          .listen((data) {
        print('on snapshot');
        data.documents.forEach((device) {
          print(device.documentID);
          documentid = device.documentID;
          // print(device.documentID + ': ' + device['ubication']);
        });
      });

      Firestore.instance
          .collection('globaldevices')
          .where("id", isEqualTo: _deviceid)
          .getDocuments()
          .then((snapshot) {
        snapshot.documents.last.reference.delete();
      });
    } catch (e) {
      print(e);
    }
  }

  getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = new DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      _setdeviceid(androidInfo.androidId);
      _setdeviceBrand(androidInfo.brand);
      print(_deviceid);
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    }
  }

  addUbicationToList() {
    String id = widget.userId;

    var userQuery = Firestore.instance
        .collection('usuarios/$id/ubications')
        .where('ubication', isEqualTo: _deviceUbication)
        .limit(1);

    userQuery.getDocuments().then((data) {
      if (data.documents.length <= 0) {
        setState(() {
          Firestore.instance
              .collection('usuarios/$id/ubications')
              .document()
              .setData({'ubication': _deviceUbication});
        });
      } else {
        print("Ubicacion en existencia");
      }
    });
  }

  addBrandToList() {
    String id = widget.userId;

    var userQuery = Firestore.instance
        .collection('usuarios/$id/brands')
        .where('brand', isEqualTo: _deviceBrand)
        .limit(1);

    userQuery.getDocuments().then((data) {
      if (data.documents.length <= 0) {
        setState(() {
          Firestore.instance
              .collection('usuarios/$id/brands')
              .document()
              .setData({'brand': _deviceBrand});
        });
      } else {
        print("Marca en existencia");
      }
    });
  }

  setOnlineDevice() {
    String id = widget.userId;

    Firestore.instance
        .collection('usuarios/$id/onlinedevices')
        .document()
        .setData({
      'id': _deviceid,
      'ubication': _deviceUbication,
      'brand': _deviceBrand
    });

    addUbicationToList();
    addBrandToList();

    Navigator.pop(context);
  }

  sendToDevicePage(String documentid) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InstructionPage(
            documentId: documentid,
          ),
        ));
  }

  _getDeviceUbication(BuildContext context) {
    String teamName = '';
    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter current ubication'),
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                autofocus: true,
                decoration: new InputDecoration(
                    labelText: 'Ubication',
                    hintText: 'eg. Kitchen, Bathroom, etc'),
                onChanged: (value) {
                  _setdeviceUbication(value);
                },
              ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(teamName);
                setOnlineDevice();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String id = widget.deviceId;
    return new Scaffold(
        backgroundColor: Colors.blue[100],
        appBar: new AppBar(
          title: new Text('Sensing App'),
          elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 00,
        ),
        drawer: new Drawer(
          child: new ListView(
            children: <Widget>[
              new DrawerHeader(
                child: new Column(children: <Widget>[
                   new Text("SENSING DEVICE"),
                   new Text(id),
                ],),
                
                decoration: new BoxDecoration(color: Colors.lightBlue),
              ),
              new Divider(),
              new ListTile(
                  trailing: new Icon(Icons.settings),
                  title: new Text("Device Configuration"),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeviceInfo(
                            _deviceName,
                            _semanticUbication,
                            _habilityOne,
                            _habilityTwo,
                            _habilityThree),
                      ))),
              new Divider(),
              new ListTile(
                trailing: new Icon(Icons.exit_to_app),
                title: new Text("Disconnect Device"),
                onTap: () => _signOut(),
              ),
            ],
          ),
        ),
        body: new Row(
          children: <Widget>[
            Expanded(
                child: SizedBox(
              child: new StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection('instructions')
                      .where('deviceid', isEqualTo: id)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return CircularProgressIndicator(
                        backgroundColor: Colors.blue[10000],
                      );
                    print(snapshot.data.documents.length);

                    //  print(widget.distanceToLookAround);
                    final int cardLength = snapshot.data.documents.length;
                    return new ListView.builder(
                      itemCount: cardLength,
                      itemBuilder: (BuildContext x, int index) {
                        final DocumentSnapshot _card =
                            snapshot.data.documents[index];
                        var icono;    
                       
                       if(_card['instruction'] == "Start"){
                          icono = new Icon(Icons.play_arrow);
                       }

                       if(_card['instruction'] == "Stop"){
                          icono = new Icon(Icons.stop);
                       }

                        new Divider(height: 30, color: Colors.white);
                        return new ListTile(
                          title: new Row(
                            children: <Widget>[
                              icono,
                              new Text("     " + _card['instruction']),
                            ],
                          ),
                          onTap: () => sendToDevicePage(_card.documentID),
                          subtitle: new Text("            " + _card['userid']),
                        );
                      },
                    );
                  }),
            ))
          ],
        ));
  }
}
