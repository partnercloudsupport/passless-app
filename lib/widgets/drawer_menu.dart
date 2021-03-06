import 'package:flutter/material.dart';
import 'package:passless/l10n/passless_localizations.dart';
import 'package:passless/receipts/latest_receipts_page.dart';
import 'package:passless/receipts/recycle_bin.dart';
import 'package:passless/receipts/search_page.dart';
import 'package:passless/settings/settings_page.dart';

class DrawerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var matLoc = MaterialLocalizations.of(context);
    var loc = PasslessLocalizations.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  tooltip: matLoc.backButtonTooltip,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            )
          ),
          ListTile(
            leading: Icon(Icons.receipt),
            title: Text(loc.latestReceiptsTitle),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LatestReceiptsPage())
              );
            }
          ),
          ListTile(
            leading: Icon(Icons.search),
            title: Text(matLoc.searchFieldLabel),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SearchPage())
              );
            }
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text(loc.recycleBin),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RecycleBinPage())
              );
            }
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(loc.settings),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsPage()
                )
              );
            },
          ),
        ],
      )
    );
  }

}