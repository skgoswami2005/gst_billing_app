import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gst_billing.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        gstPercentage REAL NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<String> insertProduct(Product product) async {
    final db = await instance.database;
    await db.insert('products', {
      'id': product.id,
      'name': product.name,
      'price': product.price,
      'gstPercentage': product.gstPercentage,
      'createdAt': DateTime.now().toIso8601String(),
    });
    return product.id;
  }

  Future<List<Product>> getAllProducts() async {
    final db = await instance.database;
    final result = await db.query('products', orderBy: 'createdAt DESC');

    return result
        .map((json) => Product(
              id: json['id'] as String,
              name: json['name'] as String,
              price: json['price'] as double,
              gstPercentage: json['gstPercentage'] as double,
            ))
        .toList();
  }

  Future<void> deleteProduct(String id) async {
    final db = await instance.database;
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'products',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'createdAt DESC',
    );

    return result
        .map((json) => Product(
              id: json['id'] as String,
              name: json['name'] as String,
              price: json['price'] as double,
              gstPercentage: json['gstPercentage'] as double,
            ))
        .toList();
  }
}
