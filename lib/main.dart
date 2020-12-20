import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InstantWhatsApp extends StatefulWidget {
  @override
  _InstantWhatsAppState createState() => _InstantWhatsAppState();
}

class _InstantWhatsAppState extends State<InstantWhatsApp> {
  List<String> phoneNumbers = [];
  Future data;
  final title = 'Instant WhatsApp';

  @override
  void initState() {
    data = getCalls();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Iterable<CallLogEntry>>(
        future: data,
        builder: (context, AsyncSnapshot<Iterable<CallLogEntry>> snapshot) {
          if (snapshot.hasData) {
            phoneNumbers = getNumbers(snapshot);
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                appBar: AppBar(
                  title: Text(title),
                ),
                body: Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                        itemCount: phoneNumbers.length,
                        itemBuilder: (context, index) {
                          return Container(
                            child: queueItem(index),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
            ;
          } else {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: SafeArea(
                  child: Column(
                    children: <Widget>[
                      Text('Loading...'),
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }

  Future getCalls() {
    Future<Iterable<CallLogEntry>> entries = CallLog.get();
    return entries;
  }

  List<String> getNumbers(snapshot) {
    List<CallLogEntry> logs = snapshot.data.toList();
    for (int i = 0; i < logs.length; i++) {
      phoneNumbers.add(logs[i].number);
    }
    return phoneNumbers.toSet().toList();
  }

  void launchWhatsApp({
    @required String phone,
    isBusiness = false,
  }) async {
    String url = '';
    String package = 'com.whatsapp';
    if (isBusiness == true) {
      package = 'com.whatsapp.w4b';
    }

    if (Platform.isAndroid) {
      url = "whatsapp://send?phone=$phone";
      url = "https://api.whatsapp.com/send?phone=${phone}";
      AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: url,
        package: package,
      );
      await intent.launch();
    } else {
      url = "whatsapp://wa.me/$phone/";
    }
  }

  queueItem(index) {
    return Card(
      child: Row(
        children: <Widget>[
          Flexible(
            child: ListTile(
              title: Text(
                '${phoneNumbers[index]}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 5),
            child: RaisedButton(
              child: Text('WhatsApp'),
              onPressed: () {
                launchWhatsApp(phone: '${phoneNumbers[index]}');
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 5),
            child: RaisedButton(
              child: Text(
                'WA Business',
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
              onPressed: () {
                launchWhatsApp(
                  phone: '${phoneNumbers[index]}',
                  isBusiness: true,
                );
              },
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.all(4),
          //   child: Icon(
          //     // Icon.battery,
          //     MyFlutterApp.whatsapp,
          //     size: 25,
          //   ),
          // ),
        ],
      ),
    );
  }
}

void main() {
  runApp(InstantWhatsApp());
}
