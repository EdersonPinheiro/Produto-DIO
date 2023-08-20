import 'dart:convert';
import 'package:collection/equality.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../model/product.dart';
import 'package:path/path.dart';

class DB {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "dio");
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    await createTableProducts(db); // PRODUTOS
  }

  Future<void> createTableProducts(Database db) async {
    await db.execute('''
      CREATE TABLE product (
        localId TEXT PRIMARY KEY,
        image TEXT,
        name TEXT,
        description TEXT,
        quantity INTEGER,
        groups TEXT,
        status TEXT,
        sync TEXT,
        setorhook TEXT
      )
    ''');
  }

  Future<void> addProduct(Product product) async {
    final dbClient = await db;
    await dbClient.insert('product', {
      'localId': product.localId,
      'image': product.image,
      'name': product.name,
      'description': product.description,
      'quantity': product.quantity,
      'status': product.status,
    });
  }

  Future<void> deleteProductLocal() async {
    final dbClient = await db;
    await dbClient.delete('product');
  }

  Future<List<Product>> getProductsDB() async {
    print("DB LOCAL");
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('product');
    List<Product> products = [];
    maps.forEach((map) {
      if (map['status'] != "delete") {
        products.add(Product(
          localId: map['localId'],
          image: map['image'],
          name: map['name'],
          description: map['description'],
          quantity: map['quantity'],
          status: map['status'] ?? '',
        ));
      }
    });
    print(maps.length);
    return products;
  }

  Future<void> deleteProductDB(Product product) async {
    final dbClient = await db;

    // Atualiza produto na base de dados
    await dbClient.update('product', {"status": "delete"},
        where: 'localId = ?', whereArgs: [product.localId]);
  }

  Future<int> updateProduct(Product product) async {
    final dbClient = await db;
    return await dbClient.update(
      'product',
      product.toJson(),
      where: 'localId = ?',
      whereArgs: [product.localId],
    );
  }

  Future<List<Product>> getProducts() async {
    final dbClient = await db;
    final result = await dbClient.query(
      'product',
      where: 'status IN (?, ?, ?)',
      whereArgs: ['new', 'delete', 'update'],
    );
    return result.map((json) => Product.fromJson(json)).toList();
  }
}
