import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceInfo extends StatefulWidget {
  DeviceInfo(
    this.devicename,
    this.semanticubication,
    this.habilityone,
    this.habilitytwo,
    this.habilitythree,
  );

  final String devicename;
  final String habilitythree;
  final String habilitytwo;
  final String semanticubication;
  final String habilityone;

  @override
  State<StatefulWidget> createState() => new _DeviceInfoState();
}

class _DeviceInfoState extends State<DeviceInfo> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  initState() {
    readDevicePreferences();
    super.initState();
    _controllerDeviceName = new TextEditingController(text: widget.devicename);

    getDeviceInfo();
  }

  String _deviceName,
      _semanticUbication,
      _habilityOne,
      _habilityTwo,
      _habilityThree;
  String _deviceid = '';
  String _deviceBrand = '';

  TextEditingController _controllerDeviceName;
  TextEditingController _controllerSemanticUbication;

  TextEditingController _controllerHabilityOne;

  TextEditingController _controllerHabilityTwo;

  TextEditingController _controllerHabilityThree;

  var location = new Location();

  void _setdeviceid(String deviceid) => setState(() => _deviceid = deviceid);
  void _setdeviceBrand(String deviceBrand) =>
      setState(() => _deviceBrand = deviceBrand);

  getDeviceInfo() async {
    try {
      DeviceInfoPlugin deviceInfo = new DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      _setdeviceid(androidInfo.androidId);
      _setdeviceBrand(androidInfo.brand);

      print(_deviceid);
    } catch (e) {}
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

  setOnlineDevice() async {
    try {
      

      var location = new Location();
      LocationData userLocation;
      userLocation = await location.getLocation();
      var latitude = userLocation.latitude;
      var longitude = userLocation.longitude;
      _formKey.currentState.save();

      Firestore.instance.collection('globaldevices').document().setData({
        'Name': _deviceName,
        'brand': _deviceBrand,
        'habilityone': _habilityOne,
        'habilitytwo': _habilityTwo,
        'habilitythree': _habilityThree,
        'id': _deviceid,
        'latitude': latitude,
        'longitude': longitude,
        'semanticubication': _semanticUbication,
      });

      await saveDevicePreferences(_deviceName, _semanticUbication, _habilityOne,
        _habilityTwo, _habilityThree);

     addSemanticUbicationToList();
     addBrandToList();
     addHablityOneToList();
     addHablityTwoToList();
    addHablityThreeToList();

      Navigator.pop(context);
    } catch (e) {
     // e.toString();
    }
  }

  saveDevicePreferences(String _deviceName, String _semanticUbication,
      String _habilityOne, String _habilityTwo, String _habilityThree) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString("_deviceName", _deviceName);
    prefs.setString("_semanticUbication", _semanticUbication);
    prefs.setString("_habilityOne", _habilityOne);
    prefs.setString("_habilityTwo", _habilityTwo);
    prefs.setString("_habilityThree", _habilityThree);
  }

  addHablityOneToList() {
    var userQuery = Firestore.instance
        .collection('habilities')
        .where('hability', isEqualTo: _habilityOne)
        .limit(1);

    userQuery.getDocuments().then((data) {
      if (data.documents.length <= 0) {
       
          Firestore.instance
              .collection('habilities')
              .document()
              .setData({'hability': _habilityOne});
       
      } else {
        print("Habilidad en existencia");
      }
    });
  }

  addHablityThreeToList() {
    var userQuery = Firestore.instance
        .collection('habilities')
        .where('hability', isEqualTo: _habilityThree)
        .limit(1);

    userQuery.getDocuments().then((data) {
      if (data.documents.length <= 0) {
        
          Firestore.instance
              .collection('habilities')
              .document()
              .setData({'hability': _habilityThree});
       
      } else {
        print("Habilidad en existencia");
      }
    });
  }

  addHablityTwoToList() {
    var userQuery = Firestore.instance
        .collection('habilities')
        .where('hability', isEqualTo: _habilityTwo)
        .limit(1);

    userQuery.getDocuments().then((data) {
      if (data.documents.length <= 0) {
        
          Firestore.instance
              .collection('habilities')
              .document()
              .setData({'hability': _habilityTwo});
       
      } else {
        print("Habilidad en existencia");
      }
    });
  }

  addBrandToList() {
    var userQuery = Firestore.instance
        .collection('brands')
        .where('brand', isEqualTo: _deviceBrand)
        .limit(1);

    userQuery.getDocuments().then((data) {
      if (data.documents.length <= 0) {
        
          Firestore.instance
              .collection('brands')
              .document()
              .setData({'brand': _deviceBrand});
       
      } else {
        print("Marca en existencia");
      }
    });
  }

  addSemanticUbicationToList() {
    var userQuery = Firestore.instance
        .collection('semanticubications')
        .where('semanticubication', isEqualTo: _semanticUbication)
        .limit(1);

    userQuery.getDocuments().then((data) {
      if (data.documents.length <= 0) {
          Firestore.instance
              .collection('semanticubications')
              .document()
              .setData({'semanticubication': _semanticUbication});
        
      } else {
        print("Ubicacion en existencia");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: new AppBar(
        title: new Text("Configuration"),
      ),
      body: new SafeArea(
          top: false,
          bottom: false,
          child: new Form(
              key: _formKey,
              autovalidate: true,
              child: new ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: <Widget>[
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.device_unknown),
                      hintText: 'Enter device name',
                      labelText: 'Device Name',
                    ),
                    onSaved: (value) => _deviceName = value,
                    autofocus: true,
                    controller: _controllerDeviceName,
                  ),
                  new Divider(
                    height: 30,
                    color: Colors.blue,
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.my_location),
                      hintText: 'Enter semantic ubication of device',
                      labelText: 'Semantic Ubication',
                    ),
                    onSaved: (String value) {
                      _semanticUbication = value;
                    },
                  ),
                  new Divider(
                    height: 30,
                    color: Colors.blue,
                  ),
                  new TextFormField(
                      decoration: const InputDecoration(
                        icon: const Icon(Icons.panorama_fish_eye),
                        hintText: 'Enter first ability of the device',
                        labelText: 'Ability one',
                      ),
                      onSaved: (String value) {
                        _habilityOne = value;
                      }),
                  new TextFormField(
                      decoration: const InputDecoration(
                        icon: const Icon(Icons.panorama_vertical),
                        hintText: 'Enter second ability of the device',
                        labelText: 'Ability two',
                      ),
                      onSaved: (String value) {
                        _habilityTwo = value;
                      }),
                  new TextFormField(
                      decoration: const InputDecoration(
                        icon: const Icon(Icons.panorama_horizontal),
                        hintText: 'Enter third ability of the device',
                        labelText: 'Ability three',
                      ),
                      onSaved: (String value) {
                        _habilityThree = value;
                      }),
                  new Divider(height: 30, color: Colors.blue),
                  new Container(
                      padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                      child: new RaisedButton(
                        child: const Text('SAVE'),
                        color: Colors.blue,
                        onPressed: () => setOnlineDevice(),
                      )),
                ],
              ))),
    );
  }
}
