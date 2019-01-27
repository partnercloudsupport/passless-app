import 'package:flutter/material.dart';
import 'package:passless_android/data/data_provider.dart';
import 'package:passless_android/l10n/passless_localizations.dart';
import 'package:passless_android/widgets/drawer_menu.dart';
import 'package:passless_android/widgets/menu_button.dart';
import 'package:passless_android/widgets/receipt_listview.dart';
import 'package:passless_android/pages/search_page.dart';
import 'package:passless_android/models/receipt.dart';

/// The root page of the app.
class LatestReceiptsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LatestReceiptsPageState();
}

class _LatestReceiptsPageState extends State<LatestReceiptsPage> {
  List<Receipt> _receipts;
  bool _isLoading = true;

  // Use this method as an alternative to initState, 
  // in order to use the repository.
  @override
  void didChangeDependencies() { 
    _initReceipts();

    // Listen for data changes.
    Repository.of(context).listen(() => _initReceipts());
    super.didChangeDependencies();
  }

  _initReceipts() async {
    var receipts;
    try {
      receipts = await Repository.of(context).getReceipts();
    } catch (e) {
      print("Failed to get receipts: '${e.message}'.");
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    /// Sets the receipts as state and stops the loading process.
    setState(() {
      _receipts = receipts;
      _isLoading = false;
    });
  }

  /// Builds the root page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerMenu(),
      appBar: AppBar(
        leading: MenuButton(),
        title: Text(PasslessLocalizations.of(context).latestReceiptsTitle),
        actions: <Widget>[
          IconButton(
            icon: Hero(
              tag: "searchIcon",
              child: Material(
                color: Colors.transparent,
                child: IconTheme(
                  data: Theme.of(context).primaryIconTheme,
                  child: Icon(Icons.search)
                )
              )
            ),
            tooltip: MaterialLocalizations.of(context).searchFieldLabel,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SearchPage())
              );
            }
          )
        ]
      ),
      // Either load or show the list of receipts.
      body: _isLoading ? 
        const CircularProgressIndicator() : 
        ReceiptListView(_receipts),
    );
  }
}