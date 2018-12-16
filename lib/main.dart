import 'package:flutter/material.dart';
import 'package:passless_android/data/data_provider.dart';
import 'package:passless_android/data/nfc_provider.dart';
import 'package:passless_android/receipt_app.dart';

/// Main entry point for the app.
void main() {
  runApp(ReceiptMaterialApp());
}

/// Root class for the material app.
class ReceiptMaterialApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ReceiptMaterialAppState();
}

/// Defines material app state like the theme.
class _ReceiptMaterialAppState extends State<ReceiptMaterialApp> {
  @override
  Widget build(BuildContext context) {
    return NfcProvider(
      child: DataProvider(
        child: MaterialApp(
          debugShowCheckedModeBanner: false, 
          theme: ThemeData.light(), 
          home: ReceiptApp(),
        )
      ),
    );
  }
}
