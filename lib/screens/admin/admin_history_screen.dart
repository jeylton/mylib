import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/borrowing_model.dart';
import '../../services/borrowing_service.dart';

class AdminHistoryScreen extends StatefulWidget {
  const AdminHistoryScreen({super.key});

  @override
  State<AdminHistoryScreen> createState() => _AdminHistoryScreenState();
}

class _AdminHistoryScreenState extends State<AdminHistoryScreen> {
  List<BorrowingModel> returnedBorrowings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    setState(() => isLoading = true);
    try {
      final allBorrowings = await BorrowingService.fetchAllBorrowings();

      setState(() {
        returnedBorrowings = allBorrowings
            .where((b) => b.status.toLowerCase() == 'returned')
            .toList();
      });
    } catch (e) {
      print('Error loading history: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin History (Returned / Fulfilled)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadHistory,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadHistory,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text("📘 Returned Borrowings",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (returnedBorrowings.isEmpty)
                    const Text("No returned borrowings."),
                  ...returnedBorrowings.map(
                    (b) => ListTile(
                      leading: const Icon(Icons.book, color: Colors.green),
                      title: Text(b.book.title),
                      subtitle: Text(
                          "By: ${b.user.name} | Returned: ${DateFormat.yMMMd().format(b.returnDate!)}"),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
