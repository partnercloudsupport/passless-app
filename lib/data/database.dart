import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:passless_android/models/receipt.dart';

/// A helper for accessing receipt data.
class Repository {

  /// Singleton database instance.
  static Database _db;
  
  /// Returns the initialized singleton database instance.
  Future<Database> get db async {
    if (_db == null) _db = await initDb();

    return _db;
  }

  /// Initializes a new database instance.
  /// 
  /// The database is created on the file system (passless.db) 
  /// if it does not yet exist.
  Future<Database> initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "passless.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  /// Creates the initial setup of the database.
  void _onCreate(Database db, int version) async {
    // When creating the db, create the receipts table
    await db.execute(
      "CREATE TABLE Receipts(id INTEGER PRIMARY KEY, receipt TEXT)");
    await db.rawInsert(
      "INSERT INTO Receipts (receipt) VALUES (?)",
      ["""{
      "time": "2018-10-28T10:27:00+01:00",
      "currency": "EUR",
      "total": 22.58,
      "tax": 1.35,
      "items": [
          {
              "name": "Bananen",
              "brand": "AH Biologisch",
              "quantity": 1.00,
              "unit": "KG",
              "unitPrice": 2.59,
              "currency": "EUR",
              "subTotal": 2.59,
              "tax": 0.1554
          },
          {
              "name": "Baby dry pants maat 5",
              "brand": "Pampers",
              "quantity": 3,
              "unit": "pc",
              "unitPrice": 9.99,
              "currency": "EUR",
              "discounts": [{
                  "name": "2 + 1 gratis",
                  "original": 29.97,
                  "deduct": 9.99 
              }],
              "subTotal": 19.98,
              "tax": 1.1988
          }
      ],
      "payments": [
          {
              "method": "cash",
              "currency": "EUR",
              "amount": 20.00,
              "meta": {
                  "tendered": 20.00,
                  "change": 0.00
              }
          },
          {
              "method": "card",
              "currency": "EUR",
              "amount": 2.58,
              "meta": {
                  "type": "Maestro",
                  "cardNumber": "1234 5678 1234 5678",
                  "expiration": "2023-10-28T00:00:00Z"
              }
          }
      ],
      "loyalties": [
          {
            "points": 412
          }
      ],
      "vendor": {
          "name": "Albert Heijn 1376",
          "address": "Amsterdamsestraatweg 367A, 3551CK, Utrecht",
          "telNumber": "030-2420200",
          "vatNumber": "NL002230884b01",
          "kvkNumber": "35012085",
          "web": "https://www.ah.nl/winkel/1376",
          "meta": {
            "operator": "Henny van de Hoek"
          }
      }
    }"""]);
    print("Created tables");
  }

  /// Retrieves all receipts.
  Future<List<Receipt>> getReceipts() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery("SELECT receipt FROM receipts");
    List<Receipt> receipts = new List<Receipt>();
    for (int i = 0; i < list.length; i++) {
      var receiptJson = json.decode(list[i]["receipt"]);
      receipts.add(Receipt.fromJson(receiptJson));
    }

    return receipts;
  }

  /// Stores the specified receipt.
  void saveReceipt(Receipt receipt) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.insert('receipts', receipt.toJson());
    });
  }

  Future<List<Receipt>> search(String search) async {
    Database dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
      """SELECT receipt FROM receipts
         WHERE json_extract(receipt, \$.vendor.name) LIKE ? || '%'""",
      [search]);

    List<Receipt> receipts = new List<Receipt>();
    for (int i = 0; i < list.length; i++) {
      var receiptJson = json.decode(list[i]["receipt"]);
      receipts.add(Receipt.fromJson(receiptJson));
    }

    return receipts;
  }
}