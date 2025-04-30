import 'package:flutter/material.dart';
import 'package:gst_billing_app/models/invoice.dart';
import '../models/product.dart';
import '../services/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Product> cartItems = [];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _searchController = TextEditingController();
  double _selectedGST = 5.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final products = await DatabaseHelper.instance.getAllProducts();
    setState(() {
      cartItems.clear();
      cartItems.addAll(products);
      _isLoading = false;
    });
  }

  void _addProduct() async {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: DateTime.now().toString(),
        name: _nameController.text,
        price: double.parse(_priceController.text),
        gstPercentage: _selectedGST,
      );

      await DatabaseHelper.instance.insertProduct(product);
      setState(() {
        cartItems.insert(0, product);
      });
      _nameController.clear();
      _priceController.clear();
      Navigator.pop(context);
    }
  }

  Future<void> _filterProducts(String query) async {
    if (query.isEmpty) {
      await _loadProducts();
    } else {
      final products = await DatabaseHelper.instance.searchProducts(query);
      setState(() {
        cartItems.clear();
        cartItems.addAll(products);
      });
    }
  }

  Future<void> _deleteProduct(String id, int index) async {
    await DatabaseHelper.instance.deleteProduct(id);
    setState(() {
      cartItems.removeAt(index);
    });
  }

  double get totalAmount => cartItems.fold(
        0,
        (sum, item) => sum + item.totalPrice,
      );

  void _generateInvoice() async {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add items to generate invoice')),
      );
      return;
    }

    final invoice = Invoice(
      id: DateTime.now().toString(),
      items: cartItems
          .map((item) => {
                'id': item.id,
                'name': item.name,
                'price': item.price,
                'gstPercentage': item.gstPercentage,
                'totalPrice': item.totalPrice,
              })
          .toList(),
      totalAmount: totalAmount,
      createdAt: DateTime.now().toIso8601String(),
    );

    await DatabaseHelper.instance.saveInvoice(invoice);
    await DatabaseHelper.instance
        .deleteAllProducts(); // Add this line to clear products
    setState(() {
      cartItems.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice generated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _filterProducts,
                  ),
                ),
              ],
            ),
          ),
          // List view
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: cartItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 64,
                                    color: Colors.blue[700],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Your cart is empty',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              final item = cartItems[index];
                              return Dismissible(
                                key: Key(item.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.red[400],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (direction) =>
                                    _deleteProduct(item.id, index),
                                child: Card(
                                  elevation: 2,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    title: Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        Text(
                                          'Base Price: ₹${item.price.toStringAsFixed(2)}',
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                        Text(
                                          'GST: ${item.gstPercentage}%',
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                        Text(
                                          'CGST: ₹${item.cgst.toStringAsFixed(2)} • SGST: ₹${item.sgst.toStringAsFixed(2)}',
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                    trailing: Text(
                                      '₹${item.totalPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[700]!, Colors.blue[800]!],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '₹${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _generateInvoice,
                  backgroundColor: Colors.green[600],
                  child: const Icon(Icons.receipt_long, color: Colors.white),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: () => _showAddProductDialog(),
                  backgroundColor: Colors.blue[700],
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Add Product',
          style: TextStyle(
            color: Colors.blue[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.shopping_bag_outlined),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter product name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.currency_rupee),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter price' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<double>(
                value: _selectedGST,
                items: [5.0, 12.0, 18.0, 28.0].map((gst) {
                  return DropdownMenuItem(
                    value: gst,
                    child: Text('$gst%'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGST = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'GST Rate',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.percent),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: _addProduct,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Add',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
