import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../services/database_helper.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Invoice> _invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() => _isLoading = true);
    final invoices = await DatabaseHelper.instance.getAllInvoices();
    setState(() {
      _invoices = invoices;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _invoices.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 64, color: Colors.blue[700]),
                    const SizedBox(height: 16),
                    Text('No invoices yet',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _invoices.length,
                itemBuilder: (context, index) {
                  final invoice = _invoices[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Invoice #${invoice.id.substring(0, 8)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text('₹${invoice.totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                              'Date: ${DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.parse(invoice.createdAt))}',
                              style: TextStyle(color: Colors.grey[600])),
                          Text('${invoice.items.length} items',
                              style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: () {
                          // TODO: Show invoice details
                        },
                      ),
                    ),
                  );
                },
              );
  }
}
