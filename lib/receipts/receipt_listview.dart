import 'package:passless_android/data/data_provider.dart';
import 'package:passless_android/l10n/passless_localizations.dart';
import 'package:passless_android/models/receipt.dart';
import 'package:flutter/material.dart';
import 'package:passless_android/models/receipt_state.dart';
import 'package:passless_android/receipts/receipt_detail_page.dart';
import 'package:passless_android/receipts/delete_dialog.dart';
import 'package:passless_android/settings/price_provider.dart';
import 'package:passless_android/widgets/spinning_hero.dart';

/// Shows a list of receipts.
class ReceiptListView extends StatelessWidget {
  final List<Receipt> receipts;
  final bool isSelectable;
  ReceiptListView(this.receipts, {this.isSelectable = true});

  /// Builds the receipt list.
  @override
  Widget build(BuildContext context) => 
    _ReceiptListView(receipts, isSelectable: isSelectable,);
}

class _SelectingReceiptListView extends StatefulWidget {
  final List<Receipt> receipts;
  final int primarySelection;

  _SelectingReceiptListView(
    this.receipts, 
    this.primarySelection);

  @override
  _SelectingReceiptListViewState createState() 
    => _SelectingReceiptListViewState();
}

class _SelectingReceiptListViewState extends State<_SelectingReceiptListView> {
  List<int> _selection;

  @override
  void initState() {
    super.initState();
    this._selection = [widget.primarySelection];
  }

  @override
  Widget build(BuildContext context) {
    var loc = PasslessLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: SpinningHero(
          tag: "appBarLeading",
          child: IconButton(
            icon: Icon(Icons.clear),
            tooltip: loc.clearTooltip,
            onPressed: () {
              // Indicate zero receipts deleted.
              Navigator.of(context).pop(0);
            },
          ),
        ),
        title: Text(loc.receiptsSelectedTitle(_selection.length)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
            onPressed: () async {
              var toDelete = _selection.map((s) => widget.receipts[s]).toList();
              await Repository.of(context).deleteBatch(toDelete);
              Navigator.of(context).pop(toDelete.length);
            },
          )
        ],
      ),
      body: _ReceiptListView(
        widget.receipts, 
        selected: _selection,
        selectionChangedCallback: _selectionChangedCallback),
    );
  }

  void _selectionChangedCallback() {
    setState(() {});
  }
}

class _ReceiptListView extends StatefulWidget {
  final List<Receipt> receipts;
  final List<int> selected;
  final void Function() selectionChangedCallback;
  final bool isSelectable;

  _ReceiptListView(
    this.receipts, 
    {
      this.isSelectable,
      List<int> selected, 
      this.selectionChangedCallback
    }) : this.selected = selected ?? List<int>();

  @override
  _ReceiptListViewState createState() => _ReceiptListViewState();
}

class _ReceiptListViewState extends State<_ReceiptListView> {
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    _isSelecting = widget.selected.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    var loc = PasslessLocalizations.of(context);
    var pri = PriceProvider.of(context);
    var theme = Theme.of(context);

    Widget result;
    if (widget.receipts.isEmpty) {
      result = Text(loc.noReceiptsFound);
    }
    else {
      result = ListView.builder(
        itemCount: widget.receipts.length,
        itemBuilder: (BuildContext context, int index) { 
          Receipt receipt = widget.receipts[index];
          bool isSelected = widget.selected.contains(index);
          return Hero(
            tag: "receipt${receipt.id}",
            child: Card(
              clipBehavior: Clip.antiAlias,
              color: isSelected ? theme.selectedRowColor : theme.cardColor,
              child: InkWell(
                onTap: () async {
                  if (_isSelecting) {
                    _onReceiptSelected(index);
                  }
                  else {
                    ReceiptState state = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => 
                          ReceiptDetailPage(receipt, loc.receipt)));
                    if (state == ReceiptState.deleted) {
                      // TODO: Add UNDO button.
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text(loc.movedToRecycleBin(1))
                        )
                      );
                    }
                  }
                },
                onLongPress: () {
                  if (widget.isSelectable) {
                    _onReceiptSelected(index);
                  }
                },
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: <Widget>[ 
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          FutureBuilder<Widget>(
                            // TODO: Logo flickers, make it load during transitions.
                            future: Repository.of(context).getLogo(receipt, 2700),
                            initialData: Container(height: 65, width: 150,),
                            builder: (context, image) {
                              if (image?.data is Image) {
                                var data = image.data as Image;
                                return Container(
                                  height: 65, 
                                  width: 150, 
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[data],
                                  )
                                );
                              }
                              else {
                                return Container(height: 65, width: 150,);
                              }
                            }
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    loc.itemCount(receipt.items.length), 
                                    style: theme.textTheme.subhead
                                  ),
                                  Text(
                                    loc.datetime(receipt.time), 
                                    style: theme.textTheme.subhead
                                  )
                                ],
                              ),
                              Expanded(child: Container(),),
                              Text(
                                pri.price(
                                  receipt.totalPrice, 
                                  receipt.currency
                                ),
                                style: theme.textTheme.title,
                              )
                            ],
                          )
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: isSelected ? Icon(Icons.check_circle, color: theme.primaryColor) : Container(),
                      ),
                    ]
                  ),
                ),
              ),
            )
          );
        }
      );
    }

    return result;
  }

  Future<void> _onReceiptSelected(int index) async {
    var loc = PasslessLocalizations.of(context);
    // If the selected list is currently empty, this will be a new selection.
    // In that case push a new selection page with the same receipts.
    if (widget.selected.isEmpty) {
      int deleteCount = await Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: 
            (context, animation, secondaryAnimation) => 
              _SelectingReceiptListView(
                widget.receipts, 
                index
              )
        )
      );

      if (deleteCount > 0) {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.movedToRecycleBin(deleteCount))
          )
        );
      }

      return;
    }

    // If the receipt was already selected, remove it
    // otherwise add it to selection
    if (!widget.selected.remove(index)) {
      widget.selected.add(index);
    }

    // The last receipt may have been deselected. Then pop to the previous list.
    // NOTE: The only way this function is called, is through selection, so
    // the selection page will be preceded by the non-selected page.
    if (widget.selected.isEmpty) {
      Navigator.of(context).pop(0);
    }
    else {
      // Make sure to update the changes in the list, and a listening parent.
      setState(() {});
      widget.selectionChangedCallback();
    }
  }
}
