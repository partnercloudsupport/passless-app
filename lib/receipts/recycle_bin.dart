import 'package:flutter/material.dart';
import 'package:passless/data/data_provider.dart';
import 'package:passless/l10n/passless_localizations.dart';
import 'package:passless/receipts/delete_dialog.dart';
import 'package:passless/receipts/restore_dialog.dart';
import 'package:passless/widgets/drawer_menu.dart';
import 'package:passless/widgets/menu_button.dart';
import 'package:passless/receipts/receipt_listview.dart';

class RecycleBinPage extends StatefulWidget {
  @override
  RecycleBinPageState createState() {
    return new RecycleBinPageState();
  }
}

class RecycleBinPageState extends State<RecycleBinPage> {
  int binSize = 0;

  @override
  void didChangeDependencies() {
    _initSize();
    super.didChangeDependencies();
  }

  Future<void> _initSize() async {
    int size = await Repository.of(context).getRecycleBinSize();
    setState(() {
      binSize = size;
    });
  }

  /// Builds the root page.
  @override
  Widget build(BuildContext context) {
    var loc = PasslessLocalizations.of(context);
    var actions = List<Widget>();
    if (binSize > 0) {
      actions.add(
        IconButton(
          icon: Icon(Icons.delete_forever),
          tooltip: loc.emptyRecycleBin,
          onPressed: () async {
            bool shouldDelete = await DeleteDialog.show(
              context, 
              binSize);

            if (shouldDelete) {
              await Repository.of(context).emptyRecycleBin();
              Navigator.of(context).pop();
            }
          },
        )
      );
    }

    return Scaffold(
      drawer: DrawerMenu(),
      appBar: AppBar(
        leading: MenuButton(),
        title: Text(loc.recycleBin),
        actions: actions,
      ),
      body: ReceiptListView(
        dataFunction: Repository.of(context).getDeletedReceipts,
        selectionActionBuilder: (context, receipts) =>
          <Widget>[
            IconButton(
              icon: Icon(Icons.delete_forever),
              tooltip: loc.emptyRecycleBin,
              onPressed: () async {
                bool shouldDelete = await DeleteDialog.show(
                  context, 
                  receipts.length);

                if (shouldDelete) {
                  await Repository.of(context).deleteBatchPermanently(receipts);
                  Navigator.of(context).pop();
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.restore_from_trash),
              tooltip: loc.restoreFromTrash,
              onPressed: () async {
                bool shouldRestore = await RestoreDialog.show(
                  context, 
                  receipts.length);

                if (shouldRestore) {
                  await Repository.of(context).undeleteBatch(receipts);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
      )
    );
  }
}