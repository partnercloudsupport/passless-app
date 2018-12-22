import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nfc/nfc_provider.dart';
import 'package:passless_android/data/data_provider.dart';
import 'package:passless_android/l10n/passless_localizations.dart';
import 'package:passless_android/models/receipt.dart';
import 'package:passless_android/pages/latest_receipts_page.dart';
import 'package:nfc/nfc.dart';
import 'package:passless_android/pages/receipt_detail_page.dart';

/// Root application part.
class ReceiptApp extends StatefulWidget {
  @override
  _ReceiptAppState createState() => _ReceiptAppState();
}

/// Root application state. Initializes the receipt data.
class _ReceiptAppState extends State<ReceiptApp> {
  final Nfc _nfc = Nfc();

  @override
  void initState() {
    super.initState();
    _nfc.configure(
      onMessage: _onMessage
    ).then((r) {
      setState((){});
    });
  }
  
  /// Builds the root page.
  @override
  Widget build(BuildContext context) {
    return LatestReceiptsPage();
  }

  /// Handles received ndef messages (receipts)
  Future<void> _onMessage(String message) async {
    var receiptJson = json.decode(message);
    Receipt receipt = Receipt.fromJson(receiptJson);
    receipt = await Repository.of(context).saveReceipt(receipt);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReceiptDetailPage(
          receipt, 
          PasslessLocalizations.of(context).newReceiptTitle
        )
      )
    );
  }
}
