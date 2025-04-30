import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'history_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('TATA Retail',
              style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'BILLING'),
              Tab(text: 'HISTORY'),
            ],
            labelStyle:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            indicatorColor: Colors.white,
          ),
          centerTitle: true,
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const TabBarView(
          children: [
            HomeScreen(),
            HistoryScreen(),
          ],
        ),
      ),
    );
  }
}
