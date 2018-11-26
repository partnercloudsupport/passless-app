import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passless_android/pages/receipt_received.dart';
import 'utils/themes.dart';
import 'receipt_app.dart';

/// Main entry point for the app.
void main() => runApp(new ReceiptMaterialApp());

/// Root class for the material app.
class ReceiptMaterialApp extends StatefulWidget {
  @override
  ReceiptMaterialAppState createState() {
    return new ReceiptMaterialAppState();
  }
}

/// Defines material app state like the theme.
class ReceiptMaterialAppState extends State<ReceiptMaterialApp> {
  static const stream = const EventChannel('flutter.passless.com/nfc-stream');

  ReceiptMaterialAppState() {
    stream.receiveBroadcastStream().listen((j) => 
      Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => new ReceiptReceivedPage(j)
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        debugShowCheckedModeBanner: false, 
        theme: darkTheme, 
        home: new ReceiptApp());
  }
}
