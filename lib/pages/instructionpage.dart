import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_database/firebase_database.dart';

class InstructionPage extends StatefulWidget {
  InstructionPage({
    Key key,
    this.documentId,
  }) : super(key: key);

  final String documentId;

  @override
  State<StatefulWidget> createState() => new _InstructionPageState();
}

class _InstructionPageState extends State<InstructionPage> {
  @override
  Widget build(BuildContext context) {
    String documentId = widget.documentId;

    return new Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: new AppBar(
        title: new Text(documentId),
      ),
      body: new Row(
        children: <Widget>[
          Expanded(
              child: SizedBox(
            height: 600.0,
            child: new StreamBuilder<DocumentSnapshot>(
                stream: Firestore.instance
                    .collection('instructions')
                    .document(documentId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Text('Connecting...');
                  final DocumentSnapshot _card = snapshot.data;
                  String hability1 = "  ";
                  String hability2 = "  ";

                  String hability3 = "  ";

                  if (_card['habilityone'] != null) {
                    hability1 = _card['habilityone'];
                  }

                  if (_card['habilitytwo'] != null) {
                    hability2 = _card['habilitytwo'];
                  }

                  if (_card['habilitythree'] != null) {
                    hability3 = _card['habilitythree'];
                  }

                  var icono;

                  if (_card['instruction'] == "Start") {
                    icono = new Icon(Icons.play_arrow,  size: 50);
                  }

                  if (_card['instruction'] == "Stop") {
                    icono = new Icon(Icons.stop, size: 50,);
                  }

                  return new Container(
                    padding: new EdgeInsets.all(32.0),
                    child: new Column(
                      children: <Widget>[
                        icono
                         ,
                        new Text(
                          'Instruction: ',
                          style: TextStyle(fontSize: 21,fontWeight: FontWeight.bold ),
                        ),
                        new Text(_card['instruction'],),
                        new Text(""),
                        new Text('Device ID: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 )),
                        new Text(_card['deviceid']),
                        new Text(""),
                        new Text('Comes from (User ID): ', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
                        new Text(_card['userid']),
                        new Text(""),
                        new Text('Time: ', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
                        new Text(_card['time']),
                        new Text(""),
                        new Column(
                          children: <Widget>[
                            new Text("Abilities:",
                                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                            new Text(hability1),
                            new Text(hability2),
                            new Text(hability3),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
          ))
        ],
      ),
    );
  }
}
